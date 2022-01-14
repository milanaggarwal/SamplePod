import Foundation

public enum UserDefaultsManagerError: Error {
    case unableToDecode, unableToEncode, defaultNotFound
}

/// Provides functionality to manage user defaults
/// 
public class UserDefaultsManager<UserDefault: Codable> {
    private let defaults: UserDefaults

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var key: String {
        String(describing: self)
    }

    var exists: Bool {
        let userDefault = try? get()
        return userDefault != nil
    }

    public init(suiteName: String) {
        self.defaults = UserDefaults(suiteName: suiteName)!
    }

    public func get() throws -> UserDefault {
        guard let savedUserDefault = defaults.object(forKey: key) as? Data else {
            throw UserDefaultsManagerError.defaultNotFound
        }
        do {
            return try decoder.decode(UserDefault.self, from: savedUserDefault)
        } catch {
            throw UserDefaultsManagerError.unableToDecode
        }
    }

    public func save(_ userDefault: UserDefault) throws {
        guard let encodedUserDefault = try? encoder.encode(userDefault) else {
            throw UserDefaultsManagerError.unableToEncode
        }
        defaults.set(encodedUserDefault, forKey: key)
    }

    public func save(modifications modify: (inout UserDefault) -> Void) throws {
        var userDefault = try get()
        modify(&userDefault)
        try save(userDefault)
    }

    public func clear() {
        defaults.removeObject(forKey: key)
    }
}

extension UserDefaultsManager where UserDefault: HasEmptyInit {
    func getOrCreate() -> UserDefault {
        do {
            return try get()
        } catch {
            let userDefault = UserDefault()
            try! save(userDefault)
            return userDefault
        }
    }
}

protocol HasEmptyInit {
    init()
}

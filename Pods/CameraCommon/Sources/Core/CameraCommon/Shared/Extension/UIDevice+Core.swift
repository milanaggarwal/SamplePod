import UIKit

public extension UIDevice {
    
    /// Get the full model name from the system.
    ///
    /// Useful for determining which processor generation the device has.
    ///
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    /// Determines whether Metal rendering is practical on the device.
    ///
    /// Checks to see if the current device is one of the older devices which don't have a fast enough
    /// GPU to apply real-time effects to the video.
    ///
    func isEffectCapable(modelName: String? = nil) -> Bool {
        let name = modelName ?? self.modelName
        let type = name.prefix(4).lowercased()
        if type == "ipad" {
            guard
                let majorString = name.dropFirst(4).first,
                let major = Int(String(majorString))
            else {
                return true
            }
            // Minimum versions:
            // - iPad: 5th Gen
            // - iPad Mini 4
            // - iPad Pro
            // - iPad Air 2
            return major > 4
        } else if type == "ipho" {
            guard
                let majorString = name.dropFirst(6).first,
                let major = Int(String(majorString))
            else {
                return true
            }
            // Minimum versions:
            // iPhone 6s / 6s Plus / SE
            return major > 7
        } else if type == "x86_" {
            // Simulator detected.
            return true
        }
        // I guess we got it running on AppleTV?
        return true
    }
}



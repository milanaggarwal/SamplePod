import Foundation
import os.log

public final class Logger {
    
    public struct LogID {
        internal let id: OSSignpostID
        public let label: StaticString
    }
    
    public static let shared: Logger = Logger()
    
    private let perfLog = OSLog(subsystem: "com.flipgrid.camera", category: "performance-logging")
    private let perfEventLog = OSLog(subsystem: "com.flipgid.camera", category: .pointsOfInterest)
    private let standardLog = OSLog(subsystem: "com.flipgrid.camera", category: "event-log")
    
    public func startPerformanceTrace(label: StaticString? = nil) -> LogID {
        let label = label ?? "Performance"
        let id = OSSignpostID(log: perfLog)
        os_signpost(.begin, log: perfLog, name: label, signpostID: id)
        return LogID(id: id, label: label)
    }
    
    public func endPerformanceTrace(id: LogID) {
        os_signpost(.end, log: perfLog, name: id.label, signpostID: id.id)
    }
    
    public func logPerformanceEvent(label: StaticString) {
        os_signpost(.event, log: perfEventLog, name: label)
    }
    
    public func log(string: StaticString, level: OSLogType = .default) {
        os_log(level, log: standardLog, string)
    }
}

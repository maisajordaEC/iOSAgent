import Foundation

/// Base class for Beacon.
class Beacon: Identifiable {
    let id = UUID()
    let sessionID: UUID
    var timestamp: Instana.Types.Milliseconds = Date().millisecondsSince1970

    init(timestamp: Instana.Types.Milliseconds = Date().millisecondsSince1970,
         sessionID: UUID = Instana.current?.session.id ?? UUID()) {
        self.sessionID = sessionID
        self.timestamp = timestamp
    }
}

enum BeaconResult {
    case success
    case failure(Error)

    var error: Error? {
        switch self {
        case .success: return nil
        case let .failure(error): return error
        }
    }
}

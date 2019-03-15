//  Created by Nikola Lajic on 1/25/19.
//  Copyright © 2019 Nikola Lajic. All rights reserved.

import Foundation

class InstanaSessionProfileEvent: InstanaEvent, InstanaEventResultNotifiable {
    var completion: CompletionBlock {
        get { return handleCompletion }
    }
    private let maxRetryInterval: Instana.Types.Milliseconds = 30_000
    private var retryInterval: Instana.Types.Milliseconds {
        didSet {
            if retryInterval > maxRetryInterval { retryInterval = maxRetryInterval }
        }
    }
    private let submitEvent: InstanaEvents.Submitter
    
    init(retryInterval: Instana.Types.Milliseconds = 50, submitEvent: @escaping InstanaEvents.Submitter = Instana.events.submit(event:)) {
        self.retryInterval = retryInterval
        self.submitEvent = submitEvent
        super.init(eventId: nil, timestamp: 0)
    }
    
    private override init(sessionId: String, eventId: String?, timestamp: Instana.Types.UTCTimestamp) {
        fatalError()
    }
    
    override func toJSON() -> [String : Any] {
        var json = super.toJSON()
        json["profile"] = [
            "platform": "iOS",
            "osLevel": InstanaSystemUtils.systemVersion,
            "deviceType": InstanaSystemUtils.deviceModel,
            "appVersion": InstanaSystemUtils.applicationVersion,
            "appBuild": InstanaSystemUtils.applicationBuildNumber,
            "clientId": InstanaSystemUtils.clientId
        ]
        return json
    }
}

private extension InstanaSessionProfileEvent {
    func handleCompletion(result: InstanaEventResult) -> Void {
        switch result {
        case .success:
            Instana.log.add("Session profile sent")
        case .failure(_):
            Instana.log.add("Failed to send session profile. Retrying in \(retryInterval) ms.")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(retryInterval))) {
                self.submitEvent(self)
            }
            retryInterval *= 2
        }
    }
}


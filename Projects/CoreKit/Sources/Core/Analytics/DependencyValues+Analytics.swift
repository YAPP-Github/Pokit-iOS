import Dependencies
import Foundation

/// Amplitude Client Protocol
public struct AmplitudeClient {
    public var initialize: @Sendable (String, String?) -> Void
    public var track: @Sendable (AnalyticsEvent) -> Void
    public var setUserId: @Sendable (String) -> Void
    public var setUserProperties: @Sendable ([String: Any]) -> Void
    public var flush: @Sendable () -> Void
    public var reset: @Sendable () -> Void
}

public extension DependencyValues {
    var amplitude: AmplitudeClient {
        get { self[AmplitudeClientKey.self] }
        set { self[AmplitudeClientKey.self] = newValue }
    }
}

private enum AmplitudeClientKey: DependencyKey {
    static let liveValue = AmplitudeClient(
        initialize: { apiKey, userId in
            AmplitudeManager.shared.initialize(apiKey: apiKey, userId: userId)
        },
        track: { event in
            AmplitudeManager.shared.track(event)
        },
        setUserId: { userId in
            AmplitudeManager.shared.setUserId(userId)
        },
        setUserProperties: { properties in
            AmplitudeManager.shared.setUserProperties(properties)
        },
        flush: {
            AmplitudeManager.shared.flush()
        },
        reset: {
            AmplitudeManager.shared.reset()
        }
    )

    static let testValue = AmplitudeClient(
        initialize: { _, _ in },
        track: { _ in },
        setUserId: { _ in },
        setUserProperties: { _ in },
        flush: { },
        reset: { }
    )
}

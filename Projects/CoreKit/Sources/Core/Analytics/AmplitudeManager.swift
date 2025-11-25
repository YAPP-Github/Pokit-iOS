import Foundation
import AmplitudeSwift

/// Amplitude Analytics 관리자
public final class AmplitudeManager {
    public static let shared = AmplitudeManager()

    private var amplitude: Amplitude?

    private init() {}

    /// Amplitude 초기화
    /// - Parameters:
    ///   - apiKey: Amplitude API Key
    ///   - userId: 사용자 ID (옵셔널)
    public func initialize(apiKey: String, userId: String? = nil) {
        amplitude = Amplitude(configuration: Configuration(
            apiKey: apiKey
        ))

        if let userId = userId {
            setUserId(userId)
        }
    }

    /// 사용자 ID 설정
    /// - Parameter userId: 사용자 ID
    public func setUserId(_ userId: String) {
        amplitude?.setUserId(userId: userId)
    }

    /// 사용자 속성 설정
    /// - Parameter properties: 사용자 속성
    public func setUserProperties(_ properties: [String: Any]) {
        let identify = Identify()
        properties.forEach { key, value in
            identify.set(property: key, value: value)
        }
        amplitude?.identify(identify: identify)
    }

    /// 이벤트 전송
    /// - Parameter event: AnalyticsEvent
    public func track(_ event: AnalyticsEvent) {
        guard let amplitude = amplitude else {
            print("⚠️ Amplitude가 초기화되지 않았습니다.")
            return
        }

        let eventProperties = event.properties.isEmpty ? nil : event.properties
        amplitude.track(
            eventType: event.eventName,
            eventProperties: eventProperties
        )

        #if DEBUG
        print("📊 [Analytics] \(event.eventName)")
        if let properties = eventProperties {
            print("   Properties: \(properties)")
        }
        #endif
    }

    /// 이벤트 버퍼 즉시 전송
    public func flush() {
        amplitude?.flush()
    }

    /// Amplitude 리셋 (로그아웃 시 사용)
    public func reset() {
        amplitude?.reset()
    }
}

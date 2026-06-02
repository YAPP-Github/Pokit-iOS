import Foundation
import CoreKit
import Testing

@MainActor
struct DeeplinkRouterTests {
    @Test("DeeplinkRouter 큐잉/FIFO 배출/브로드캐스트/파싱")
    func queueDrainBroadcastAndParse() async {
        let router = DeeplinkRouteClient.liveValue
        
        await router.routeTo(URL(string: "pokit://shared?categoryId=1&contentId=2&userId=3"))
        await router.routeTo(URL(string: "pokit://alert"))
        
        var queuedIterator = router.routeStream().makeAsyncIterator()
        let queuedFirst = await queuedIterator.next()
        let queuedSecond = await queuedIterator.next()
        
        #expect(queuedFirst == .pokitShared(
            categoryId: 1,
            contentId: 2,
            userId: 3
        ))
        #expect(queuedSecond == .pokitAlert)
        
        var firstSubscriber = router.routeStream().makeAsyncIterator()
        var secondSubscriber = router.routeStream().makeAsyncIterator()
        
        await router.routeTo(URL(string: "pokit://shared?categoryId=9&contentId=10&userId=11"))
        
        let firstReceived = await firstSubscriber.next()
        let secondReceived = await secondSubscriber.next()
        
        #expect(firstReceived == .pokitShared(
            categoryId: 9,
            contentId: 10,
            userId: 11
        ))
        #expect(secondReceived == .pokitShared(
            categoryId: 9,
            contentId: 10,
            userId: 11
        ))
        
        var invalidCheckSubscriber = router.routeStream().makeAsyncIterator()
        await router.routeTo(URL(string: "https://example.com/deeplink"))
        await router.routeTo(URL(string: "pokit://alert"))
        
        let afterInvalid = await invalidCheckSubscriber.next()
        #expect(afterInvalid == .pokitAlert)
    }
}

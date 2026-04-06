//
//  MainTabDeeplinkUITests.swift
//  AppUITests
//
//  Created by 김도형 on 2/18/26.
//

import XCTest

final class MainTabDeeplinkUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_앱이_실행되고_기본화면이_표시된다() {
        let app = XCUIApplication()
        app.launch()

        let candidates: [XCUIElement] = [
            app.otherElements["main-tab-root"].firstMatch,
            app.buttons["Apple로 계속하기"].firstMatch,
            app.buttons["Google로 계속하기"].firstMatch
        ]

        let found = candidates.contains { $0.waitForExistence(timeout: 8) }
        XCTAssertTrue(found, "앱의 기본 화면(main tab 또는 로그인)이 표시되지 않았습니다.")
    }

    func test_카카오_openurl_카테고리_공유딥링크는_해당카테고리로_이동한다() {
        let app = launchDeeplinkApp(
            deeplinks: [
                "kakao7890f93caf1d9d5da976da4b4bc6e5e7://kakaolink?categoryId=2&shareType=share"
            ]
        )

        waitForElement(element(in: app, id: "category-detail-2"), in: app)
    }

    func test_포킷_alert_push는_알림함으로_이동한다() {
        let app = launchDeeplinkApp(
            deeplinks: ["pokit://alert"]
        )

        waitForElement(element(in: app, id: "main-tab-root"), in: app)
        waitForElement(app.staticTexts["알림함"].firstMatch, in: app)
    }

    func test_포킷_push_컨텐츠아이디가_있는_공유딥링크는_상세시트를_열고_닫은뒤_777카드를_확인한다() {
        let app = launchDeeplinkApp(
            deeplinks: ["pokit://shared?categoryId=2&contentId=777"]
        )

        waitForElement(element(in: app, id: "category-detail-2"), in: app)

        let contentSheet = app.scrollViews["content-detail-sheet"].firstMatch
        waitForElement(contentSheet, in: app)

        dismissSheet(contentSheet, in: app)
        waitForElement(element(in: app, id: "content-card-777"), in: app)
    }

    func test_포킷_push_유저아이디가_있는_공유딥링크는_참여인원시트를_연다() {
        let app = launchDeeplinkApp(
            deeplinks: ["pokit://shared?categoryId=2&userId=999"]
        )

        waitForElement(element(in: app, id: "category-detail-2"), in: app)
        waitForElement(element(in: app, id: "participants-sheet"), in: app)
    }

    func test_앱실행직후_포킷_push_딥링크를_넣어도_정상_라우팅된다() {
        let app = launchDeeplinkApp(
            deeplinks: ["pokit://shared?categoryId=2"],
            routeBeforeMainTab: true
        )

        waitForElement(element(in: app, id: "category-detail-2"), in: app)
    }

    func test_같은카테고리로_재라우팅하면_중복푸시되지_않는다() {
        let app = launchDeeplinkApp(
            deeplinks: [
                "pokit://shared?categoryId=2",
                "pokit://shared?categoryId=2"
            ]
        )

        let categoryDetail = element(in: app, id: "category-detail-2")
        waitForElement(categoryDetail, in: app)

        let backButton = app.buttons["category-detail-back"].firstMatch
        waitForElement(backButton, in: app)

        backButton.tap()

        waitForElement(element(in: app, id: "main-tab-root"), in: app)
        waitForAbsence(categoryDetail, in: app)
    }

    func test_다른카테고리로_재라우팅하면_스택에_추가이동된다() {
        let app = launchDeeplinkApp(
            deeplinks: [
                "pokit://shared?categoryId=2",
                "pokit://shared?categoryId=3"
            ]
        )

        waitForElement(element(in: app, id: "category-detail-3"), in: app)

        let backButton = app.buttons["category-detail-back"].firstMatch
        waitForElement(backButton, in: app)

        backButton.tap()

        waitForElement(element(in: app, id: "category-detail-2"), in: app)
    }
}

private extension MainTabDeeplinkUITests {
    func launchDeeplinkApp(
        deeplinks: [String],
        routeBeforeMainTab: Bool = false,
        forceMainTab: Bool = true
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["UITEST_MODE"] = "1"
        app.launchEnvironment["UITEST_SCENARIO"] = "deeplink"
        app.launchEnvironment["UITEST_FORCE_MAIN_TAB"] = forceMainTab ? "1" : "0"
        app.launchEnvironment["UITEST_ROUTE_BEFORE_MAIN_TAB"] = routeBeforeMainTab ? "1" : "0"
        app.launchEnvironment["UITEST_DEEPLINKS_JSON"] = deeplinkJSONString(from: deeplinks)
        app.launch()
        return app
    }

    func element(in app: XCUIApplication, id: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: id).firstMatch
    }

    @discardableResult
    func waitForElement(
        _ element: XCUIElement,
        in app: XCUIApplication,
        timeout: TimeInterval = 8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        let exists = element.waitForExistence(timeout: timeout)
        if !exists {
            XCTFail(
                """
                Element not found: \(element.identifier)

                Hierarchy:
                \(app.debugDescription)
                """,
                file: file,
                line: line
            )
        }
        return exists
    }

    func waitForAbsence(
        _ element: XCUIElement,
        in app: XCUIApplication,
        timeout: TimeInterval = 5,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        if result != .completed {
            XCTFail(
                """
                Element did not disappear: \(element.identifier)

                Hierarchy:
                \(app.debugDescription)
                """,
                file: file,
                line: line
            )
        }
    }

    func dismissSheet(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 4) {
        guard element.exists else { return }

        for _ in 0..<maxSwipes where element.exists {
            element.swipeDown()
        }

        waitForAbsence(element, in: app)
    }

    func deeplinkJSONString(from deeplinks: [String]) -> String {
        guard
            let data = try? JSONSerialization.data(withJSONObject: deeplinks, options: []),
            let json = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return json
    }
}

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

    func test_카테고리만_있는_공유딥링크는_해당카테고리로_이동한다() throws {
        let app = launchApp(
            deeplinks: ["pokit://shared?categoryId=2"]
        )

        waitForElement(element(in: app, id: "category-detail-2"))
    }

    func test_컨텐츠아이디가_있는_공유딥링크는_상세시트를_열고_닫은뒤_777카드를_확인한다() throws {
        let app = launchApp(
            deeplinks: ["pokit://shared?categoryId=2&contentId=777"]
        )

        waitForElement(element(in: app, id: "category-detail-2"))
        let contentSheet = app.scrollViews["content-detail-sheet"].firstMatch
        waitForElement(contentSheet)

        dismissSheet(contentSheet)
        waitForElement(element(in: app, id: "content-card-777"))
    }

    func test_유저아이디가_있는_공유딥링크는_참여인원시트를_연다() throws {
        let app = launchApp(
            deeplinks: ["pokit://shared?categoryId=2&userId=999"]
        )

        waitForElement(element(in: app, id: "category-detail-2"))
        waitForElement(element(in: app, id: "participants-sheet"))
    }

    func test_메인탭_진입전_딥링크를_넣어도_진입후_정상_라우팅된다() throws {
        let app = launchApp(
            deeplinks: ["pokit://shared?categoryId=2"],
            routeBeforeMainTab: true
        )

        waitForElement(element(in: app, id: "category-detail-2"))
    }

    func test_같은카테고리로_재라우팅하면_중복푸시되지_않는다() throws {
        let app = launchApp(
            deeplinks: [
                "pokit://shared?categoryId=2",
                "pokit://shared?categoryId=2"
            ]
        )

        waitForElement(element(in: app, id: "category-detail-2"))
        let backButton = app.buttons["category-detail-back"]
        waitForElement(backButton)

        backButton.tap()

        waitForElement(element(in: app, id: "main-tab-root"))
        XCTAssertFalse(element(in: app, id: "category-detail-2").exists)
    }

    func test_다른카테고리로_재라우팅하면_스택에_추가이동된다() throws {
        let app = launchApp(
            deeplinks: [
                "pokit://shared?categoryId=2",
                "pokit://shared?categoryId=3"
            ]
        )

        waitForElement(element(in: app, id: "category-detail-3"))
        let backButton = app.buttons["category-detail-back"]
        waitForElement(backButton)

        backButton.tap()

        waitForElement(element(in: app, id: "category-detail-2"))
    }
}

private extension MainTabDeeplinkUITests {
    func launchApp(
        deeplinks: [String],
        routeBeforeMainTab: Bool = false
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["UITEST_MODE"] = "1"
        app.launchEnvironment["UITEST_FORCE_MAIN_TAB"] = "1"
        app.launchEnvironment["UITEST_ROUTE_BEFORE_MAIN_TAB"] = routeBeforeMainTab ? "1" : "0"
        app.launchEnvironment["UITEST_DEEPLINKS_JSON"] = deeplinkJSONString(from: deeplinks)
        app.launch()
        return app
    }

    func element(in app: XCUIApplication, id: String) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }

    @discardableResult
    func waitForElement(
        _ element: XCUIElement,
        timeout: TimeInterval = 8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        let exists = element.waitForExistence(timeout: timeout)
        XCTAssertTrue(
            exists,
            "Element not found: \(element.identifier)",
            file: file,
            line: line
        )
        return exists
    }

    func waitForElementToDisappear(
        _ element: XCUIElement,
        timeout: TimeInterval = 5,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(
            result,
            .completed,
            "Element did not disappear: \(element.identifier)",
            file: file,
            line: line
        )
    }

    func dismissSheet(_ element: XCUIElement, maxSwipes: Int = 4) {
        guard element.exists else { return }

        for _ in 0..<maxSwipes where element.exists {
            element.swipeDown()
        }
    }

    func deeplinkJSONString(from deeplinks: [String]) -> String {
        let data = try? JSONSerialization.data(withJSONObject: deeplinks, options: [])
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }
}

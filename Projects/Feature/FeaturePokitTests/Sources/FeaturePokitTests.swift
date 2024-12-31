import ComposableArchitecture
import XCTest

@testable import FeaturePokit
@testable import Domain

final class FeaturePokitTests: XCTestCase {
    /// ex) 1.3.5버전일 때
    /// 1: Major
    /// 3: Minor
    /// 5: Patch
    
    func test_patch_버전이_앱스토어가_더_커도_업데이트가_필요하지_않다() {
        let current_V = Version("1.0.8", trackId: 0)
        let appStore_V = Version("1.0.9", trackId: 0)
        
        let result = updateNeeded(currentVersion: current_V, appStoreVersion: appStore_V)
        /// expect: False
        XCTAssertFalse(result)
    }
    
    func test_minor_버전이_앱스토어가_더_클때_업데이트가_필요하다() {
        let current_V = Version("1.0.8", trackId: 0)
        let appStore_V = Version("1.1.8", trackId: 0)
        
        let result = updateNeeded(currentVersion: current_V, appStoreVersion: appStore_V)
        /// expect: True
        XCTAssertTrue(result)
    }
    
    func test_major_버전이_앱스토어가_더_클때_업데이트가_필요하다() {
        let current_V = Version("1.0.8", trackId: 0)
        let appStore_V = Version("2.0.8", trackId: 0)
        
        let result = updateNeeded(currentVersion: current_V, appStoreVersion: appStore_V)
        /// expect: True
        XCTAssertTrue(result)
    }
    
    func test_major는_앱스토어가_더_높고_minor는_현재_버전이_더_클때_업데이트가_필요하다() {
        let current_V = Version("1.6.4", trackId: 0)
        let appStore_V = Version("2.1.4", trackId: 0)
        
        let result = updateNeeded(currentVersion: current_V, appStoreVersion: appStore_V)
        /// expect: True
        XCTAssertTrue(result)
    }
    
    func test_버전이_같다면_업데이트가_필요하지_않다() {
        let current_V = Version("1.0.8", trackId: 0)
        let appStore_V = Version("1.0.8", trackId: 0)
        
        let result = updateNeeded(currentVersion: current_V, appStoreVersion: appStore_V)
        /// expect: False
        XCTAssertFalse(result)
    }

}

extension FeaturePokitTests {
    func updateNeeded(
        currentVersion: Version,
        appStoreVersion: Version
    ) -> Bool {
        return currentVersion < appStoreVersion
    }
}

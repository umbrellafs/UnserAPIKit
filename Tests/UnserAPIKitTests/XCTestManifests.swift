import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(UnserAPIKitTests.allTests),
    ]
}
#endif

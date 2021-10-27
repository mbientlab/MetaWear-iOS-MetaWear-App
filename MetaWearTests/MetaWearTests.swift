import XCTest
@testable import MetaWearMac
import Combine
//
//class NaiveGraphControllerTests: XCTestCase {
//
//    func testDisplaysInitialDataOnInit() throws {
//        let test = createTestDataAndConfig([[1, 2, 3], [4, 5, 6]])
//        let sut = ScrollingStaticGraph(controller: test.config, width: 400)
//        let result = sut.displayedPoints.map { point -> [Float] in
//            point.heights.map(Float.init)
//        }
//        XCTAssertEqual(test.exp, result)
//    }
//
//    func testDisplaysEmptyDataOnEmptyInit() throws {
//        let test = createTestDataAndConfig([])
//        let sut = ScrollingStaticGraph(controller: test.config, width: 400)
//        let result = sut.displayedPoints.map { point -> [Float] in
//            point.heights.map(Float.init)
//        }
//        XCTAssertEqual(test.exp, result)
//    }
//
//}
//
//private extension NaiveGraphControllerTests {
//    func createTestDataAndConfig(_ testData: [[Float]]) -> (exp: [[Float]], config: GraphConfig) {
//        var config = GraphConfig.makeXYZLiveOverwriting(yAxisScale: 2, dataPoints: 0)
//        config.loadDataConvertingFromTimeSeries(testData)
//        return (testData, config)
//    }
//}

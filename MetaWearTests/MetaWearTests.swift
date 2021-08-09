import XCTest
@testable import MetaWearMac
import Combine

class NaiveGraphControllerTests: XCTestCase {

    let driver: GraphDriver = MockDoublesDriver(interval: 2)

    func testDisplaysInitialDataOnInit() throws {
        let test = createTestDataAndConfig([[1, 2, 3], [4, 5, 6]])
        let sut = NaiveGraphController(config: test.config, driver: driver)
        let result = sut.displayedPoints.map { point -> [Float] in
            point.heights.map(Float.init)
        }
        XCTAssertEqual(test.exp, result)
    }

    func testDisplaysEmptyDataOnEmptyInit() throws {
        let test = createTestDataAndConfig([])
        let sut = NaiveGraphController(config: test.config, driver: driver)
        let result = sut.displayedPoints.map { point -> [Float] in
            point.heights.map(Float.init)
        }
        XCTAssertEqual(test.exp, result)
    }

}

private extension NaiveGraphControllerTests {
    func createTestDataAndConfig(_ testData: [[Float]]) -> (exp: [[Float]], config: GraphConfig) {
        var config = GraphConfig.makeXYZLiveOverwriting(yAxisScale: 2, dataPoints: 0)
        config.loadDataConvertingFromTimeSeries(testData)
        return (testData, config)
    }
}

private class MockDoublesDriver: GraphDriver {
    var delegate: GraphDriverDelegate? = nil
    var addRequests: CurrentValueSubject<[Float], Never> = .init([])
    var pipeline: AnyCancellable? = nil

    func stop() {
    }

    func restart() {
    }

    required init(interval: Double) {
        pipeline = addRequests
            .collect(2)
            .sink { [weak self] data in
                self?.delegate?.add(points: data)
        }
    }
}

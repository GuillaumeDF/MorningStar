//
//  MorningStarTests.swift
//  MorningStarTests
//
//  Created by Guillaume Djaider Fornari on 06/08/2024.
//

import XCTest
@testable import MorningStar

final class MorningStarTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - HealthMetricType Tests

    func testHealthMetricTypeDescription() throws {
        XCTAssertEqual(HealthMetricType.steps.description, "steps")
        XCTAssertEqual(HealthMetricType.calories.description, "calories")
        XCTAssertEqual(HealthMetricType.weight.description, "weight")
        XCTAssertEqual(HealthMetricType.sleep.description, "sleep")
        XCTAssertEqual(HealthMetricType.workouts.description, "workouts")
    }

    func testHealthMetricTypeAllCases() throws {
        XCTAssertEqual(HealthMetricType.allCases.count, 5)
    }

    // MARK: - IntensityLevel Tests

    func testIntensityLevelRawValues() throws {
        XCTAssertEqual(IntensityLevel.undetermined.rawValue, 0)
        XCTAssertEqual(IntensityLevel.low.rawValue, 1)
        XCTAssertEqual(IntensityLevel.moderate.rawValue, 2)
        XCTAssertEqual(IntensityLevel.high.rawValue, 3)
        XCTAssertEqual(IntensityLevel.veryHigh.rawValue, 4)
    }

    func testIntensityLevelFromRawValue() throws {
        XCTAssertEqual(IntensityLevel(rawValue: 0), .undetermined)
        XCTAssertEqual(IntensityLevel(rawValue: 1), .low)
        XCTAssertEqual(IntensityLevel(rawValue: 2), .moderate)
        XCTAssertEqual(IntensityLevel(rawValue: 3), .high)
        XCTAssertEqual(IntensityLevel(rawValue: 4), .veryHigh)
        XCTAssertNil(IntensityLevel(rawValue: 99))
    }
}

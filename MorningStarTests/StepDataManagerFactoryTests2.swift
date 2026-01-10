//
//  StepDataManagerFactoryTests2.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 21/02/2025.
//

import XCTest
import CoreData
@testable import MorningStar

private struct StepPeriodTestData2 {
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static var day29January2024 = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                startDate: formatter.date(from: "2024-01-29T10:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T11:00:00Z")!,
                value: 150,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-29T11:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T12:00:00Z")!,
                value: 200,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-29T12:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T13:00:00Z")!,
                value: 0,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-29T13:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T14:00:00Z")!,
                value: 50,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-29T14:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T15:00:00Z")!,
                value: 90,
                unit: "steps"
            )
        ]
    )
    
    static let day31_30_29ContinueDay31January2024WithLess5min = [
        StepPeriod(
            id: day31January2024.id,
            entries: [
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                    startDate: formatter.date(from: "2024-01-31T10:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T11:00:00Z")!,
                    value: 150,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T11:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T12:00:00Z")!,
                    value: 200,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T12:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T13:00:00Z")!,
                    value: 0,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T13:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T14:00:00Z")!,
                    value: 50,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T14:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T16:00:00Z")!,
                    value: 240,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T16:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T17:00:00Z")!,
                    value: 200,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T18:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T19:00:00Z")!,
                    value: 0,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T19:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T20:00:00Z")!,
                    value: 180,
                    unit: "steps"
                )
            ]
        ),
        day30January2024,
        day29January2024
    ]
    
    static let day01February_31_30_29ContinueDay31January2024WithLess5min = [
        day01February2024,
        StepPeriod(
            id: day31January2024.id,
            entries: [
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                    startDate: formatter.date(from: "2024-01-31T10:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T11:00:00Z")!,
                    value: 150,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T11:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T12:00:00Z")!,
                    value: 200,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T12:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T13:00:00Z")!,
                    value: 0,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T13:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T14:00:00Z")!,
                    value: 50,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T14:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T16:00:00Z")!,
                    value: 240,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T16:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T17:00:00Z")!,
                    value: 200,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T18:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T19:00:00Z")!,
                    value: 0,
                    unit: "steps"
                ),
                HealthData.ActivityEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                    startDate: formatter.date(from: "2024-01-31T19:00:00Z")!,
                    endDate: formatter.date(from: "2024-01-31T20:00:00Z")!,
                    value: 180,
                    unit: "steps"
                )
            ]
        ),
        day30January2024,
        day29January2024
    ]
    
    static let day31_30_29ContinueDay29January2024WithMore5min = [
        StepPeriod(
            id: day31January2024.id,
            entries: day31January2024.entries +
            [
                HealthData.ActivityEntry(
                    startDate: day31January2024.endDate!,
                    endDate: continueDay31January2024WithMore5min.startDate!,
                    value: 0,
                    unit: "steps"
                )
            ]
            + continueDay31January2024WithMore5min.entries
        ),
        day30January2024,
        day29January2024
    ]
    
    static let day01February_31_30_29ContinueDay31January2024WithMore5min = [
        day01February2024,
        StepPeriod(
            id: day31January2024.id,
            entries: day31January2024.entries +
            [
                HealthData.ActivityEntry(
                    startDate: day31January2024.endDate!,
                    endDate: continueDay31January2024WithMore5min.startDate!,
                    value: 0,
                    unit: "steps"
                )
            ]
            + continueDay31January2024WithMore5min.entries
        ),
        day30January2024,
        day29January2024
    ]
    
    static let day30January2024 = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                startDate: formatter.date(from: "2024-01-30T10:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T11:00:00Z")!,
                value: 150,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-30T11:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T12:00:00Z")!,
                value: 200,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-30T12:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T13:00:00Z")!,
                value: 0,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-30T13:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T14:00:00Z")!,
                value: 50,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-30T14:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T15:00:00Z")!,
                value: 90,
                unit: "steps"
            )
        ]
    )
    
    static let day31January2024 = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                startDate: formatter.date(from: "2024-01-31T10:00:00Z")!,
                endDate: formatter.date(from: "2024-01-31T11:00:00Z")!,
                value: 150,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-31T11:00:00Z")!,
                endDate: formatter.date(from: "2024-01-31T12:00:00Z")!,
                value: 200,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-31T12:00:00Z")!,
                endDate: formatter.date(from: "2024-01-31T13:00:00Z")!,
                value: 0,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-31T13:00:00Z")!,
                endDate: formatter.date(from: "2024-01-31T14:00:00Z")!,
                value: 50,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-31T14:00:00Z")!,
                endDate: formatter.date(from: "2024-01-31T15:00:00Z")!,
                value: 90,
                unit: "steps"
            )
        ]
    )
    
    static let continueDay31January2024WithLess5min = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                startDate: formatter.date(from: "2024-01-31T15:02:00Z")!,
                endDate: formatter.date(from: "2024-01-31T16:00:00Z")!,
                value: 150,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-31T16:00:00Z")!,
                endDate: formatter.date(from: "2024-01-31T17:00:00Z")!,
                value: 200,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-31T18:00:00Z")!,
                endDate: formatter.date(from: "2024-01-31T19:00:00Z")!,
                value: 0,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-31T19:00:00Z")!,
                endDate: formatter.date(from: "2024-01-31T20:00:00Z")!,
                value: 180,
                unit: "steps"
            )
        ]
    )
    
    static let continueDay31January2024WithMore5min = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                startDate: formatter.date(from: "2024-01-31T15:30:00Z")!,
                endDate: formatter.date(from: "2024-01-31T16:00:00Z")!,
                value: 150,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-31T16:00:00Z")!,
                endDate: formatter.date(from: "2024-01-31T17:00:00Z")!,
                value: 200,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-31T18:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T19:00:00Z")!,
                value: 0,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-31T19:00:00Z")!,
                endDate: formatter.date(from: "2024-01-31T20:00:00Z")!,
                value: 180,
                unit: "steps"
            )
        ]
    )
    
    static var day01February2024 = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                startDate: formatter.date(from: "2024-02-01T10:00:00Z")!,
                endDate: formatter.date(from: "2024-02-01T11:00:00Z")!,
                value: 150,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-02-01T11:00:00Z")!,
                endDate: formatter.date(from: "2024-02-01T12:00:00Z")!,
                value: 200,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-02-01T12:00:00Z")!,
                endDate: formatter.date(from: "2024-02-01T13:00:00Z")!,
                value: 0,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-02-01T13:00:00Z")!,
                endDate: formatter.date(from: "2024-02-01T14:00:00Z")!,
                value: 50,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-02-01T14:00:00Z")!,
                endDate: formatter.date(from: "2024-02-01T15:00:00Z")!,
                value: 90,
                unit: "steps"
            )
        ]
    )
    
    static let day31_30January2024 = [day31January2024, day30January2024]
    
    static let day30_29January2024 = [day30January2024, day29January2024]
    
    static let day31_30_29January2024 = [day31January2024, day30January2024, day29January2024]
    
    static let day01February_31_30_29January2024 = [day01February2024, day31January2024, day30January2024, day29January2024]
}

final class StepDataManagerFactoryTests2: XCTestCase {
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        let container = NSPersistentContainer(name: "")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        context = container.newBackgroundContext()
    }
    
    override func tearDown() {
        context = nil
        super.tearDown()
    }
    
    func testMergeCoreDataWithHealthKitDataWhenHealthKitIsEmpty() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData(StepPeriodTestData2.day31_30_29January2024, context: context)
        let healthKitData: [StepPeriod] = []
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        let mergedEntriesToHealthKit = StepDataManagerFactory.mapCoreDataToHealthKit(mergedEntries)
        let expectedEntries = StepPeriodTestData2.day31_30_29January2024
        
        XCTAssertEqual(mergedEntriesToHealthKit, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenCoreDataIsEmpty() {
        let coreDataEntries: [PeriodEntryMO] = []
        let healthKitData: [StepPeriod] = StepPeriodTestData2.day31_30_29January2024
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        let mergedEntriesToHealthKit = StepDataManagerFactory.mapCoreDataToHealthKit(mergedEntries)
        let expectedEntries = StepPeriodTestData2.day31_30_29January2024
        
        XCTAssertEqual(mergedEntriesToHealthKit, expectedEntries)
    }
    
    func testMergeCoreDataAndHealthKitData_WhenDaysDiffer_ShouldMatchExpectedResult() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData(StepPeriodTestData2.day30_29January2024, context: context)
        let healthKitData: [StepPeriod] = [StepPeriodTestData2.day31January2024]
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        let mergedEntriesToHealthKit = StepDataManagerFactory.mapCoreDataToHealthKit(mergedEntries)
        let expectedEntries = StepPeriodTestData2.day31_30_29January2024
        
        XCTAssertEqual(mergedEntriesToHealthKit, expectedEntries)
    }
    
    func testMergeCoreDataAndHealthKitData_WhenDaysDiffer_ShouldMatchExpectedResult2() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData([StepPeriodTestData2.day29January2024], context: context)
        let healthKitData: [StepPeriod] = StepPeriodTestData2.day31_30January2024
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        let mergedEntriesToHealthKit = StepDataManagerFactory.mapCoreDataToHealthKit(mergedEntries)
        let expectedEntries = StepPeriodTestData2.day31_30_29January2024
        
        XCTAssertEqual(mergedEntriesToHealthKit, expectedEntries)
    }
    
    func testMergeCoreDataAndHealthKitData_WhenOneDayMatchesWith5MinLessDifference_AndOneDayIsDifferent_ShouldMergeCorrectly() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData(StepPeriodTestData2.day31_30_29January2024, context: context)
        let healthKitData: [StepPeriod] = [StepPeriodTestData2.continueDay31January2024WithLess5min]
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        let mergedEntriesToHealthKit = StepDataManagerFactory.mapCoreDataToHealthKit(mergedEntries)
        let expectedEntries = StepPeriodTestData2.day31_30_29ContinueDay31January2024WithLess5min
        
        XCTAssertEqual(mergedEntriesToHealthKit, expectedEntries)
    }
    
    func testMergeCoreDataAndHealthKitData_WhenOneDayMatchesWith5MinLessDifference_AndOneDayIsDifferent_ShouldMergeCorrectly2() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData(StepPeriodTestData2.day31_30_29January2024, context: context)
        let healthKitData: [StepPeriod] = [StepPeriodTestData2.day01February2024, StepPeriodTestData2.continueDay31January2024WithLess5min]
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        let mergedEntriesToHealthKit = StepDataManagerFactory.mapCoreDataToHealthKit(mergedEntries)
        let expectedEntries = StepPeriodTestData2.day01February_31_30_29ContinueDay31January2024WithLess5min
        
        XCTAssertEqual(mergedEntriesToHealthKit, expectedEntries)
    }
    
    func testMergeCoreDataAndHealthKitData_WhenOneDayMatchesWith5MinMoreDifference_AndOneDayIsDifferent_ShouldMergeCorrectly() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData(StepPeriodTestData2.day31_30_29January2024, context: context)
        let healthKitData: [StepPeriod] = [StepPeriodTestData2.continueDay31January2024WithMore5min]
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        var mergedEntriesToHealthKit = StepDataManagerFactory.mapCoreDataToHealthKit(mergedEntries)
        let expectedEntries = StepPeriodTestData2.day31_30_29ContinueDay29January2024WithMore5min
        
        mergedEntriesToHealthKit[0].entries[5] = HealthData.ActivityEntry(
            id: expectedEntries[0].entries[5].id,
            startDate: mergedEntriesToHealthKit[0].entries[5].startDate,
            endDate: mergedEntriesToHealthKit[0].entries[5].endDate,
            value: mergedEntriesToHealthKit[0].entries[5].value,
            unit: mergedEntriesToHealthKit[0].entries[5].unit
        )
        
        XCTAssertEqual(mergedEntriesToHealthKit, expectedEntries)
    }
    
    func testMergeCoreDataAndHealthKitData_WhenOneDayMatchesWith5MinMoreDifference_AndOneDayIsDifferent_ShouldMergeCorrectly2() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData(StepPeriodTestData2.day31_30_29January2024, context: context)
        let healthKitData: [StepPeriod] = [StepPeriodTestData2.day01February2024, StepPeriodTestData2.continueDay31January2024WithMore5min]
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        var mergedEntriesToHealthKit = StepDataManagerFactory.mapCoreDataToHealthKit(mergedEntries)
        let expectedEntries = StepPeriodTestData2.day01February_31_30_29ContinueDay31January2024WithMore5min
        
        mergedEntriesToHealthKit[1].entries[5] = HealthData.ActivityEntry(
            id: expectedEntries[1].entries[5].id,
            startDate: mergedEntriesToHealthKit[1].entries[5].startDate,
            endDate: mergedEntriesToHealthKit[1].entries[5].endDate,
            value: mergedEntriesToHealthKit[1].entries[5].value,
            unit: mergedEntriesToHealthKit[1].entries[5].unit
        )
        
        XCTAssertEqual(mergedEntriesToHealthKit, expectedEntries)
    }
}

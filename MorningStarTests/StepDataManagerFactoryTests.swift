//
//  StepDataManagerFactoryTests.swift
//  MorningStarTests
//
//  Created by Guillaume Djaider Fornari on 30/01/2025.
//

import XCTest
import CoreData
@testable import MorningStar

private struct StepPeriodTestData {
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static let previousDayMorning = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                startDate: formatter.date(from: "2024-01-29T10:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T11:00:00Z")!,
                value: 100,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-29T11:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T12:00:00Z")!,
                value: 200,
                unit: "steps"
            )
        ]
    )
    
    static let previousDayNight = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440004")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440005")!,
                startDate: formatter.date(from: "2024-01-29T19:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T20:00:00Z")!,
                value: 150,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440010")!,
                startDate: formatter.date(from: "2024-01-29T20:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T21:00:00Z")!,
                value: 180,
                unit: "steps"
            )
        ]
    )
    
    static let previousDayMerged = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: previousDayMorning.entries + previousDayNight.entries
    )
    
    static let currentDayMorning = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440006")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440007")!,
                startDate: formatter.date(from: "2024-01-30T08:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T09:00:00Z")!,
                value: 90,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440008")!,
                startDate: formatter.date(from: "2024-01-30T09:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T10:00:00Z")!,
                value: 110,
                unit: "steps"
            )
        ]
    )
    
    static let currentDayNight = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440009")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440011")!,
                startDate: formatter.date(from: "2024-01-30T21:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T22:00:00Z")!,
                value: 180,
                unit: "steps"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440012")!,
                startDate: formatter.date(from: "2024-01-30T22:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T23:00:00Z")!,
                value: 130,
                unit: "steps"
            )
        ]
    )
    
    static let currentDayMerged = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440006")!,
        entries: currentDayMorning.entries + currentDayNight.entries
    )
    
    static let previousAndCurrentDayMerged = [
        currentDayMerged,
        previousDayMerged
    ]
    
    static let periodWithEmptyEntries = StepPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655441006")!,
        entries: []
    )
}

extension StepPeriodTestData {
    static let currentMorningTest = StepPeriod(
        id: UUID(uuidString: "E060DC65-D25E-4901-AD11-E5ADAE97FFCF")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "5EC5CD28-6574-4871-8ACB-96E9A1551480")!,
                startDate: formatter.date(from: "2025-02-13T23:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T00:00:00Z")!,
                value: 55.0,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "132BE58C-A708-4A4D-9B21-4A9EF2CCCE7B")!,
                startDate: formatter.date(from: "2025-02-14T00:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T01:00:00Z")!,
                value: 28.0,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "FA2C2AC1-C701-44A0-B543-E9863687A158")!,
                startDate: formatter.date(from: "2025-02-14T09:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T10:00:00Z")!,
                value: 48.0,
                unit: "count"
            )
        ]
    )
    
    static let currentAfterMorningTest = StepPeriod(
        id: UUID(uuidString: "F8D11D2C-9F11-4E33-B598-FC5F88DE3750")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "4AA4B3C0-8F11-41AB-BAC1-A2191A29D754")!,
                startDate: formatter.date(from: "2025-02-14T11:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T12:00:00Z")!,
                value: 48.34206850911718,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "E7ECB6F4-5CDF-4C10-9BE6-057CB012F34E")!,
                startDate: formatter.date(from: "2025-02-14T12:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T13:00:00Z")!,
                value: 308.6579314908828,
                unit: "count"
            )
        ]
    )
    
    static let currentMorningTestMerged = StepPeriod(
        id: UUID(uuidString: "E060DC65-D25E-4901-AD11-E5ADAE97FFCF")!,
        entries: currentMorningTest.entries + currentAfterMorningTest.entries
    )
}

extension StepPeriodTestData {
    static let period1 = StepPeriod(
        id: UUID(uuidString: "E4AB8BA3-627E-4F76-95EE-DEEC13705DD8")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "09ADD376-47F0-4371-A530-A6F3FD355BC2")!,
                startDate: formatter.date(from: "2025-02-13T23:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T00:00:00Z")!,
                value: 55.0,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "13DE233C-AB12-4CBA-B1EE-E2B8E9FAE7E0")!,
                startDate: formatter.date(from: "2025-02-14T00:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T01:00:00Z")!,
                value: 28.0,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "B94B675E-EB41-4881-87D3-8AD68BED20CE")!,
                startDate: formatter.date(from: "2025-02-14T09:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T10:00:00Z")!,
                value: 48.0,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "88017B62-55F7-460C-93CC-411ABBBD67D0")!,
                startDate: formatter.date(from: "2025-02-14T11:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T12:00:00Z")!,
                value: 48.34206850911718,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "AAE97E04-97EB-41F4-B995-EE020777B4A3")!,
                startDate: formatter.date(from: "2025-02-14T12:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T13:00:00Z")!,
                value: 308.6579314908828,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "5F91F140-1BC0-42EE-9690-4EA50715DB93")!,
                startDate: formatter.date(from: "2025-02-14T13:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T14:00:00Z")!,
                value: 101.0,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "5EC457D6-A121-4F0C-8394-FC71F46872B1")!,
                startDate: formatter.date(from: "2025-02-14T14:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T15:00:00Z")!,
                value: 14.0,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "779F2494-5AC7-4CFC-B9D3-79B169091C0B")!,
                startDate: formatter.date(from: "2025-02-14T15:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T16:00:00Z")!,
                value: 115.0,
                unit: "count"
            )
        ]
    )
    
    static let period2 = StepPeriod(
        id: UUID(uuidString: "43A6CF69-9487-4E5C-B758-ABE94D61CCDF")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "D477DD88-005B-4198-ADA9-53F73C203DC2")!,
                startDate: formatter.date(from: "2025-02-14T16:01:00Z")!,
                endDate: formatter.date(from: "2025-02-14T19:00:00Z")!,
                value: 340.2945384587494,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "53062BB3-BF95-4DDE-B15D-C642FE75C763")!,
                startDate: formatter.date(from: "2025-02-14T19:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T20:00:00Z")!,
                value: 831.7054615412507,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "29F2A169-2253-4A03-8CF0-B027A5E18B6B")!,
                startDate: formatter.date(from: "2025-02-14T20:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T21:00:00Z")!,
                value: 456.76946791707303,
                unit: "count"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "2BAE450A-4249-4115-A20F-37F0C38D92F8")!,
                startDate: formatter.date(from: "2025-02-14T21:00:00Z")!,
                endDate: formatter.date(from: "2025-02-14T22:00:00Z")!,
                value: 247.1638215526461,
                unit: "count"
            )
        ]
    )

    static let periodTestMerged = StepPeriod(
        id: UUID(uuidString: "E4AB8BA3-627E-4F76-95EE-DEEC13705DD8")!,
        entries: period1.entries + period2.entries
    )
}

final class StepDataManagerFactoryTests: XCTestCase {
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
    
    
    func testMapHealthKitToCoreDataWithValidData() {
        let inputHealthKitPeriods = [StepPeriodTestData.currentDayMerged]
        let coreDataEntries = StepDataManagerFactory.mapHealthKitToCoreData(inputHealthKitPeriods, context: context)
        let outputHealthKitPeriods = StepDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertEqual(inputHealthKitPeriods, outputHealthKitPeriods)
    }
    
    func testMapHealthKitToCoreDataWithMultipleEntries() {
        let inputHealthKitPeriods = StepPeriodTestData.previousAndCurrentDayMerged
        let coreDataEntries = StepDataManagerFactory.mapHealthKitToCoreData(inputHealthKitPeriods, context: context)
        let outputHealthKitPeriods = StepDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertEqual(inputHealthKitPeriods, outputHealthKitPeriods)
    }
    
    func testMapHealthKitToCoreDataWithEmptyData() {
        let healthKitData: [StepPeriod] = []
        let coreDataEntries = StepDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        XCTAssertTrue(coreDataEntries.isEmpty, "Mapping an empty HealthKit dataset should return an empty CoreData dataset")
    }
    
    func testMapHealthKitToCoreDataWithEmptyEntries() {
        let healthKitData = [StepPeriodTestData.periodWithEmptyEntries]
        let coreDataEntries = StepDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        XCTAssertTrue(coreDataEntries.isEmpty, "HealthKit period without entries should not be mapped")
    }
    
    func testMapCoreDataToHealthKitWithEmptyData() {
        let coreDataEntries: [PeriodEntryMO] = []
        let healthKitData = StepDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertTrue(healthKitData.isEmpty, "Mapping an empty CoreData dataset should return an empty HealthKit dataset")
    }
    
    func testMergeCoreDataWithHealthKitDataWhenHealthKitIsEmpty() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData(StepPeriodTestData.previousAndCurrentDayMerged, context: context)
        let healthKitData: [StepPeriod] = []
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        checkPeriodEntriesEqual(mergedEntries, coreDataEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenCoreDataIsEmpty() {
        let coreDataEntries: [PeriodEntryMO] = []
        let healthKitData: [StepPeriod] = StepPeriodTestData.previousAndCurrentDayMerged
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = StepDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenCoreDataAndHealthKitAreEmpty() {
        let coreDataEntries: [PeriodEntryMO] = []
        let healthKitData: [StepPeriod] = []
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        XCTAssertTrue(mergedEntries.isEmpty, "When both CoreData and HealthKit are empty, the result should be an empty array.")
    }
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreDifferent() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData([StepPeriodTestData.previousDayMerged], context: context)
        let healthKitData: [StepPeriod] = [StepPeriodTestData.currentDayMerged]
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = StepDataManagerFactory.mapHealthKitToCoreData(StepPeriodTestData.previousAndCurrentDayMerged, context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreTheSameDay() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData([StepPeriodTestData.previousDayMorning], context: context)
        let healthKitData: [StepPeriod] = [StepPeriodTestData.previousDayNight]
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = StepDataManagerFactory.mapHealthKitToCoreData([StepPeriodTestData.previousDayMerged], context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreTheSameDay2() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData([StepPeriodTestData.currentDayMorning], context: context)
        let healthKitData: [StepPeriod] = [StepPeriodTestData.currentDayNight]
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = StepDataManagerFactory.mapHealthKitToCoreData([StepPeriodTestData.currentDayMerged], context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreTheSameDay3() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData([StepPeriodTestData.currentMorningTest], context: context)
        let healthKitData: [StepPeriod] = [StepPeriodTestData.currentAfterMorningTest]
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = StepDataManagerFactory.mapHealthKitToCoreData([StepPeriodTestData.currentMorningTestMerged], context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreTheSameDay4() {
        let coreDataEntries: [PeriodEntryMO] = StepDataManagerFactory.mapHealthKitToCoreData([StepPeriodTestData.period1], context: context)
        let healthKitData: [StepPeriod] = [StepPeriodTestData.period2]
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = StepDataManagerFactory.mapHealthKitToCoreData([StepPeriodTestData.periodTestMerged], context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
//    func testMergeCoreDataWithHealthKitDataWithIdenticalPeriods() {
//        let coreDataEntries = StepDataManagerFactory.mapHealthKitToCoreData([StepPeriodTestData.currentDayMerged], context: context)
//        let healthKitData = [StepPeriodTestData.currentDayMerged]
//        
//        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
//        
//        checkPeriodEntriesEqual(mergedEntries, coreDataEntries)
//    }
}

extension StepDataManagerFactoryTests {
    func checkPeriodEntriesEqual(
        _ entries: [PeriodEntryMO],
        _ expectedEntries: [PeriodEntryMO]
    ) {
        XCTAssertEqual(entries.count, expectedEntries.count, "The number of merged entries should match the expected entries count.")
        
        for (index, mergedEntry) in entries.enumerated() {
            let expectedEntry = expectedEntries[index]
            
            XCTAssertEqual(mergedEntry.id, expectedEntry.id,"Mismatch in id at index \(index)")
            XCTAssertEqual(mergedEntry.startDate, expectedEntry.startDate, "Mismatch in startDate at index \(index)")
            XCTAssertEqual(mergedEntry.endDate, expectedEntry.endDate, "Mismatch in endDate at index \(index)")
            
            if index > 0,
               let currentStartDate = mergedEntry.startDate,
               let previousStartDate = entries[index - 1].startDate {
                XCTAssertTrue(currentStartDate <= previousStartDate, "Periods should be sorted chronologically at index \(index)")
            }
            
            let mergedSteps = mergedEntry.stepEntries?.compactMap { $0 as? StepEntryMO } ?? []
            let expectedSteps = expectedEntry.stepEntries?.compactMap { $0 as? StepEntryMO } ?? []
            
            XCTAssertEqual(mergedSteps.count, expectedSteps.count, "Step entries count mismatch for entry at index \(index)")
            
            for (stepIndex, mergedStep) in mergedSteps.enumerated() {
                let expectedStep = expectedSteps[stepIndex]
                
                XCTAssertEqual(mergedStep.id, expectedStep.id, "Step entry ID mismatch at index \(stepIndex) in period \(index)")
                XCTAssertEqual(mergedStep.startDate, expectedStep.startDate, "Step entry startDate mismatch at index \(stepIndex) in period \(index)")
                XCTAssertEqual(mergedStep.endDate, expectedStep.endDate, "Step entry endDate mismatch at index \(stepIndex) in period \(index)")
                XCTAssertEqual(mergedStep.value, expectedStep.value, "Step entry value mismatch at index \(stepIndex) in period \(index)")
                XCTAssertEqual(mergedStep.unit, expectedStep.unit, "Step entry unit mismatch at index \(stepIndex) in period \(index)")
                
                if let stepStartDate = mergedStep.startDate,
                   let stepEndDate = mergedStep.endDate,
                   let periodStartDate = mergedEntry.startDate,
                   let periodEndDate = mergedEntry.endDate {
                    XCTAssertTrue(stepStartDate >= periodStartDate && stepEndDate <= periodEndDate, "Step entry at index \(stepIndex) is not within its period's range at index \(index)")
                }
            }
            
            let sortedMergedSteps = mergedSteps.sorted {
                ($0.startDate ?? Date.distantPast) < ($1.startDate ?? Date.distantPast)
            }
            XCTAssertEqual(mergedSteps, sortedMergedSteps, "Step entries should be sorted by startDate at index \(index)")
        }
    }
}

//
//  StepDataManagerFactoryTests.swift
//  MorningStarTests
//
//  Created by Guillaume Djaider Fornari on 30/01/2025.
//

import XCTest
import CoreData
@testable import MorningStar

private enum StepPeriodTestData {
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
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
        
        XCTAssertEqual(mergedEntries, coreDataEntries, "When HealthKit data is empty, the CoreData entries should remain unchanged.")
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
    
    func testMergeCoreDataWithHealthKitDataWithIdenticalPeriods() {
        let coreDataEntries = StepDataManagerFactory.mapHealthKitToCoreData([StepPeriodTestData.currentDayMerged], context: context)
        let healthKitData = [StepPeriodTestData.currentDayMerged]
        
        let mergedEntries = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        XCTAssertEqual(mergedEntries, coreDataEntries, "Merging identical data should not create duplicates.")
    }
    

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

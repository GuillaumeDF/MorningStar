//
//  WeightDataManagerFactoryTests.swift
//  MorningStarTests
//
//  Created by Guillaume Djaider Fornari on 31/01/2025.
//

import XCTest
import CoreData
@testable import MorningStar

private struct WeightPeriodTestData {
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static let previousEarlyWeek = WeightPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: [
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                startDate: formatter.date(from: "2025-01-28T21:00:00Z")!,
                endDate: formatter.date(from: "2025-01-28T21:30:00Z")!,
                value: 75,
                unit: "kg"
            ),
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2025-01-29T22:00:00Z")!,
                endDate: formatter.date(from: "2025-01-29T22:30:30Z")!,
                value: 80,
                unit: "kg"
            )
        ]
    )
    
    static let previousLateWeek = WeightPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440004")!,
        entries: [
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440005")!,
                startDate: formatter.date(from: "2025-01-31T00:00:00Z")!,
                endDate: formatter.date(from: "2025-01-31T02:00:00Z")!,
                value: 85,
                unit: "kg"
            ),
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440010")!,
                startDate: formatter.date(from: "2025-02-01T03:00:00Z")!,
                endDate: formatter.date(from: "2025-02-01T05:30:00Z")!,
                value: 70,
                unit: "kg"
            )
        ]
    )
    
    static let previousWeekMerged = WeightPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: previousEarlyWeek.entries + previousLateWeek.entries
    )
    
    static let currentEarlyWeek = WeightPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440009")!,
        entries: [
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440011")!,
                startDate: formatter.date(from: "2025-02-03T03:00:00Z")!,
                endDate: formatter.date(from: "2025-02-03T05:30:00Z")!,
                value: 150,
                unit: "kg"
            ),
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440012")!,
                startDate: formatter.date(from: "2025-02-04T03:00:00Z")!,
                endDate: formatter.date(from: "2025-02-04T05:30:00Z")!,
                value: 150,
                unit: "kg"
            )
        ]
    )
    
    static let currentLateWeek = WeightPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440006")!,
        entries: [
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440007")!,
                startDate: formatter.date(from: "2025-02-07T03:00:00Z")!,
                endDate: formatter.date(from: "2025-02-07T05:30:00Z")!,
                value: 82,
                unit: "kg"
            ),
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440008")!,
                startDate: formatter.date(from: "2025-02-08T03:00:00Z")!,
                endDate: formatter.date(from: "2025-02-08T05:30:00Z")!,
                value: 86,
                unit: "kg"
            )
        ]
    )
    
    static let currentWeekMerged = [
        currentLateWeek,
        currentEarlyWeek
    ]
    
    static let previousAndCurrentWeek = currentWeekMerged + [previousWeekMerged]
    
    static let periodWithEmptyEntries = WeightPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655441006")!,
        entries: []
    )
}

final class WeightDataManagerFactoryTests: XCTestCase {
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
        let inputHealthKitPeriods = WeightPeriodTestData.currentWeekMerged
        let coreDataEntries = WeightDataManagerFactory.mapHealthKitToCoreData(inputHealthKitPeriods, context: context)
        let outputHealthKitPeriods = WeightDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertEqual(inputHealthKitPeriods, outputHealthKitPeriods)
    }
    
    func testMapHealthKitToCoreDataWithMultipleEntries() {
        let inputHealthKitPeriods = WeightPeriodTestData.previousAndCurrentWeek
        let coreDataEntries = WeightDataManagerFactory.mapHealthKitToCoreData(inputHealthKitPeriods, context: context)
        let outputHealthKitPeriods = WeightDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertEqual(inputHealthKitPeriods, outputHealthKitPeriods)
    }
    
    func testMapHealthKitToCoreDataWithEmptyData() {
        let healthKitData: [WeightPeriod] = []
        let coreDataEntries = WeightDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        XCTAssertTrue(coreDataEntries.isEmpty, "Mapping an empty HealthKit dataset should return an empty CoreData dataset")
    }
    
    func testMapHealthKitToCoreDataWithEmptyEntries() {
        let healthKitData = [WeightPeriodTestData.periodWithEmptyEntries]
        let coreDataEntries = WeightDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        XCTAssertTrue(coreDataEntries.isEmpty, "HealthKit period without entries should not be mapped")
    }
    
    func testMapCoreDataToHealthKitWithEmptyData() {
        let coreDataEntries: [PeriodEntryMO] = []
        let healthKitData = WeightDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertTrue(healthKitData.isEmpty, "Mapping an empty CoreData dataset should return an empty HealthKit dataset")
    }
    
    func testMergeCoreDataWithHealthKitDataWhenHealthKitIsEmpty() {
        let coreDataEntries: [PeriodEntryMO] = WeightDataManagerFactory.mapHealthKitToCoreData(WeightPeriodTestData.previousAndCurrentWeek, context: context)
        let healthKitData: [WeightPeriod] = []
        let mergedEntries = WeightDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        checkPeriodEntriesEqual(mergedEntries, coreDataEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenCoreDataIsEmpty() {
        let coreDataEntries: [PeriodEntryMO] = []
        let healthKitData: [WeightPeriod] = WeightPeriodTestData.previousAndCurrentWeek
        
        let mergedEntries = WeightDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = WeightDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenCoreDataAndHealthKitAreEmpty() {
        let coreDataEntries: [PeriodEntryMO] = []
        let healthKitData: [WeightPeriod] = []
        
        let mergedEntries = WeightDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        XCTAssertTrue(mergedEntries.isEmpty, "When both CoreData and HealthKit are empty, the result should be an empty array.")
    }
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreDifferent() {
        let coreDataEntries: [PeriodEntryMO] = WeightDataManagerFactory.mapHealthKitToCoreData([WeightPeriodTestData.previousWeekMerged], context: context)
        let healthKitData: [WeightPeriod] = WeightPeriodTestData.currentWeekMerged
        
        let mergedEntries = WeightDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = WeightDataManagerFactory.mapHealthKitToCoreData(WeightPeriodTestData.previousAndCurrentWeek, context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreTheSameWeek() {
        let coreDataEntries: [PeriodEntryMO] = WeightDataManagerFactory.mapHealthKitToCoreData([WeightPeriodTestData.previousEarlyWeek], context: context)
        let healthKitData: [WeightPeriod] = [WeightPeriodTestData.previousLateWeek]
        
        let mergedEntries = WeightDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = WeightDataManagerFactory.mapHealthKitToCoreData([WeightPeriodTestData.previousWeekMerged], context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
}

extension WeightDataManagerFactoryTests {
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
            
            let mergedSteps = mergedEntry.weightEntries?.compactMap { $0 as? StepEntryMO } ?? []
            let expectedSteps = expectedEntry.weightEntries?.compactMap { $0 as? StepEntryMO } ?? []
            
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

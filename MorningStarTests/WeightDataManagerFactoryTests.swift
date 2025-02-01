//
//  WeightDataManagerFactoryTests.swift
//  MorningStarTests
//
//  Created by Guillaume Djaider Fornari on 31/01/2025.
//

import XCTest
import CoreData
@testable import MorningStar

private enum WeightPeriodTestData {
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static let previousWeekPeriod = WeightPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440004")!,
        entries: [
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440005")!,
                startDate: formatter.date(from: "2024-01-29T19:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T20:00:00Z")!,
                value: 150,
                unit: "kg"
            )
        ]
    )
    
    static let currentEarlyWeekPeriod = WeightPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: [
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                startDate: formatter.date(from: "2025-01-28T10:00:00Z")!,
                endDate: formatter.date(from: "2025-01-28T11:00:00Z")!,
                value: 100,
                unit: "kg"
            ),
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2025-01-29T11:00:00Z")!,
                endDate: formatter.date(from: "2025-01-29T12:00:00Z")!,
                value: 200,
                unit: "kg"
            )
        ]
    )
    
        static let currentWeekPeriod = WeightPeriod(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440006")!,
            entries: [
                HealthData.WeightEntry(
                    id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440007")!,
                    startDate: formatter.date(from: "2025-01-30T11:00:00Z")!,
                    endDate: formatter.date(from: "2025-01-30T12:00:00Z")!,
                    value: 120,
                    unit: "kcal"
                )
            ]
        )
    
    static let currentAndEarlyWeekMergedPeriod = WeightPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: [
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                startDate: formatter.date(from: "2025-01-28T10:00:00Z")!,
                endDate: formatter.date(from: "2025-01-28T11:00:00Z")!,
                value: 100,
                unit: "kg"
            ),
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2025-01-29T11:00:00Z")!,
                endDate: formatter.date(from: "2025-01-29T12:00:00Z")!,
                value: 200,
                unit: "kg"
            ),
            HealthData.WeightEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440007")!,
                startDate: formatter.date(from: "2025-01-30T11:00:00Z")!,
                endDate: formatter.date(from: "2025-01-30T12:00:00Z")!,
                value: 120,
                unit: "kcal"
            )
        ]
    )
    
    static let emptyPeriod = WeightPeriod(
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
        let healthKitData = [WeightPeriodTestData.currentAndEarlyWeekMergedPeriod]
        let coreDataEntries = WeightDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        let retrievedHealthKitData = WeightDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertEqual(healthKitData, retrievedHealthKitData)
    }
    
    func testMapHealthKitToCoreDataWithEmptyData() {
        let healthKitData: [WeightPeriod] = []
        let coreDataEntries = WeightDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        XCTAssertTrue(coreDataEntries.isEmpty, "Mapping an empty HealthKit dataset should return an empty CoreData dataset")
    }
    
    func testMapHealthKitToCoreDataWithInvalidData() {
        let healthKitData = [WeightPeriodTestData.emptyPeriod]
        let coreDataEntries = WeightDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        XCTAssertTrue(coreDataEntries.isEmpty, "HealthKit period without entries should not be mapped")
    }
    
    func testMapCoreDataToHealthKitWithEmptyData() {
        let coreDataEntries: [PeriodEntryMO] = []
        let healthKitData = WeightDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertTrue(healthKitData.isEmpty, "Mapping an empty CoreData dataset should return an empty HealthKit dataset")
    }
    
    func testMergeCoreDataWithHealthKitDataWhenHealthKitIsEmpty() {
        let coreDataEntries: [PeriodEntryMO] = WeightDataManagerFactory.mapHealthKitToCoreData([WeightPeriodTestData.currentAndEarlyWeekMergedPeriod], context: context)
        let healthKitData: [WeightPeriod] = []
        let mergedEntries = WeightDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        XCTAssertEqual(mergedEntries, coreDataEntries, "When HealthKit data is empty, the CoreData entries should remain unchanged.")
    }
    
    func testMergeCoreDataWithHealthKitDataWhenCoreDataIsEmpty() {
        let coreDataEntries: [PeriodEntryMO] = []
        let healthKitData: [WeightPeriod] = [WeightPeriodTestData.previousWeekPeriod]
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
    
    func testMergeCoreDataWithHealthKitDataWhenWeeksAreDifferent() {
        let coreDataEntries: [PeriodEntryMO] = WeightDataManagerFactory.mapHealthKitToCoreData([WeightPeriodTestData.previousWeekPeriod], context: context)
        let healthKitData: [WeightPeriod] = [WeightPeriodTestData.currentWeekPeriod]
        
        let mergedEntries = WeightDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = WeightDataManagerFactory.mapHealthKitToCoreData([WeightPeriodTestData.currentWeekPeriod, WeightPeriodTestData.previousWeekPeriod], context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreTheSameWeek() {
        let coreDataEntries: [PeriodEntryMO] = WeightDataManagerFactory.mapHealthKitToCoreData([WeightPeriodTestData.currentEarlyWeekPeriod], context: context)
        let healthKitData: [WeightPeriod] = [WeightPeriodTestData.currentWeekPeriod]
        
        let mergedEntries = WeightDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = WeightDataManagerFactory.mapHealthKitToCoreData([WeightPeriodTestData.currentAndEarlyWeekMergedPeriod], context: context)
        
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

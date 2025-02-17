//
//  CalorieDataManagerFactoryTests.swift
//  MorningStarTests
//
//  Created by Guillaume Djaider Fornari on 31/01/2025.
//

import XCTest
import CoreData
@testable import MorningStar

private struct CaloriePeriodTestData {
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static let previousDayMorning = CaloriesPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                startDate: formatter.date(from: "2024-01-29T10:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T11:00:00Z")!,
                value: 100,
                unit: "kcal"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                startDate: formatter.date(from: "2024-01-29T11:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T12:00:00Z")!,
                value: 200,
                unit: "kcal"
            )
        ]
    )
    
    static let previousDayNight = CaloriesPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440004")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440005")!,
                startDate: formatter.date(from: "2024-01-29T19:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T20:00:00Z")!,
                value: 150,
                unit: "kcal"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440010")!,
                startDate: formatter.date(from: "2024-01-29T20:00:00Z")!,
                endDate: formatter.date(from: "2024-01-29T21:00:00Z")!,
                value: 180,
                unit: "kcal"
            )
        ]
    )
    
    static let previousDayMerged = CaloriesPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
        entries: previousDayMorning.entries + previousDayNight.entries
    )
    
    static let currentDayMorning = CaloriesPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440006")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440007")!,
                startDate: formatter.date(from: "2024-01-30T08:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T09:00:00Z")!,
                value: 90,
                unit: "kcal"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440008")!,
                startDate: formatter.date(from: "2024-01-30T09:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T10:00:00Z")!,
                value: 110,
                unit: "kcal"
            )
        ]
    )
    
    static let currentDayNight = CaloriesPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440009")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440011")!,
                startDate: formatter.date(from: "2024-01-30T21:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T22:00:00Z")!,
                value: 180,
                unit: "kcal"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440012")!,
                startDate: formatter.date(from: "2024-01-30T22:00:00Z")!,
                endDate: formatter.date(from: "2024-01-30T23:00:00Z")!,
                value: 130,
                unit: "kcal"
            )
        ]
    )
    
    static let currentDayMerged = CaloriesPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440006")!,
        entries: currentDayMorning.entries + currentDayNight.entries
    )
    
    static let previousAndCurrentDayMerged = [
        currentDayMerged,
        previousDayMerged
    ]
    
    static let periodWithEmptyEntries = CaloriesPeriod(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655441006")!,
        entries: []
    )
}

extension CaloriePeriodTestData {
    static let period1 = CaloriesPeriod(
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
    
    static let period2 = CaloriesPeriod(
        id: UUID(uuidString: "43A6CF69-9487-4E5C-B758-ABE94D61CCDF")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "D477DD88-005B-4198-ADA9-53F73C203DC2")!,
                startDate: formatter.date(from: "2025-02-14T18:00:00Z")!,
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

    static let periodTestMerged = CaloriesPeriod(
        id: UUID(uuidString: "E4AB8BA3-627E-4F76-95EE-DEEC13705DD8")!,
        entries: period1.entries + period2.entries
    )
}

extension CaloriePeriodTestData {
    static let firstCaloriesPeriod = CaloriesPeriod(
        id: UUID(uuidString: "02646C3F-E25B-4720-8EA6-423DA859FDAA")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "5B5D1877-0709-4AA6-BDDD-FCD4EFD493E2")!,
                startDate: formatter.date(from: "2025-02-14T23:00:00Z")!,
                endDate: formatter.date(from: "2025-02-15T00:00:00Z")!,
                value: 18.195,
                unit: "kcal"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "3FA6542E-3947-447A-989C-0A1E93CD0690")!,
                startDate: formatter.date(from: "2025-02-15T00:00:00Z")!,
                endDate: formatter.date(from: "2025-02-15T01:00:00Z")!,
                value: 16.469,
                unit: "kcal"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "BB47C88C-7E25-4B4B-BA82-97EBDA413AD3")!,
                startDate: formatter.date(from: "2025-02-15T01:00:00Z")!,
                endDate: formatter.date(from: "2025-02-15T02:00:00Z")!,
                value: 13.857047159320539,
                unit: "kcal"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "D3BA9453-CAA9-4250-A5B7-32F4D70E38E4")!,
                startDate: formatter.date(from: "2025-02-15T02:00:00Z")!,
                endDate: formatter.date(from: "2025-02-15T03:00:00Z")!,
                value: 32.92195284067946,
                unit: "kcal"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "176ACFE9-17C7-4AD5-90FA-6F61CEC269FD")!,
                startDate: formatter.date(from: "2025-02-15T10:00:00Z")!,
                endDate: formatter.date(from: "2025-02-15T11:00:00Z")!,
                value: 9.265874652758546,
                unit: "kcal"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "EF6BC764-3699-41C8-82E5-818850F0F9CB")!,
                startDate: formatter.date(from: "2025-02-15T11:00:00Z")!,
                endDate: formatter.date(from: "2025-02-15T12:00:00Z")!,
                value: 12.017125347241457,
                unit: "kcal"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "7C100533-B285-4CB4-9DEB-C74107B1E09B")!,
                startDate: formatter.date(from: "2025-02-15T12:00:00Z")!,
                endDate: formatter.date(from: "2025-02-15T13:00:00Z")!,
                value: 32.479,
                unit: "kcal"
            ),
            HealthData.ActivityEntry(
                id: UUID(uuidString: "3B56C80E-8A96-411B-B367-CEFF4FD36BF6")!,
                startDate: formatter.date(from: "2025-02-15T13:00:00Z")!,
                endDate: formatter.date(from: "2025-02-15T14:00:00Z")!,
                value: 3.646,
                unit: "kcal"
            )
        ]
    )
    
    static let secondCaloriesPeriod = CaloriesPeriod(
        id: UUID(uuidString: "984642E9-3ABF-4758-8E46-3A07F01A3433")!,
        entries: [
            HealthData.ActivityEntry(
                id: UUID(uuidString: "AAC5E3AB-C01C-4F21-9F05-142EE9FF80FC")!,
                startDate: formatter.date(from: "2025-02-15T15:00:00Z")!,
                endDate: formatter.date(from: "2025-02-15T16:00:00Z")!,
                value: 3.159,
                unit: "kcal"
            )
        ]
    )

    // Array containing both CaloriesPeriods
    static let caloriesPeriod = CaloriesPeriod(
        id: UUID(uuidString: "02646C3F-E25B-4720-8EA6-423DA859FDAA")!,
        entries: firstCaloriesPeriod.entries + secondCaloriesPeriod.entries
    )
}

final class CalorieDataManagerFactoryTests: XCTestCase {
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
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreTheSameDay4() {
        let coreDataEntries: [PeriodEntryMO] = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData([CaloriePeriodTestData.period1], context: context)
        let healthKitData: [StepPeriod] = [CaloriePeriodTestData.period2]
        
        let mergedEntries = CalorieBurnedDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData([CaloriePeriodTestData.periodTestMerged], context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreTheSameDay5() {
        let coreDataEntries: [PeriodEntryMO] = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData([CaloriePeriodTestData.firstCaloriesPeriod], context: context)
        let healthKitData: [StepPeriod] = [CaloriePeriodTestData.secondCaloriesPeriod]
        
        let mergedEntries = CalorieBurnedDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData([CaloriePeriodTestData.caloriesPeriod], context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    
    func testMapHealthKitToCoreDataWithValidData() {
        let inputHealthKitPeriods = [CaloriePeriodTestData.currentDayMerged]
        let coreDataEntries = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData(inputHealthKitPeriods, context: context)
        let outputHealthKitPeriods = CalorieBurnedDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertEqual(inputHealthKitPeriods, outputHealthKitPeriods)
    }
    
    func testMapHealthKitToCoreDataWithMultipleEntries() {
        let inputHealthKitPeriods = CaloriePeriodTestData.previousAndCurrentDayMerged
        let coreDataEntries = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData(inputHealthKitPeriods, context: context)
        let outputHealthKitPeriods = CalorieBurnedDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertEqual(inputHealthKitPeriods, outputHealthKitPeriods)
    }
    
    func testMapHealthKitToCoreDataWithEmptyData() {
        let healthKitData: [CaloriesPeriod] = []
        let coreDataEntries = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        XCTAssertTrue(coreDataEntries.isEmpty, "Mapping an empty HealthKit dataset should return an empty CoreData dataset")
    }
    
    func testMapHealthKitToCoreDataWithEmptyEntries() {
        let healthKitData = [CaloriePeriodTestData.periodWithEmptyEntries]
        let coreDataEntries = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        XCTAssertTrue(coreDataEntries.isEmpty, "HealthKit period without entries should not be mapped")
    }
    
    func testMapCoreDataToHealthKitWithEmptyData() {
        let coreDataEntries: [PeriodEntryMO] = []
        let healthKitData = CalorieBurnedDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertTrue(healthKitData.isEmpty, "Mapping an empty CoreData dataset should return an empty HealthKit dataset")
    }
    
    func testMergeCoreDataWithHealthKitDataWhenHealthKitIsEmpty() {
        let coreDataEntries: [PeriodEntryMO] = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData(CaloriePeriodTestData.previousAndCurrentDayMerged, context: context)
        let healthKitData: [CaloriesPeriod] = []
        let mergedEntries = CalorieBurnedDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        checkPeriodEntriesEqual(mergedEntries, coreDataEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenCoreDataIsEmpty() {
        let coreDataEntries: [PeriodEntryMO] = []
        let healthKitData: [CaloriesPeriod] = CaloriePeriodTestData.previousAndCurrentDayMerged
        
        let mergedEntries = CalorieBurnedDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenCoreDataAndHealthKitAreEmpty() {
        let coreDataEntries: [PeriodEntryMO] = []
        let healthKitData: [CaloriesPeriod] = []
        
        let mergedEntries = CalorieBurnedDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        XCTAssertTrue(mergedEntries.isEmpty, "When both CoreData and HealthKit are empty, the result should be an empty array.")
    }
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreDifferent() {
        let coreDataEntries: [PeriodEntryMO] = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData([CaloriePeriodTestData.previousDayMerged], context: context)
        let healthKitData: [CaloriesPeriod] = [CaloriePeriodTestData.currentDayMerged]
        
        let mergedEntries = CalorieBurnedDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData(CaloriePeriodTestData.previousAndCurrentDayMerged, context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreTheSameDay() {
        let coreDataEntries: [PeriodEntryMO] = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData([CaloriePeriodTestData.previousDayMorning], context: context)
        let healthKitData: [CaloriesPeriod] = [CaloriePeriodTestData.previousDayNight]
        
        let mergedEntries = CalorieBurnedDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData([CaloriePeriodTestData.previousDayMerged], context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
//    func testMergeCoreDataWithHealthKitDataWithIdenticalPeriods() {
//        let coreDataEntries = CalorieBurnedDataManagerFactory.mapHealthKitToCoreData([CaloriePeriodTestData.currentDayMerged], context: context)
//        let healthKitData = [CaloriePeriodTestData.currentDayMerged]
//        
//        let mergedEntries = CalorieBurnedDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
//        
//        checkPeriodEntriesEqual(mergedEntries, coreDataEntries)
//    }
}

extension CalorieDataManagerFactoryTests {
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
            
            let mergedSteps = mergedEntry.calorieEntries?.compactMap { $0 as? StepEntryMO } ?? []
            let expectedSteps = expectedEntry.calorieEntries?.compactMap { $0 as? StepEntryMO } ?? []
            
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

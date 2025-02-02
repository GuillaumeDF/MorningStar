//
//  WorkoutDataManagerFactoryTests.swift
//  MorningStarTests
//
//  Created by Guillaume Djaider Fornari on 01/02/2025.
//

import XCTest
import CoreData
@testable import MorningStar

private enum WorkoutPeriodTestData {
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static let previousWeekPeriod = WeeklyWorkouts(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440004")!,
        dailyWorkouts: [
            DailyWorkouts(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440010")!,
                workouts: [
                    HealthData.Workout(
                        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440011")!,
                        phaseEntries: [
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440012")!,
                                startDate: formatter.date(from: "2025-01-20T08:00:00Z")!,
                                endDate: formatter.date(from: "2025-01-20T08:10:00Z")!,
                                value: .low,
                                averageHeartRate: 110,
                                caloriesBurned: 45
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440013")!,
                                startDate: formatter.date(from: "2025-01-20T08:10:00Z")!,
                                endDate: formatter.date(from: "2025-01-20T08:45:00Z")!,
                                value: .moderate,
                                averageHeartRate: 145,
                                caloriesBurned: 250
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440014")!,
                                startDate: formatter.date(from: "2025-01-20T08:45:00Z")!,
                                endDate: formatter.date(from: "2025-01-20T09:00:00Z")!,
                                value: .low,
                                averageHeartRate: 120,
                                caloriesBurned: 55
                            )
                        ]
                    )
                ]
            ),
            DailyWorkouts(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440013")!,
                workouts: [
                    HealthData.Workout(
                        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440014")!,
                        phaseEntries: [
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440015")!,
                                startDate: formatter.date(from: "2025-01-22T17:30:00Z")!,
                                endDate: formatter.date(from: "2025-01-22T17:40:00Z")!,
                                value: .moderate,
                                averageHeartRate: 135,
                                caloriesBurned: 70
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440016")!,
                                startDate: formatter.date(from: "2025-01-22T17:40:00Z")!,
                                endDate: formatter.date(from: "2025-01-22T18:20:00Z")!,
                                value: .high,
                                averageHeartRate: 165,
                                caloriesBurned: 320
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440017")!,
                                startDate: formatter.date(from: "2025-01-22T18:20:00Z")!,
                                endDate: formatter.date(from: "2025-01-22T18:30:00Z")!,
                                value: .moderate,
                                averageHeartRate: 140,
                                caloriesBurned: 60
                            )
                        ]
                    )
                ]
            )
        ]
    )

    // Début de la semaine courante
    static let currentEarlyWeekPeriod = WeeklyWorkouts(
        id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440005")!,
        dailyWorkouts: [
            DailyWorkouts(
                id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440020")!,
                workouts: [
                    HealthData.Workout(
                        id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440021")!,
                        phaseEntries: [
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440022")!,
                                startDate: formatter.date(from: "2025-01-28T06:30:00Z")!,
                                endDate: formatter.date(from: "2025-01-28T06:45:00Z")!,
                                value: .low,
                                averageHeartRate: 120,
                                caloriesBurned: 80
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440023")!,
                                startDate: formatter.date(from: "2025-01-28T06:45:00Z")!,
                                endDate: formatter.date(from: "2025-01-28T07:15:00Z")!,
                                value: .moderate,
                                averageHeartRate: 148,
                                caloriesBurned: 240
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440024")!,
                                startDate: formatter.date(from: "2025-01-28T07:15:00Z")!,
                                endDate: formatter.date(from: "2025-01-28T07:30:00Z")!,
                                value: .low,
                                averageHeartRate: 125,
                                caloriesBurned: 60
                            )
                        ]
                    )
                ]
            )
        ]
    )

    // Semaine courante complète
    static let currentWeekPeriod = WeeklyWorkouts(
        id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440006")!,
        dailyWorkouts: [
            DailyWorkouts(
                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440030")!,
                workouts: [
                    HealthData.Workout(
                        id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440031")!,
                        phaseEntries: [
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440032")!,
                                startDate: formatter.date(from: "2025-01-29T06:30:00Z")!,
                                endDate: formatter.date(from: "2025-01-29T06:45:00Z")!,
                                value: .low,
                                averageHeartRate: 120,
                                caloriesBurned: 80
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440033")!,
                                startDate: formatter.date(from: "2025-01-29T06:45:00Z")!,
                                endDate: formatter.date(from: "2025-01-29T07:15:00Z")!,
                                value: .moderate,
                                averageHeartRate: 148,
                                caloriesBurned: 240
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440034")!,
                                startDate: formatter.date(from: "2025-01-29T07:15:00Z")!,
                                endDate: formatter.date(from: "2025-01-29T7:30:00Z")!,
                                value: .low,
                                averageHeartRate: 125,
                                caloriesBurned: 60
                            )
                        ]
                    )
                ]
            ),
            DailyWorkouts(
                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440033")!,
                workouts: [
                    HealthData.Workout(
                        id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440034")!,
                        phaseEntries: [
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440035")!,
                                startDate: formatter.date(from: "2025-01-30T07:00:00Z")!,
                                endDate: formatter.date(from: "2025-01-30T07:15:00Z")!,
                                value: .moderate,
                                averageHeartRate: 140,
                                caloriesBurned: 90
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440036")!,
                                startDate: formatter.date(from: "2025-01-30T07:15:00Z")!,
                                endDate: formatter.date(from: "2025-01-30T08:00:00Z")!,
                                value: .veryHigh,
                                averageHeartRate: 172,
                                caloriesBurned: 380
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440037")!,
                                startDate: formatter.date(from: "2025-01-30T08:00:00Z")!,
                                endDate: formatter.date(from: "2025-01-30T08:15:00Z")!,
                                value: .moderate,
                                averageHeartRate: 145,
                                caloriesBurned: 50
                            )
                        ]
                    )
                ]
            )
        ]
    )

    // Fusion du début de semaine et de la semaine courante
    static let currentAndEarlyWeekMergedPeriod = WeeklyWorkouts(
        id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440005")!,
        dailyWorkouts: [
            DailyWorkouts(
                id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440020")!,
                workouts: [
                    HealthData.Workout(
                        id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440021")!,
                        phaseEntries: [
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440022")!,
                                startDate: formatter.date(from: "2025-01-28T06:30:00Z")!,
                                endDate: formatter.date(from: "2025-01-28T06:45:00Z")!,
                                value: .low,
                                averageHeartRate: 120,
                                caloriesBurned: 80
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440023")!,
                                startDate: formatter.date(from: "2025-01-28T06:45:00Z")!,
                                endDate: formatter.date(from: "2025-01-28T07:15:00Z")!,
                                value: .moderate,
                                averageHeartRate: 148,
                                caloriesBurned: 240
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440024")!,
                                startDate: formatter.date(from: "2025-01-28T07:15:00Z")!,
                                endDate: formatter.date(from: "2025-01-28T07:30:00Z")!,
                                value: .low,
                                averageHeartRate: 125,
                                caloriesBurned: 60
                            )
                        ]
                    )
                ]
            ),
            DailyWorkouts(
                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440030")!,
                workouts: [
                    HealthData.Workout(
                        id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440031")!,
                        phaseEntries: [
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440032")!,
                                startDate: formatter.date(from: "2025-01-29T06:30:00Z")!,
                                endDate: formatter.date(from: "2025-01-29T06:45:00Z")!,
                                value: .low,
                                averageHeartRate: 120,
                                caloriesBurned: 80
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440033")!,
                                startDate: formatter.date(from: "2025-01-29T06:45:00Z")!,
                                endDate: formatter.date(from: "2025-01-29T07:15:00Z")!,
                                value: .moderate,
                                averageHeartRate: 148,
                                caloriesBurned: 240
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440034")!,
                                startDate: formatter.date(from: "2025-01-29T07:15:00Z")!,
                                endDate: formatter.date(from: "2025-01-29T7:30:00Z")!,
                                value: .low,
                                averageHeartRate: 125,
                                caloriesBurned: 60
                            )
                        ]
                    )
                ]
            ),
            DailyWorkouts(
                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440033")!,
                workouts: [
                    HealthData.Workout(
                        id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440034")!,
                        phaseEntries: [
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440035")!,
                                startDate: formatter.date(from: "2025-01-30T07:00:00Z")!,
                                endDate: formatter.date(from: "2025-01-30T07:15:00Z")!,
                                value: .moderate,
                                averageHeartRate: 140,
                                caloriesBurned: 90
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440036")!,
                                startDate: formatter.date(from: "2025-01-30T07:15:00Z")!,
                                endDate: formatter.date(from: "2025-01-30T08:00:00Z")!,
                                value: .veryHigh,
                                averageHeartRate: 172,
                                caloriesBurned: 380
                            ),
                            HealthData.WorkoutPhaseEntry(
                                id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440037")!,
                                startDate: formatter.date(from: "2025-01-30T08:00:00Z")!,
                                endDate: formatter.date(from: "2025-01-30T08:15:00Z")!,
                                value: .moderate,
                                averageHeartRate: 145,
                                caloriesBurned: 50
                            )
                        ]
                    )
                ]
            )
        ]
    )

    // Période vide
    static let emptyPeriod = WeeklyWorkouts(
        id: UUID(uuidString: "990e8400-e29b-41d4-a716-446655440008")!,
        dailyWorkouts: []
    )
}

final class WorkoutDataManagerFactoryTests: XCTestCase {
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
        let healthKitData = [WorkoutPeriodTestData.currentAndEarlyWeekMergedPeriod]
        let coreDataEntries = WorkoutDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        let retrievedHealthKitData = WorkoutDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertEqual(healthKitData, retrievedHealthKitData)
    }
    
    func testMapHealthKitToCoreDataWithEmptyData() {
        let healthKitData: [WeeklyWorkouts] = []
        let coreDataEntries = WorkoutDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        XCTAssertTrue(coreDataEntries.isEmpty, "Mapping an empty HealthKit dataset should return an empty CoreData dataset")
    }
    
    func testMapHealthKitToCoreDataWithInvalidData() {
        let healthKitData = [WorkoutPeriodTestData.emptyPeriod]
        let coreDataEntries = WorkoutDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        XCTAssertTrue(coreDataEntries.isEmpty, "HealthKit period without entries should not be mapped")
    }
    
    func testMapCoreDataToHealthKitWithEmptyData() {
        let coreDataEntries: [WeeklyWorkoutsMO] = []
        let healthKitData = WorkoutDataManagerFactory.mapCoreDataToHealthKit(coreDataEntries)
        
        XCTAssertTrue(healthKitData.isEmpty, "Mapping an empty CoreData dataset should return an empty HealthKit dataset")
    }
    
    func testMergeCoreDataWithHealthKitDataWhenHealthKitIsEmpty() {
        let coreDataEntries: [WeeklyWorkoutsMO] = WorkoutDataManagerFactory.mapHealthKitToCoreData([WorkoutPeriodTestData.currentAndEarlyWeekMergedPeriod], context: context)
        let healthKitData: [WeeklyWorkouts] = []
        let mergedEntries = WorkoutDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        XCTAssertEqual(mergedEntries, coreDataEntries, "When HealthKit data is empty, the CoreData entries should remain unchanged.")
    }
    
    func testMergeCoreDataWithHealthKitDataWhenCoreDataIsEmpty() {
        let coreDataEntries: [WeeklyWorkoutsMO] = []
        let healthKitData: [WeeklyWorkouts] = [WorkoutPeriodTestData.previousWeekPeriod]
        let mergedEntries = WorkoutDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = WorkoutDataManagerFactory.mapHealthKitToCoreData(healthKitData, context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenCoreDataAndHealthKitAreEmpty() {
        let coreDataEntries: [WeeklyWorkoutsMO] = []
        let healthKitData: [WeeklyWorkouts] = []
        let mergedEntries = WorkoutDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        
        XCTAssertTrue(mergedEntries.isEmpty, "When both CoreData and HealthKit are empty, the result should be an empty array.")
    }
    
    func testMergeCoreDataWithHealthKitDataWhenWeeksAreDifferent() {
        let coreDataEntries: [WeeklyWorkoutsMO] = WorkoutDataManagerFactory.mapHealthKitToCoreData([WorkoutPeriodTestData.previousWeekPeriod], context: context)
        let healthKitData: [WeeklyWorkouts] = [WorkoutPeriodTestData.currentWeekPeriod]
        
        let mergedEntries = WorkoutDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = WorkoutDataManagerFactory.mapHealthKitToCoreData([WorkoutPeriodTestData.currentWeekPeriod, WorkoutPeriodTestData.previousWeekPeriod], context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
    
    func testMergeCoreDataWithHealthKitDataWhenDatesAreTheSameWeek() {
        let coreDataEntries: [WeeklyWorkoutsMO] = WorkoutDataManagerFactory.mapHealthKitToCoreData([WorkoutPeriodTestData.currentEarlyWeekPeriod], context: context)
        let healthKitData: [WeeklyWorkouts] = [WorkoutPeriodTestData.currentWeekPeriod]
        
        let mergedEntries = WorkoutDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataEntries, with: healthKitData, in: context)
        let expectedEntries = WorkoutDataManagerFactory.mapHealthKitToCoreData([WorkoutPeriodTestData.currentAndEarlyWeekMergedPeriod], context: context)
        
        checkPeriodEntriesEqual(mergedEntries, expectedEntries)
    }
}

extension WorkoutDataManagerFactoryTests {
    func checkPeriodEntriesEqual(
        _ mergedEntries: [WeeklyWorkoutsMO],
        _ expectedEntries: [WeeklyWorkoutsMO]
    ) {
        XCTAssertEqual(mergedEntries.count, expectedEntries.count, "The number of merged weekly entries should match the expected entries count.")

        for (index, mergedEntry) in mergedEntries.enumerated() {
            let expectedEntry = expectedEntries[index]

            XCTAssertEqual(mergedEntry.id, expectedEntry.id, "Mismatch in id at index \(index)")
            XCTAssertEqual(mergedEntry.startDate, expectedEntry.startDate, "Mismatch in startDate at index \(index)")
            XCTAssertEqual(mergedEntry.endDate, expectedEntry.endDate, "Mismatch in endDate at index \(index)")

            if index > 0,
               let currentStartDate = mergedEntry.startDate,
               let previousStartDate = mergedEntries[index - 1].startDate {
                XCTAssertTrue(currentStartDate <= previousStartDate, "Periods should be sorted chronologically at index \(index)")
            }

            let mergedDailyWorkouts = mergedEntry.dailyWorkouts?.compactMap { $0 as? DailyWorkoutsMO } ?? []
            let expectedDailyWorkouts = expectedEntry.dailyWorkouts?.compactMap { $0 as? DailyWorkoutsMO } ?? []

            XCTAssertEqual(mergedDailyWorkouts.count, expectedDailyWorkouts.count, "Daily workouts count mismatch for weekly entry at index \(index)")

            for (dailyIndex, mergedDailyWorkout) in mergedDailyWorkouts.enumerated() {
                let expectedDailyWorkout = expectedDailyWorkouts[dailyIndex]

                XCTAssertEqual(mergedDailyWorkout.id, expectedDailyWorkout.id, "Mismatch in daily workout id at index \(dailyIndex) in weekly entry \(index)")
                XCTAssertEqual(mergedDailyWorkout.startDate, expectedDailyWorkout.startDate, "Mismatch in daily workout startDate at index \(dailyIndex) in weekly entry \(index)")
                XCTAssertEqual(mergedDailyWorkout.endDate, expectedDailyWorkout.endDate, "Mismatch in daily workout endDate at index \(dailyIndex) in weekly entry \(index)")

                if let dailyStartDate = mergedDailyWorkout.startDate,
                   let dailyEndDate = mergedDailyWorkout.endDate,
                   let weeklyStartDate = mergedEntry.startDate,
                   let weeklyEndDate = mergedEntry.endDate {
                    XCTAssertTrue(dailyStartDate >= weeklyStartDate && dailyEndDate <= weeklyEndDate, "Daily workout at index \(dailyIndex) is not within its weekly period at index \(index)")
                }

                let mergedWorkouts = mergedDailyWorkout.workouts?.compactMap { $0 as? WorkoutMO } ?? []
                let expectedWorkouts = expectedDailyWorkout.workouts?.compactMap { $0 as? WorkoutMO } ?? []

                XCTAssertEqual(mergedWorkouts.count, expectedWorkouts.count, "Workouts count mismatch for daily entry at index \(dailyIndex) in weekly entry \(index)")

                for (workoutIndex, mergedWorkout) in mergedWorkouts.enumerated() {
                    let expectedWorkout = expectedWorkouts[workoutIndex]

                    XCTAssertEqual(mergedWorkout.id, expectedWorkout.id, "Mismatch in workout id at index \(workoutIndex) in daily entry \(dailyIndex) in weekly entry \(index)")
                    XCTAssertEqual(mergedWorkout.startDate, expectedWorkout.startDate, "Mismatch in workout startDate at index \(workoutIndex) in daily entry \(dailyIndex) in weekly entry \(index)")
                    XCTAssertEqual(mergedWorkout.endDate, expectedWorkout.endDate, "Mismatch in workout endDate at index \(workoutIndex) in daily entry \(dailyIndex) in weekly entry \(index)")

                    if let workoutStartDate = mergedWorkout.startDate,
                       let workoutEndDate = mergedWorkout.endDate,
                       let dailyStartDate = mergedDailyWorkout.startDate,
                       let dailyEndDate = mergedDailyWorkout.endDate {
                        XCTAssertTrue(workoutStartDate >= dailyStartDate && workoutEndDate <= dailyEndDate, "Workout at index \(workoutIndex) is not within its daily period at index \(dailyIndex) in weekly entry \(index)")
                    }

                    let mergedWorkoutEntries = mergedWorkout.workoutPhaseEntries?.compactMap { $0 as? WorkoutPhaseEntryMO } ?? []
                    let expectedWorkoutEntries = expectedWorkout.workoutPhaseEntries?.compactMap { $0 as? WorkoutPhaseEntryMO } ?? []

                    XCTAssertEqual(mergedWorkoutEntries.count, expectedWorkoutEntries.count, "Workout entries count mismatch at index \(workoutIndex) in daily entry \(dailyIndex) in weekly entry \(index)")

                    for (entryIndex, mergedWorkoutEntry) in mergedWorkoutEntries.enumerated() {
                        let expectedWorkoutEntry = expectedWorkoutEntries[entryIndex]

                        XCTAssertEqual(mergedWorkoutEntry.id, expectedWorkoutEntry.id, "Workout entry ID mismatch at index \(entryIndex) in workout \(workoutIndex) in daily entry \(dailyIndex) in weekly entry \(index)")
                        XCTAssertEqual(mergedWorkoutEntry.startDate, expectedWorkoutEntry.startDate, "Workout entry startDate mismatch at index \(entryIndex) in workout \(workoutIndex) in daily entry \(dailyIndex) in weekly entry \(index)")
                        XCTAssertEqual(mergedWorkoutEntry.endDate, expectedWorkoutEntry.endDate, "Workout entry endDate mismatch at index \(entryIndex) in workout \(workoutIndex) in daily entry \(dailyIndex) in weekly entry \(index)")
                        XCTAssertEqual(mergedWorkoutEntry.value, expectedWorkoutEntry.value, "Workout entry value mismatch at index \(entryIndex) in workout \(workoutIndex) in daily entry \(dailyIndex) in weekly entry \(index)")
                        XCTAssertEqual(mergedWorkoutEntry.unit, expectedWorkoutEntry.unit, "Workout entry unit mismatch at index \(entryIndex) in workout \(workoutIndex) in daily entry \(dailyIndex) in weekly entry \(index)")

                        if let entryStartDate = mergedWorkoutEntry.startDate,
                           let entryEndDate = mergedWorkoutEntry.endDate,
                           let workoutStartDate = mergedWorkout.startDate,
                           let workoutEndDate = mergedWorkout.endDate {
                            XCTAssertTrue(entryStartDate >= workoutStartDate && entryEndDate <= workoutEndDate, "Workout entry at index \(entryIndex) is not within its workout's range at index \(workoutIndex) in daily entry \(dailyIndex) in weekly entry \(index)")
                        }
                    }
                }
            }
        }
    }
}

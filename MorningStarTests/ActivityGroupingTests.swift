//
//  ActivityGroupingTests.swift
//  MorningStarTests
//
//  Created by Guillaume Djaider Fornari on 19/02/2025.
//

import XCTest
import HealthKit
@testable import MorningStar
import CoreData

class ActivityGroupingTests: XCTestCase {
    let unit = HKUnit.count()
     let calendar = Calendar.current
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
     
     // Helper function to create sample data
     private func createQuantitySample(
         start: Date,
         end: Date,
         value: Double
     ) -> HKQuantitySample {
         let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
         let quantity = HKQuantity(unit: unit, doubleValue: value)
         return HKQuantitySample(
             type: type,
             quantity: quantity,
             start: start,
             end: end
         )
     }
     
     func testEmptyData() {
         let samples: [HKSample] = []
         let result = HealthDataProcessor.groupActivitiesByDay(from: samples, unit: unit)
         XCTAssertTrue(result.isEmpty, "Result should be empty for empty input")
     }
     
     func testSingleActivity() {
         let now = Date()
         let samples = [
             createQuantitySample(
                 start: now,
                 end: now.addingTimeInterval(60),
                 value: 100
             )
         ]
         
         let result = HealthDataProcessor.groupActivitiesByDay(from: samples, unit: unit)
         
         XCTAssertEqual(result.count, 1, "Should have one day of activities")
         XCTAssertEqual(result[0].entries.count, 1, "Should have one activity")
         XCTAssertEqual(result[0].entries[0].value, 100, "Value should be 100")
     }
     
     func testMultipleActivitiesSameDay() {
         let now = Date()
         let samples = [
             createQuantitySample(
                 start: now,
                 end: now.addingTimeInterval(60),
                 value: 100
             ),
             createQuantitySample(
                 start: now.addingTimeInterval(120),
                 end: now.addingTimeInterval(180),
                 value: 150
             )
         ]
         
         let result = HealthDataProcessor.groupActivitiesByDay(from: samples, unit: unit)
         
         XCTAssertEqual(result.count, 1, "Should have one day")
         XCTAssertEqual(result[0].entries.count, 1, "Should have three entries including inactivity")
         XCTAssertEqual(result[0].entries[0].value, 250, "Middle entry should be inactivity")
     }
     
     func testActivityMerging() {
         let now = Date()
         let samples = [
             createQuantitySample(
                 start: now,
                 end: now.addingTimeInterval(60),
                 value: 100
             ),
             createQuantitySample(
                 start: now.addingTimeInterval(120),
                 end: now.addingTimeInterval(180),
                 value: 150
             ),
             // This should merge with previous activity (less than 5 min gap)
             createQuantitySample(
                 start: now.addingTimeInterval(200),
                 end: now.addingTimeInterval(260),
                 value: 75
             )
         ]
         
         let result = HealthDataProcessor.groupActivitiesByDay(from: samples, unit: unit)
         
         XCTAssertEqual(result[0].entries.count, 3)
         XCTAssertEqual(result[0].entries[2].value, 225) // 150 + 75
     }
     
     func testMultipleDays() {
         let now = Date()
         let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
         let samples = [
             createQuantitySample(
                 start: now,
                 end: now.addingTimeInterval(60),
                 value: 100
             ),
             createQuantitySample(
                 start: now.addingTimeInterval(120),
                 end: now.addingTimeInterval(180),
                 value: 150
             ),
             createQuantitySample(
                 start: now.addingTimeInterval(600),
                 end: now.addingTimeInterval(700),
                 value: 160
             ),
             createQuantitySample(
                 start: tomorrow,
                 end: tomorrow.addingTimeInterval(60),
                 value: 200
             ),
             createQuantitySample(
                 start: tomorrow.addingTimeInterval(600),
                 end: tomorrow.addingTimeInterval(700),
                 value: 200
             )
         ]
         
         let result = HealthDataProcessor.groupActivitiesByDay(from: samples, unit: unit)
         
         XCTAssertEqual(result.count, 2, "Should have two days")
         XCTAssertEqual(result[0].entries[0].value, 200, "First day should have 200 steps")
         XCTAssertEqual(result[1].entries[0].value, 100, "Second day should have 100 steps")
     }
     
     func testChronologicalOrder() {
         let now = Date()
         let samples = [
             createQuantitySample(
                 start: now.addingTimeInterval(3600),
                 end: now.addingTimeInterval(3660),
                 value: 200
             ),
             createQuantitySample(
                 start: now,
                 end: now.addingTimeInterval(60),
                 value: 100
             )
         ]
         
         let result = HealthDataProcessor.groupActivitiesByDay(from: samples, unit: unit)
         
         XCTAssertEqual(result[0].entries[0].value, 100, "First entry should be earlier activity")
         XCTAssertEqual(result[0].entries[2].value, 200, "Last entry should be later activity")
     }
    
    func testMultipleDaysWithMerge() {
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let healthKit = [
            createQuantitySample(
                start: now.addingTimeInterval(120),
                end: now.addingTimeInterval(180),
                value: 150
            ),
            createQuantitySample(
                start: now,
                end: now.addingTimeInterval(60),
                value: 100
            )
        ]
        
        let coreData = [
            createQuantitySample(
                start: now.addingTimeInterval(600),
                end: now.addingTimeInterval(700),
                value: 160
            ),
            createQuantitySample(
                start: tomorrow.addingTimeInterval(600),
                end: tomorrow.addingTimeInterval(700),
                value: 200
            ),
            createQuantitySample(
                start: tomorrow,
                end: tomorrow.addingTimeInterval(60),
                value: 200
            ),
        ]
        
        let healthKitHealth = HealthDataProcessor.groupActivitiesByDay(from: healthKit, unit: unit)
        let coreDataHealth = HealthDataProcessor.groupActivitiesByDay(from: coreData, unit: unit)
        
        let healthKitCore = StepDataManagerFactory.mapHealthKitToCoreData(healthKitHealth, context: context)
        let coreDataCore = StepDataManagerFactory.mapHealthKitToCoreData(coreDataHealth, context: context)
        
        //let healthKit2 = StepDataManagerFactory.mapCoreDataToHealthKit(coreData2)
        let resultat = StepDataManagerFactory.mergeCoreDataWithHealthKitData(coreDataCore, with: healthKitHealth, in: context)
    }
 }

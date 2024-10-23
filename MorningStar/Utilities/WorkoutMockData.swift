//
//  WorkoutMockData.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 23/10/2024.
//

import Foundation

struct WorkoutMockData {
    static let fullHistory: HealthData.WorkoutHistory = {
        let now = Date()
        let secondsInADay: TimeInterval = 24 * 3600
        let secondsInAnHour: TimeInterval = 3600
        
        let dates = [
            now.addingTimeInterval(-21 * secondsInADay + 8 * secondsInAnHour),
            now.addingTimeInterval(-21 * secondsInADay + 9 * secondsInAnHour),
            now.addingTimeInterval(-19 * secondsInADay + 17 * secondsInAnHour),
            now.addingTimeInterval(-17 * secondsInADay + 8 * secondsInAnHour),
            now.addingTimeInterval(-16 * secondsInADay + 10 * secondsInAnHour),
            now.addingTimeInterval(-14 * secondsInADay + 8 * secondsInAnHour),
            now.addingTimeInterval(-14 * secondsInADay + 18 * secondsInAnHour),
            now.addingTimeInterval(-13 * secondsInADay + 17 * secondsInAnHour),
            now.addingTimeInterval(-11 * secondsInADay + 12 * secondsInAnHour),
            now.addingTimeInterval(-10 * secondsInADay + 16 * secondsInAnHour),
            now.addingTimeInterval(-9 * secondsInADay + 9 * secondsInAnHour)
        ]
        
        return [
            [
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: dates[0],
                            endDate: dates[1],
                            value: .moderate,
                            averageHeartRate: 145,
                            caloriesBurned: 400
                        )
                    ]
                ],
                [],
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: dates[2],
                            endDate: dates[2].addingTimeInterval(45 * 60),
                            value: .high,
                            averageHeartRate: 160,
                            caloriesBurned: 350
                        )
                    ]
                ],
                [],
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: dates[3],
                            endDate: dates[3].addingTimeInterval(3600),
                            value: .moderate,
                            averageHeartRate: 140,
                            caloriesBurned: 380
                        )
                    ]
                ],
                // Samedi
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: dates[4],
                            endDate: dates[4].addingTimeInterval(3600),
                            value: .high,
                            averageHeartRate: 155,
                            caloriesBurned: 450
                        )
                    ]
                ],
                []
            ],
            
            [
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: dates[5],
                            endDate: dates[5].addingTimeInterval(30 * 60),
                            value: .moderate,
                            averageHeartRate: 135,
                            caloriesBurned: 250
                        )
                    ],
                    [
                        HealthData.WorkoutEntry(
                            startDate: dates[6],
                            endDate: dates[6].addingTimeInterval(3600),
                            value: .high,
                            averageHeartRate: 165,
                            caloriesBurned: 400
                        )
                    ]
                ],
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: dates[7],
                            endDate: dates[7].addingTimeInterval(3600),
                            value: .veryHigh,
                            averageHeartRate: 175,
                            caloriesBurned: 500
                        )
                    ]
                ],
                [],
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: dates[8],
                            endDate: dates[8].addingTimeInterval(3600),
                            value: .moderate,
                            averageHeartRate: 140,
                            caloriesBurned: 350
                        )
                    ]
                ],
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: dates[9],
                            endDate: dates[9].addingTimeInterval(3600),
                            value: .high,
                            averageHeartRate: 160,
                            caloriesBurned: 420
                        )
                    ]
                ],
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: dates[10],
                            endDate: dates[10].addingTimeInterval(5 * 60),
                            value: .low,
                            averageHeartRate: 95,
                            caloriesBurned: 25
                        ),
                        HealthData.WorkoutEntry(
                            startDate: dates[10].addingTimeInterval(5 * 60),
                            endDate: dates[10].addingTimeInterval(25 * 60),
                            value: .veryHigh,
                            averageHeartRate: 180,
                            caloriesBurned: 300
                        ),
                        HealthData.WorkoutEntry(
                            startDate: dates[10].addingTimeInterval(25 * 60),
                            endDate: dates[10].addingTimeInterval(30 * 60),
                            value: .low,
                            averageHeartRate: 110,
                            caloriesBurned: 30
                        )
                    ]
                ],
                []
            ],
            
            [
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: now.addingTimeInterval(-7 * secondsInADay + 8 * secondsInAnHour),
                            endDate: now.addingTimeInterval(-7 * secondsInADay + 9 * secondsInAnHour),
                            value: .moderate,
                            averageHeartRate: 140,
                            caloriesBurned: 380
                        )
                    ]
                ],
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: now.addingTimeInterval(-6 * secondsInADay + 17 * secondsInAnHour),
                            endDate: now.addingTimeInterval(-6 * secondsInADay + 18 * secondsInAnHour),
                            value: .high,
                            averageHeartRate: 155,
                            caloriesBurned: 420
                        )
                    ]
                ],
                [],
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: now.addingTimeInterval(-4 * secondsInADay + 12 * secondsInAnHour),
                            endDate: now.addingTimeInterval(-4 * secondsInADay + 13 * secondsInAnHour),
                            value: .moderate,
                            averageHeartRate: 145,
                            caloriesBurned: 390
                        )
                    ]
                ],
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: now.addingTimeInterval(-3 * secondsInADay + 16 * secondsInAnHour),
                            endDate: now.addingTimeInterval(-3 * secondsInADay + 17 * secondsInAnHour),
                            value: .high,
                            averageHeartRate: 165,
                            caloriesBurned: 450
                        )
                    ]
                ],
                [
                    [
                        HealthData.WorkoutEntry(
                            startDate: now.addingTimeInterval(-2 * secondsInADay + 9 * secondsInAnHour),
                            endDate: now.addingTimeInterval(-2 * secondsInADay + 10 * secondsInAnHour + 30 * 60),
                            value: .moderate,
                            averageHeartRate: 150,
                            caloriesBurned: 520
                        )
                    ]
                ],
                []
            ]
        ]
    }()
    
      static var lastWeek: HealthData.WeeklyWorkoutSessions {
          fullHistory[1]
      }
      
      static var typicalDay: HealthData.DailyWorkoutSessions {
          fullHistory[2][1]
      }
      
      static var hiitWorkout: HealthData.WorkoutPhaseEntries {
          fullHistory[1][5][0]
      }
      
      static var moderateCardio: HealthData.WorkoutPhaseEntries {
          fullHistory[2][0][0]
      }
      
      static var intenseWorkout: HealthData.WorkoutPhaseEntries {
          fullHistory[2][1][0]
      }
}

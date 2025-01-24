//
//  WorkoutMockData.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 23/10/2024.
//

import Foundation

struct WorkoutMockData {
    static let fullHistory: [WeeklyWorkouts] = {
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
            WeeklyWorkouts(dailyWorkouts: [
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: dates[0],
                            endDate: dates[1],
                            value: .moderate,
                            averageHeartRate: 145,
                            caloriesBurned: 400
                        )
                    ])
                ]),
                DailyWorkouts(workouts: []),
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: dates[2],
                            endDate: dates[2].addingTimeInterval(45 * 60),
                            value: .high,
                            averageHeartRate: 160,
                            caloriesBurned: 350
                        )
                    ])
                ]),
                DailyWorkouts(workouts: []),
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: dates[3],
                            endDate: dates[3].addingTimeInterval(3600),
                            value: .moderate,
                            averageHeartRate: 140,
                            caloriesBurned: 380
                        )
                    ])
                ]),
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: dates[4],
                            endDate: dates[4].addingTimeInterval(3600),
                            value: .high,
                            averageHeartRate: 155,
                            caloriesBurned: 450
                        )
                    ])
                ]),
                DailyWorkouts(workouts: [])
            ]),
            
            WeeklyWorkouts(dailyWorkouts: [
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: dates[5],
                            endDate: dates[5].addingTimeInterval(30 * 60),
                            value: .moderate,
                            averageHeartRate: 135,
                            caloriesBurned: 250
                        )
                    ]),
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: dates[6],
                            endDate: dates[6].addingTimeInterval(3600),
                            value: .high,
                            averageHeartRate: 165,
                            caloriesBurned: 400
                        )
                    ])
                ]),
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: dates[7],
                            endDate: dates[7].addingTimeInterval(3600),
                            value: .veryHigh,
                            averageHeartRate: 175,
                            caloriesBurned: 500
                        )
                    ])
                ]),
                DailyWorkouts(workouts: []),
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: dates[8],
                            endDate: dates[8].addingTimeInterval(3600),
                            value: .moderate,
                            averageHeartRate: 140,
                            caloriesBurned: 350
                        )
                    ])
                ]),
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: dates[9],
                            endDate: dates[9].addingTimeInterval(3600),
                            value: .high,
                            averageHeartRate: 160,
                            caloriesBurned: 420
                        )
                    ])
                ]),
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: dates[10],
                            endDate: dates[10].addingTimeInterval(5 * 60),
                            value: .low,
                            averageHeartRate: 95,
                            caloriesBurned: 25
                        ),
                        HealthData.WorkoutPhaseEntry(
                            startDate: dates[10].addingTimeInterval(5 * 60),
                            endDate: dates[10].addingTimeInterval(25 * 60),
                            value: .veryHigh,
                            averageHeartRate: 180,
                            caloriesBurned: 300
                        ),
                        HealthData.WorkoutPhaseEntry(
                            startDate: dates[10].addingTimeInterval(25 * 60),
                            endDate: dates[10].addingTimeInterval(30 * 60),
                            value: .low,
                            averageHeartRate: 110,
                            caloriesBurned: 30
                        )
                    ])
                ]),
                DailyWorkouts(workouts: [])
            ]),
            
            WeeklyWorkouts(dailyWorkouts: [
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: now.addingTimeInterval(-7 * secondsInADay + 8 * secondsInAnHour),
                            endDate: now.addingTimeInterval(-7 * secondsInADay + 9 * secondsInAnHour),
                            value: .moderate,
                            averageHeartRate: 140,
                            caloriesBurned: 380
                        )
                    ])
                ]),
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: now.addingTimeInterval(-6 * secondsInADay + 17 * secondsInAnHour),
                            endDate: now.addingTimeInterval(-6 * secondsInADay + 18 * secondsInAnHour),
                            value: .high,
                            averageHeartRate: 155,
                            caloriesBurned: 420
                        )
                    ])
                ]),
                DailyWorkouts(workouts: []),
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: now.addingTimeInterval(-4 * secondsInADay + 12 * secondsInAnHour),
                            endDate: now.addingTimeInterval(-4 * secondsInADay + 13 * secondsInAnHour),
                            value: .moderate,
                            averageHeartRate: 145,
                            caloriesBurned: 390
                        )
                    ])
                ]),
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: now.addingTimeInterval(-3 * secondsInADay + 16 * secondsInAnHour),
                            endDate: now.addingTimeInterval(-3 * secondsInADay + 17 * secondsInAnHour),
                            value: .high,
                            averageHeartRate: 165,
                            caloriesBurned: 450
                        )
                    ])
                ]),
                DailyWorkouts(workouts: [
                    Workout(phaseEntries: [
                        HealthData.WorkoutPhaseEntry(
                            startDate: now.addingTimeInterval(-2 * secondsInADay + 9 * secondsInAnHour),
                            endDate: now.addingTimeInterval(-2 * secondsInADay + 10 * secondsInAnHour + 30 * 60),
                            value: .moderate,
                            averageHeartRate: 150,
                            caloriesBurned: 520
                        )
                    ])
                ]),
                DailyWorkouts(workouts: [])
            ])
        ]
    }()
    
    static var lastWeek: WeeklyWorkouts {
        fullHistory[1]
      }
      
    static var typicalDay: DailyWorkouts {
        fullHistory[2].dailyWorkouts[1]
      }
      
    static var hiitWorkout: Workout {
        fullHistory[1].dailyWorkouts[5].workouts[0]
      }
      
      static var moderateCardio: Workout {
          fullHistory[2].dailyWorkouts[0].workouts[0]
      }
      
      static var intenseWorkout: Workout {
          fullHistory[2].dailyWorkouts[1].workouts[0]
      }
}

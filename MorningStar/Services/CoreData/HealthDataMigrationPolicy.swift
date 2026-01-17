//
//  HealthDataMigrationPolicy.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 17/01/2026.
//

import CoreData

final class StepEntryMigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        guard let stepEntries = sInstance.value(forKey: "stepEntries") as? NSOrderedSet else { return }

        for case let stepEntry as NSManagedObject in stepEntries {
            let dest = NSEntityDescription.insertNewObject(
                forEntityName: "StepEntryMO",
                into: manager.destinationContext
            )
            dest.setValue(stepEntry.value(forKey: "id"), forKey: "id")
            dest.setValue(stepEntry.value(forKey: "startDate"), forKey: "startDate")
            dest.setValue(stepEntry.value(forKey: "endDate"), forKey: "endDate")
            dest.setValue(stepEntry.value(forKey: "value"), forKey: "value")
            dest.setValue(stepEntry.value(forKey: "unit"), forKey: "unit")
        }
    }
}

final class CalorieEntryMigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        guard let calorieEntries = sInstance.value(forKey: "calorieEntries") as? NSOrderedSet else { return }

        for case let calorieEntry as NSManagedObject in calorieEntries {
            let dest = NSEntityDescription.insertNewObject(
                forEntityName: "CalorieEntryMO",
                into: manager.destinationContext
            )
            dest.setValue(calorieEntry.value(forKey: "id"), forKey: "id")
            dest.setValue(calorieEntry.value(forKey: "startDate"), forKey: "startDate")
            dest.setValue(calorieEntry.value(forKey: "endDate"), forKey: "endDate")
            dest.setValue(calorieEntry.value(forKey: "value"), forKey: "value")
            dest.setValue(calorieEntry.value(forKey: "unit"), forKey: "unit")
        }
    }
}

final class WeightEntryMigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        guard let weightEntries = sInstance.value(forKey: "weightEntries") as? NSOrderedSet else { return }

        for case let weightEntry as NSManagedObject in weightEntries {
            let dest = NSEntityDescription.insertNewObject(
                forEntityName: "WeightEntryMO",
                into: manager.destinationContext
            )
            dest.setValue(weightEntry.value(forKey: "id"), forKey: "id")
            dest.setValue(weightEntry.value(forKey: "startDate"), forKey: "startDate")
            dest.setValue(weightEntry.value(forKey: "endDate"), forKey: "endDate")
            dest.setValue(weightEntry.value(forKey: "value"), forKey: "value")
            dest.setValue(weightEntry.value(forKey: "unit"), forKey: "unit")
        }
    }
}

final class SleepEntryMigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        guard let sleepEntries = sInstance.value(forKey: "sleepEntries") as? NSOrderedSet else { return }

        for case let sleepEntry as NSManagedObject in sleepEntries {
            let dest = NSEntityDescription.insertNewObject(
                forEntityName: "SleepEntryMO",
                into: manager.destinationContext
            )
            dest.setValue(sleepEntry.value(forKey: "id"), forKey: "id")
            dest.setValue(sleepEntry.value(forKey: "startDate"), forKey: "startDate")
            dest.setValue(sleepEntry.value(forKey: "endDate"), forKey: "endDate")
            dest.setValue(sleepEntry.value(forKey: "unit"), forKey: "unit")
        }
    }
}

final class HeartRateEntryMigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        guard let heartRateEntries = sInstance.value(forKey: "heartRateEntries") as? NSOrderedSet else { return }

        for case let heartRateEntry as NSManagedObject in heartRateEntries {
            let dest = NSEntityDescription.insertNewObject(
                forEntityName: "HeartRateEntryMO",
                into: manager.destinationContext
            )
            dest.setValue(heartRateEntry.value(forKey: "id"), forKey: "id")
            dest.setValue(heartRateEntry.value(forKey: "startDate"), forKey: "startDate")
            dest.setValue(heartRateEntry.value(forKey: "endDate"), forKey: "endDate")
            dest.setValue(heartRateEntry.value(forKey: "value"), forKey: "value")
            dest.setValue(heartRateEntry.value(forKey: "unit"), forKey: "unit")
        }
    }
}

final class WorkoutMigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        guard let dailyWorkouts = sInstance.value(forKey: "dailyWorkouts") as? NSOrderedSet else { return }

        for case let dailyWorkout as NSManagedObject in dailyWorkouts {
            guard let workouts = dailyWorkout.value(forKey: "workouts") as? NSOrderedSet else { continue }

            for case let workout as NSManagedObject in workouts {
                let destWorkout = NSEntityDescription.insertNewObject(
                    forEntityName: "WorkoutMO",
                    into: manager.destinationContext
                )
                destWorkout.setValue(workout.value(forKey: "id"), forKey: "id")
                destWorkout.setValue(workout.value(forKey: "startDate"), forKey: "startDate")
                destWorkout.setValue(workout.value(forKey: "endDate"), forKey: "endDate")
                destWorkout.setValue(workout.value(forKey: "type"), forKey: "type")

                guard let phases = workout.value(forKey: "workoutPhaseEntries") as? NSOrderedSet else { continue }
                var destPhases: [NSManagedObject] = []

                for case let phase as NSManagedObject in phases {
                    let destPhase = NSEntityDescription.insertNewObject(
                        forEntityName: "WorkoutPhaseEntryMO",
                        into: manager.destinationContext
                    )
                    destPhase.setValue(phase.value(forKey: "id"), forKey: "id")
                    destPhase.setValue(phase.value(forKey: "startDate"), forKey: "startDate")
                    destPhase.setValue(phase.value(forKey: "endDate"), forKey: "endDate")
                    destPhase.setValue(phase.value(forKey: "value"), forKey: "value")
                    destPhase.setValue(phase.value(forKey: "averageHeartRate"), forKey: "averageHeartRate")
                    destPhase.setValue(phase.value(forKey: "caloriesBurned"), forKey: "caloriesBurned")
                    destPhase.setValue(phase.value(forKey: "unit"), forKey: "unit")
                    destPhase.setValue(destWorkout, forKey: "workout")
                    destPhases.append(destPhase)
                }

                destWorkout.setValue(NSOrderedSet(array: destPhases), forKey: "phases")
            }
        }
    }
}

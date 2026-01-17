# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the project
DEVELOPER_DIR=/Applications/Xcode-26.2.0.app/Contents/Developer xcodebuild -scheme MorningStar -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all tests
DEVELOPER_DIR=/Applications/Xcode-26.2.0.app/Contents/Developer xcodebuild -scheme MorningStar -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test class
DEVELOPER_DIR=/Applications/Xcode-26.2.0.app/Contents/Developer xcodebuild -scheme MorningStar -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MorningStarTests/StepDataManagerFactoryTests test

# Run a single test method
DEVELOPER_DIR=/Applications/Xcode-26.2.0.app/Contents/Developer xcodebuild -scheme MorningStar -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MorningStarTests/StepDataManagerFactoryTests/testMergeCoreDataWithHealthKitData_sameDayData_mergesEntries test
```

## Architecture

MorningStar is a health analytics iOS app using SwiftUI, HealthKit, and Core Data with Swift 6 strict concurrency.

### Layer Structure

```
Views (SwiftUI)
    ↓
ViewModels (@MainActor @Observable)
    ↓
HealthRepository (coordinates data sources)
    ↓
Services (CoreDataSource actor, HealthKitSource)
    ↓
Data Stores (Core Data, HealthKit, UserDefaults)
```

### Key Patterns

**Actor-based Core Data**: All Core Data operations go through `CoreDataSource` (an actor) via `context.performAndWait`. Never access Core Data directly.

**Factory Pattern for Health Metrics**: Each health metric (steps, calories, weight, sleep, workouts) has a factory implementing `HealthDataFactoryProtocol`:
- `StepDataManagerFactory`
- `CalorieBurnedDataManagerFactory`
- `WeightDataManagerFactory`
- `SleepDataManagerFactory`
- `WorkoutDataManagerFactory`
- `HeartRateDataManagerFactory`

These factories handle bidirectional mapping between HealthKit samples and Core Data entities.

**Sync Strategy**: `TimeBasedSyncStrategy` throttles HealthKit syncs (300s minimum interval). `LastSyncStorage` tracks per-metric sync timestamps in UserDefaults.

### Data Flow

1. `HealthDashboardViewModel.initialize()` requests HealthKit authorization
2. `loadAllLocalData()` fetches from Core Data in parallel (TaskGroup)
3. `startPeriodicSync()` syncs with HealthKit every 60 seconds
4. `HealthRepository.syncData()` merges HealthKit data into Core Data
5. ViewModels update `healthMetrics` which triggers UI updates via `@Observable`

### Core Data Model

- `PeriodEntryMO` - Container for period-based entries
- `StepEntryMO`, `ActivityEntryMO`, `WeightEntryMO`, `SleepEntryMO` - Specific entry types
- `WorkoutMO`, `WorkoutPhaseMO` - Workout data with intensity phases

### Concurrency Rules

- ViewModels are `@MainActor` isolated
- `CoreDataSource` is an actor - all methods are async
- All domain types conform to `Sendable`
- Use `@preconcurrency import CoreData` for Core Data compatibility

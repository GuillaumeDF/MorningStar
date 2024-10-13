//
//  HealthViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import HealthKit

enum AuthorizationStatus {
    case notDetermined, authorized, denied
}

class HealthViewModel: ObservableObject {
    @Published var healthData = HealthData()
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
    private let healthStore = HKHealthStore()
    private let calendar = Calendar.current
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            .quantityType(forIdentifier: .stepCount)!,
            .quantityType(forIdentifier: .bodyMass)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .quantityType(forIdentifier: .heartRate)!,
            .categoryType(forIdentifier: .sleepAnalysis)!,
            .workoutType(),
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.authorizationStatus = success ? .authorized : .denied
                if success {
                    self?.fetchAllHealthData()
                } else {
                    self?.errorMessage = "Authorization failed: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
        }
    }
    
    func fetchAllHealthData() {
        fetchWeightHistory()
        fetchStepCountHistory()
        fetchCaloriesBurnedHistory()
        fetchSleepQualityHistory()
        fetchWorkoutHistory()
    }
    
    private func fetchStepCountHistory() {
        let startDate = calendar.date(byAdding: .year, value: -1, to: Date())!
        
        StepDataManager(healthStore: healthStore, retrieveDataFrom: startDate).fetchData {  [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.healthData.stepCountHistory = entries
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchCaloriesBurnedHistory() {
        let startDate = calendar.date(byAdding: .year, value: -1, to: Date())!
        
        CalorieBurnedDataManager(healthStore: healthStore, retrieveDataFrom: startDate).fetchData {  [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.healthData.calorieBurnHistory = entries
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchWeightHistory() {
        WeightDataManager(healthStore: healthStore).fetchData {  [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.healthData.weightHistory = entries
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchSleepQualityHistory() {
        SleepDataManager(healthStore: healthStore).fetchData {  [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.healthData.sleepHistory = entries
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchWorkoutHistory() {
        let startDate = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        WorkoutDataManager(healthStore: healthStore, retrieveDataFrom: startDate).fetchData {  [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.healthData.workoutHistory = entries
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// --------------------------------------------------------------------

struct HealthDataProcessor {
    static func groupActivitiesByDay(from statsCollection: HKStatisticsCollection, startDate: Date, unit: HKUnit) -> [PeriodEntry<HealthData.ActivityEntry>] {
        var dailyActivities: [PeriodEntry<HealthData.ActivityEntry>] = []
        var currentDayActivities: [HealthData.ActivityEntry] = []
        var currentDay: Date?
        
        statsCollection.enumerateStatistics(from: startDate, to: Date()) { statistics, _ in
            let day = Calendar.current.startOfDay(for: statistics.startDate)
            
            if currentDay != day {
                if !currentDayActivities.isEmpty {
                    dailyActivities.append(PeriodEntry(entries: currentDayActivities))
                }
                currentDay = day
                currentDayActivities = []
            }
            
            let entry = HealthData.ActivityEntry(
                startDate: statistics.startDate,
                endDate: statistics.endDate,
                value: statistics.sumQuantity()?.doubleValue(for: unit) ?? -1,
                unit: unit.unitString
            )
            currentDayActivities.append(entry)
        }
        
        if !currentDayActivities.isEmpty {
            dailyActivities.append(PeriodEntry(entries: currentDayActivities))
        }
        
        return dailyActivities
    }
    
    static func groupSleepByNight(from samples: [HKSample]) -> [PeriodEntry<HealthData.SleepEntry>] {
        var nightlyActivities: [PeriodEntry<HealthData.SleepEntry>] = []
        var currentNightActivities: [HealthData.SleepEntry] = []
        var lastSampleEndDate: Date?
        
        for sample in samples {
            guard let categorySample = sample as? HKCategorySample else { continue }
            
            if let lastEnd = lastSampleEndDate, categorySample.startDate.timeIntervalSince(lastEnd) > 4 * 60 * 60 {
                if !currentNightActivities.isEmpty {
                    nightlyActivities.append(PeriodEntry(entries: currentNightActivities))
                    currentNightActivities = []
                }
            }
            
            let entry = HealthData.SleepEntry(
                startDate: categorySample.startDate,
                endDate: categorySample.endDate,
                unit: HKUnit.hour().unitString
            )
            
            currentNightActivities.append(entry)
            lastSampleEndDate = categorySample.endDate
        }
        
        if !currentNightActivities.isEmpty {
            nightlyActivities.append(PeriodEntry(entries: currentNightActivities))
        }
        
        return nightlyActivities
    }
    
    static func groupWeightsByWeek(from samples: [HKSample], unit: HKUnit) -> [PeriodEntry<HealthData.WeightEntry>] {
        let calendar = Calendar.current
        
        var weeklyActivities: [PeriodEntry<HealthData.WeightEntry>] = []
        var currentWeekActivities: [HealthData.WeightEntry] = []
        var currentWeek: Date?
        
        for sample in samples {
            guard let quantitySample = sample as? HKQuantitySample else { continue }
            guard let week = calendar.dateInterval(of: .weekOfYear, for: quantitySample.startDate)?.start else { continue }
            
            if currentWeek != week {
                if !currentWeekActivities.isEmpty {
                    weeklyActivities.append(PeriodEntry(entries: currentWeekActivities))
                }
                currentWeek = week
                currentWeekActivities = []
            }
            
            let entry = HealthData.WeightEntry(
                startDate: sample.startDate,
                endDate: sample.endDate,
                value: quantitySample.quantity.doubleValue(for: unit),
                unit: unit.unitString
                
            )
            currentWeekActivities.append(entry)
        }
        
        if !currentWeekActivities.isEmpty {
            weeklyActivities.append(PeriodEntry(entries: currentWeekActivities))
        }
        
        return weeklyActivities
    }
}

class WorkoutIntensityAnalyzer {
    
    private enum Constants {
        static let minPhaseDurationFactor: Double = 0.05
        static let minPhaseDurationSeconds: TimeInterval = 30
        static let variabilityThresholdFactor: Double = 0.7
        static let lowIntensityThreshold: Double = 0.8
        static let moderateIntensityThreshold: Double = 1.1
        static let highIntensityThreshold: Double = 1.4
    }
    
    func generateIntensityPhases(
        workout: HKSample,
        heartRates: [HealthData.HeartRateEntry],
        caloriesBurned: [HealthData.ActivityEntry]
    ) -> [HealthData.WorkoutEntry] {
        guard !heartRates.isEmpty else {
            return [createUndeterminedPhase(startDate: workout.startDate, endDate: workout.endDate)]
        }
        
        let duration = workout.endDate.timeIntervalSince(workout.startDate)
        let globalAverages = calculateGlobalAverages(heartRates: heartRates, caloriesBurned: caloriesBurned, duration: duration)
        let thresholds = calculateThresholds(heartRates: heartRates, caloriesBurned: caloriesBurned, globalAverages: globalAverages)
        let minPhaseDuration = max(duration * Constants.minPhaseDurationFactor, Constants.minPhaseDurationSeconds)
        
        return generatePhases(
            workout: workout,
            heartRates: heartRates,
            caloriesBurned: caloriesBurned,
            globalAverages: globalAverages,
            thresholds: thresholds,
            minPhaseDuration: minPhaseDuration
        )
    }
    
    private func createUndeterminedPhase(startDate: Date, endDate: Date) -> HealthData.WorkoutEntry {
        return HealthData.WorkoutEntry(startDate: startDate, endDate: endDate, value: .undetermined, averageHeartRate: 0, caloriesBurned: 0)
    }
    
    private func calculateGlobalAverages(heartRates: [HealthData.HeartRateEntry], caloriesBurned: [HealthData.ActivityEntry], duration: TimeInterval) -> (heartRate: Double, calorieRate: Double) {
        let avgHeartRate = calculateAverageHeartRate(heartRates)
        let avgCalorieRate = calculateCaloriesBurnedRate(caloriesBurned, duration: duration)
        
        return (heartRate: avgHeartRate, calorieRate: avgCalorieRate)
    }
    
    private func calculateHeartRateVariability(_ entries: [HealthData.HeartRateEntry], globalAverage: Double) -> Double {
        let variance = entries.reduce(0.0) { sum, entrie in
            let heartRate = entrie.value
            let difference = heartRate - globalAverage
            
            return sum + (difference * difference)
        }
        return sqrt(variance / Double(entries.count))
    }
    
    private func calculateCaloriesVariability(_ entries: [HealthData.ActivityEntry], globalAverage: Double) -> Double {
        let variance = entries.reduce(0.0) { sum, entry in
            let calories = entry.value
            let difference = calories - globalAverage
            
            return sum + (difference * difference)
        }
        return sqrt(variance / Double(entries.count))
    }
    
    // Utilisation de ces fonctions dans calculateThresholds
    private func calculateThresholds(heartRates: [HealthData.HeartRateEntry], caloriesBurned: [HealthData.ActivityEntry], globalAverages: (heartRate: Double, calorieRate: Double)) -> (heartRate: Double, calorieRate: Double) {
        let heartRateVariability = calculateHeartRateVariability(heartRates, globalAverage: globalAverages.heartRate)
        let calorieRateVariability = calculateCaloriesVariability(caloriesBurned, globalAverage: globalAverages.calorieRate)
        
        return (
            heartRate: heartRateVariability * Constants.variabilityThresholdFactor,
            calorieRate: calorieRateVariability * Constants.variabilityThresholdFactor
        )
    }
    
    private func generatePhases(
        workout: HKSample,
        heartRates: [HealthData.HeartRateEntry],
        caloriesBurned: [HealthData.ActivityEntry],
        globalAverages: (heartRate: Double, calorieRate: Double),
        thresholds: (heartRate: Double, calorieRate: Double),
        minPhaseDuration: TimeInterval
    ) -> [HealthData.WorkoutEntry] {
        var phases: [HealthData.WorkoutEntry] = []
        var currentPhaseStart = workout.startDate
        var previousStats: (heartRate: Double?, calorieRate: Double?) = (
            heartRates.first?.value,
            caloriesBurned.first?.value
        )
        
        for (index, currentSample) in heartRates.enumerated() {
            let currentDate = currentSample.startDate
            let phaseDuration = currentDate.timeIntervalSince(currentPhaseStart)
            let isLastSample = index == heartRates.count - 1
            
            let phaseStats = calculatePhaseStats(
                heartRates: heartRates,
                caloriesBurned: caloriesBurned,
                startDate: currentPhaseStart,
                endDate: currentDate
            )
            
            let shouldCreatePhase = shouldCreateNewPhase(
                phaseDuration: phaseDuration,
                minPhaseDuration: minPhaseDuration,
                currentStats: phaseStats,
                previousStats: previousStats,
                thresholds: thresholds
            )
            
            if shouldCreatePhase || isLastSample {
                if isLastSample && shouldCreatePhase == false {
                    if let lastIndex = phases.indices.last {
                        phases[lastIndex].endDate = workout.endDate
                    }
                } else {
                    let phase = createWorkoutPhase(
                        startDate: currentPhaseStart,
                        endDate: currentDate,
                        stats: phaseStats,
                        globalAverages: globalAverages
                    )
                    phases.append(phase)
                    
                    currentPhaseStart = currentDate
                    previousStats = phaseStats
                }
            }
        }
        
        return phases
    }
    
    private func calculatePhaseStats(
        heartRates: [HealthData.HeartRateEntry],
        caloriesBurned: [HealthData.ActivityEntry],
        startDate: Date,
        endDate: Date
    ) -> (heartRate: Double, calorieRate: Double) {
        let phaseHeartRates = heartRates.filter { $0.startDate >= startDate && $0.endDate <= endDate }
        let phaseCalories = caloriesBurned.filter { $0.startDate >= startDate && $0.endDate <= endDate }
        let phaseDuration = endDate.timeIntervalSince(startDate)
        
        let avgHeartRate = calculateAverageHeartRate(phaseHeartRates)
        let calorieRate = calculateCaloriesBurnedRate(phaseCalories, duration: phaseDuration)
        
        return (heartRate: avgHeartRate, calorieRate: calorieRate)
    }
    
    private func shouldCreateNewPhase(
        phaseDuration: TimeInterval,
        minPhaseDuration: TimeInterval,
        currentStats: (heartRate: Double, calorieRate: Double),
        previousStats: (heartRate: Double?, calorieRate: Double?),
        thresholds: (heartRate: Double, calorieRate: Double)
    ) -> Bool {
        guard phaseDuration >= minPhaseDuration else { return false }
        
        let heartRateChanged = hasIntensityChanged(
            previousValue: previousStats.heartRate,
            currentValue: currentStats.heartRate,
            threshold: thresholds.heartRate
        )
        
        let calorieRateChanged = hasIntensityChanged(
            previousValue: previousStats.calorieRate,
            currentValue: currentStats.calorieRate,
            threshold: thresholds.calorieRate
        )
        
        return heartRateChanged || calorieRateChanged
    }
    
    private func createWorkoutPhase(
        startDate: Date,
        endDate: Date,
        stats: (heartRate: Double, calorieRate: Double),
        globalAverages: (heartRate: Double, calorieRate: Double)
    ) -> HealthData.WorkoutEntry {
        let intensityLevel = determineIntensityLevel(
            heartRate: stats.heartRate,
            caloriesBurnedRate: stats.calorieRate,
            globalHeartRate: globalAverages.heartRate,
            globalCaloriesBurnedRate: globalAverages.calorieRate
        )
        
        return HealthData.WorkoutEntry(
            startDate: startDate,
            endDate: endDate,
            value: intensityLevel,
            averageHeartRate: stats.heartRate,
            caloriesBurned: stats.calorieRate
        )
    }
    
    private func calculateAverageHeartRate(_ entries: [HealthData.HeartRateEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        let totalHr = entries.reduce(0.0) { $0 + $1.value }
        
        return totalHr / Double(entries.count)
    }
    
    private func calculateCaloriesBurnedRate(_ entries: [HealthData.ActivityEntry], duration: TimeInterval) -> Double {
        guard duration > 0 else { return 0 }
        let totalCalories = entries.reduce(0.0) { $0 + $1.value }
        
        return totalCalories / duration * 60
    }
    
    private func hasIntensityChanged(previousValue: Double?, currentValue: Double, threshold: Double) -> Bool {
        guard let previousValue = previousValue else { return false }
        
        return abs(previousValue - currentValue) > threshold
    }
    
    private func determineIntensityLevel(
        heartRate: Double,
        caloriesBurnedRate: Double,
        globalHeartRate: Double,
        globalCaloriesBurnedRate: Double
    ) -> IntensityLevel {
        let heartRateRatio = heartRate / globalHeartRate
        let calorieRateRatio = caloriesBurnedRate / globalCaloriesBurnedRate
        let combinedRatio = (heartRateRatio + calorieRateRatio) / 2
        
        switch combinedRatio {
        case 0..<Constants.lowIntensityThreshold:
            return .low
        case Constants.lowIntensityThreshold..<Constants.moderateIntensityThreshold:
            return .moderate
        case Constants.moderateIntensityThreshold..<Constants.highIntensityThreshold:
            return .high
        case Constants.highIntensityThreshold...:
            return .veryHigh
        default:
            return .undetermined
        }
    }
}

enum HealthKitError: Error {
    case dataProcessingFailed
    case queryFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .dataProcessingFailed:
            return "Failed to process the HealthKit data."
        case .queryFailed(let error):
            return error.localizedDescription
        }
    }
}

protocol QueryStrategy {
    associatedtype QueryType: HKQuery
    associatedtype ResultType
    
    func createQuery(for healthStore: HKHealthStore, completion: @escaping (Result<ResultType, Error>) -> Void) -> QueryType
}

protocol HealthDataFetchable {
    associatedtype Strategy: QueryStrategy
    
    var queryStrategy: Strategy { get }
    var healthStore: HKHealthStore { get }
    
    func fetchData(completion: @escaping (Result<Strategy.ResultType, Error>) -> Void)
}

extension HealthDataFetchable {
    func fetchData(completion: @escaping (Result<Strategy.ResultType, Error>) -> Void) {
        let query = queryStrategy.createQuery(for: healthStore, completion: completion)
        healthStore.execute(query)
    }
}

struct HealthSampleQueryStrategy<T>: QueryStrategy {
    typealias QueryType = HKSampleQuery
    typealias ResultType = T
    
    let sampleType: HKSampleType
    let predicate: NSPredicate?
    let limit: Int
    let sortDescriptors: [NSSortDescriptor]?
    let resultsHandler: ([HKSample]) -> T?
    
    func createQuery(for healthStore: HKHealthStore, completion: @escaping (Result<T, Error>) -> Void) -> HKSampleQuery {
        return HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { _, samples, error in
            if let error = error {
                completion(.failure(HealthKitError.queryFailed(error)))
            } else if let samples = samples, let processedResults = self.resultsHandler(samples) {
                completion(.success(processedResults))
            } else {
                completion(.failure(HealthKitError.dataProcessingFailed))
            }
        }
    }
}

struct HealthStatisticsCollectionQueryStrategy<T>: QueryStrategy {
    typealias QueryType = HKStatisticsCollectionQuery
    typealias ResultType = T
    
    let quantityType: HKQuantityType
    let anchorDate: Date
    let intervalComponents: DateComponents
    let predicate: NSPredicate?
    let options: HKStatisticsOptions
    let resultsHandler: (HKStatisticsCollection) -> T?
    
    func createQuery(for healthStore: HKHealthStore, completion: @escaping (Result<T, Error>) -> Void) -> HKStatisticsCollectionQuery {
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: options,
            anchorDate: anchorDate,
            intervalComponents: intervalComponents
        )
        
        query.initialResultsHandler = { _, results, error in
            if let error = error {
                completion(.failure(HealthKitError.queryFailed(error)))
            } else if let statisticsCollection = results, let processedResults = self.resultsHandler(statisticsCollection) {
                completion(.success(processedResults))
            } else {
                completion(.failure(HealthKitError.dataProcessingFailed))
            }
        }
        
        return query
    }
}

struct HealthStatisticsQueryStrategy<T>: QueryStrategy {
    typealias QueryType = HKStatisticsQuery
    typealias ResultType = T
    
    let quantityType: HKQuantityType
    let predicate: NSPredicate?
    let options: HKStatisticsOptions
    let resultsHandler: (HKStatistics) -> T?
    
    func createQuery(for healthStore: HKHealthStore, completion: @escaping (Result<T, Error>) -> Void) -> HKStatisticsQuery {
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: options
        ) { _, result, error in
            if let error = error {
                completion(.failure(HealthKitError.queryFailed(error)))
            } else if let statistics = result, let processedResults = self.resultsHandler(statistics) {
                completion(.success(processedResults))
            } else {
                completion(.failure(HealthKitError.dataProcessingFailed))
            }
        }
        
        return query
    }
}

struct CalorieBurnedQueryStrategy: QueryStrategy {
    typealias QueryType = HKQuery
    typealias ResultType = [PeriodEntry<HealthData.ActivityEntry>]
    
    private let collectionStatictics: HealthStatisticsCollectionQueryStrategy<ResultType>?
    private let collectionSample: HealthSampleQueryStrategy<ResultType>?
    
    init(collectionStatictics: HealthStatisticsCollectionQueryStrategy<ResultType>) {
        self.collectionStatictics = collectionStatictics
        self.collectionSample = nil
    }
    
    init(collectionSample: HealthSampleQueryStrategy<ResultType>) {
        self.collectionStatictics = nil
        self.collectionSample = collectionSample
    }
    
    func createQuery(for healthStore: HKHealthStore, completion: @escaping (Result<ResultType, Error>) -> Void) -> HKQuery {
        if let collectionStatictics = collectionStatictics {
            return collectionStatictics.createQuery(for: healthStore, completion: completion)
        } else if let collectionSample = collectionSample {
            return collectionSample.createQuery(for: healthStore, completion: completion)
        } else {
            fatalError("Neither collection nor single strategy is set")
        }
    }
}


class CalorieBurnedDataManager: HealthDataFetchable {
    typealias Strategy = CalorieBurnedQueryStrategy
    
    let healthStore: HKHealthStore
    let queryStrategy: Strategy
    
    init(healthStore: HKHealthStore, retrieveDataFrom startDate: Date) {
        self.healthStore = healthStore
        self.queryStrategy = CalorieBurnedQueryStrategy(
            collectionStatictics:
                HealthStatisticsCollectionQueryStrategy<[PeriodEntry<HealthData.ActivityEntry>]>(
                    quantityType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                    anchorDate: Calendar.current.startOfDay(for: startDate),
                    intervalComponents: DateComponents(hour: 1),
                    predicate: nil,
                    options: .cumulativeSum,
                    resultsHandler: { statisticsCollection in
                        return HealthDataProcessor.groupActivitiesByDay(from: statisticsCollection, startDate: startDate, unit: HKUnit.kilocalorie())
                    }
                )
        )
    }
    
    init(healthStore: HKHealthStore, retrieveDataFrom startDate: Date, to endDate: Date) {
        self.healthStore = healthStore
        self.queryStrategy = CalorieBurnedQueryStrategy(
            collectionSample:
                HealthSampleQueryStrategy<[PeriodEntry<HealthData.ActivityEntry>]>(
                    sampleType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                    predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)],
                    resultsHandler: { samples in
                        let activities = samples.compactMap { sample -> HealthData.ActivityEntry? in
                            guard let quantitySample = sample as? HKQuantitySample else {
                                return nil
                            }
                            
                            let caloriesBurned = quantitySample.quantity.doubleValue(for: HKUnit.kilocalorie())
                            
                            return HealthData.ActivityEntry(
                                startDate: quantitySample.startDate,
                                endDate: quantitySample.endDate,
                                value: caloriesBurned,
                                unit: HKUnit.kilocalorie().unitString
                            )
                        }
                        
                        return [PeriodEntry(entries: activities)]
                    }
                )
        )
    }
}

class StepDataManager: HealthDataFetchable {
    typealias Strategy = HealthStatisticsCollectionQueryStrategy<[PeriodEntry<HealthData.ActivityEntry>]>
    
    let healthStore: HKHealthStore
    let queryStrategy: Strategy
    
    init(healthStore: HKHealthStore, retrieveDataFrom startDate: Date) {
        self.healthStore = healthStore
        self.queryStrategy = HealthStatisticsCollectionQueryStrategy(
            quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            anchorDate: Calendar.current.startOfDay(for: startDate),
            intervalComponents: DateComponents(hour: 1),
            predicate: nil,
            options: .cumulativeSum,
            resultsHandler: { statisticsCollection in
                return HealthDataProcessor.groupActivitiesByDay(from: statisticsCollection, startDate: startDate, unit: HKUnit.count())
            }
        )
    }
}

class WeightDataManager: HealthDataFetchable {
    typealias Strategy = HealthSampleQueryStrategy<[PeriodEntry<HealthData.WeightEntry>]>
    
    let healthStore: HKHealthStore
    let queryStrategy: Strategy
    
    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
        self.queryStrategy = HealthSampleQueryStrategy(
            sampleType: HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
            predicate: HKQuery.predicateForSamples(withStart: nil, end: Date(), options: .strictEndDate),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)],
            resultsHandler: { samples in
                return HealthDataProcessor.groupWeightsByWeek(from: samples, unit: .gramUnit(with: .kilo))
            }
        )
    }
}

class SleepDataManager: HealthDataFetchable {
    typealias Strategy = HealthSampleQueryStrategy<[PeriodEntry<HealthData.SleepEntry>]>
    
    let healthStore: HKHealthStore
    let queryStrategy: Strategy
    
    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
        self.queryStrategy = HealthSampleQueryStrategy(
            sampleType: HKQuantityType.categoryType(forIdentifier: .sleepAnalysis)!,
            predicate: HKQuery.predicateForSamples(withStart: nil, end: Date(), options: .strictEndDate),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)],
            resultsHandler: { samples in
                return HealthDataProcessor.groupSleepByNight(from: samples)
            }
        )
    }
}

class WorkoutDataManager: HealthDataFetchable {
    typealias Strategy = HealthSampleQueryStrategy<[PeriodEntry<HealthData.WorkoutEntry>]>
    
    let healthStore: HKHealthStore
    let queryStrategy: Strategy
    
    init(healthStore: HKHealthStore, retrieveDataFrom startDate: Date) {
        self.healthStore = healthStore
        self.queryStrategy = HealthSampleQueryStrategy(
            sampleType: HKObjectType.workoutType(),
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)],
            resultsHandler: { samples in
                
                for sample in samples {
                    HeartRateDataManager(healthStore: healthStore, retrieveDataFrom: sample.startDate, to: sample.endDate).fetchData { heartRates in
                        //guard let avgHeartRate = try? avgHeartRate.get() else { return }
                        CalorieBurnedDataManager(healthStore: healthStore, retrieveDataFrom: sample.startDate, to: sample.endDate).fetchData { calorieBurned in
                            var heartRatesT: [HealthData.HeartRateEntry] = []
                            var caloriesBurnedTmp: [HealthData.ActivityEntry] = []
                            
                            print("Workout: \(sample.startDate) - \(sample.endDate)")
                            switch heartRates {
                            case .success(let entries):
                                heartRatesT = entries.entries
                                //print("Average HeartRate: \(entries)")
                            case .failure(let error):
                                print("no heart rate data: \(error)")
                            }
                            switch calorieBurned {
                            case .success(let entries):
                                caloriesBurnedTmp = entries.first!.entries
                                //print("Average Calorie Burned: \(entries)")
                            case .failure(let error):
                                print("no calorie burned data: \(error)")
                            }
                            let t = WorkoutIntensityAnalyzer().generateIntensityPhases(workout: sample, heartRates: heartRatesT, caloriesBurned: caloriesBurnedTmp)
                            t.forEach { workout in
                                print(workout.value)
                            }
                            print("--------------------------------")
                        }
                    }
                }
                return []
            }
        )
    }
}

class HeartRateDataManager: HealthDataFetchable {
    typealias Strategy = HealthSampleQueryStrategy<PeriodEntry<HealthData.HeartRateEntry>>
    
    let healthStore: HKHealthStore
    let queryStrategy: Strategy
    
    init(healthStore: HKHealthStore, retrieveDataFrom startDate: Date, to endDate: Date) {
        self.healthStore = healthStore
        self.queryStrategy = HealthSampleQueryStrategy(
            sampleType: HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)],
            resultsHandler: { samples in
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                
                let heartRateEntries: [HealthData.HeartRateEntry] = samples.compactMap { sample in
                    guard let quantitySample = sample as? HKQuantitySample else { return nil }
                    let heartRateValue = quantitySample.quantity.doubleValue(for: heartRateUnit)
                    
                    return HealthData.HeartRateEntry(
                        startDate: quantitySample.startDate,
                        endDate: quantitySample.endDate,
                        value: heartRateValue
                    )
                }
                
                let heartRates = PeriodEntry<HealthData.HeartRateEntry>(entries: heartRateEntries)
                
                return heartRates
            }
        )
    }
}

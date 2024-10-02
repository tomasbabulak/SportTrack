//
//  HomeViewModel.swift
//  SportTrack
//
//  Created by Tomas on 30.09.2024.
//

import Foundation
import SwiftData
import SwiftUI
import SwiftNavigation
import Dependencies

@Observable
final class HomeViewModel {
    @ObservationIgnored
    @Dependency(DatabaseService.self) var databaseService
    @ObservationIgnored
    @Dependency(NetworkService.self) var networkService

    var destination: Destination?

    @CasePathable
    enum Destination {
        case createWorkout(CreateWorkoutViewModel)
        case loading
    }

    enum WorkoutSelection: Int, CaseIterable {
        case all, cloud, local

        var description: String {
            switch self {
            case .all:
                return "All"
            case .cloud:
                return "Cloud"
            case .local:
                return "Local"
            }
        }
    }

    private var workouts: [Workout] = []
    var fileteredWorkouts: [Workout] {
        switch selection {
        case .all:
            return workouts
        case .cloud:
            return workouts.filter { $0.storage == .cloud }
        case .local:
            return workouts.filter { $0.storage == .local }
        }
    }

    var selection: WorkoutSelection = .all

    var isLoading: Bool {
        switch destination {
        case .loading:
            return true
        default:
            return false
        }
    }

    func task() async {
        await MainActor.run { destination = .loading }
        await fetchLocations()
        await MainActor.run { destination = nil }
    }

    func fetchLocations() async {
        databaseService.reloadAllFetched()
        let databaseWorkouts = databaseService.workouts
        let cloudWorkouts: [Workout]
        do {
            cloudWorkouts = try await networkService.getWorkouts()
        } catch {
            NSLog("Error while fetching workouts: \(error.localizedDescription)")
            // TODO: Handle errors
            cloudWorkouts = []
        }

        workouts = (databaseWorkouts + cloudWorkouts).sorted(by: { $0.timestamp > $1.timestamp })
    }

    func addItemTapped() {
        destination = .createWorkout(
            CreateWorkoutViewModel(resultHandler: { [weak self] in await self?.createWorkoutResultHandler($0) })
        )
    }

    func createWorkoutResultHandler(_ handler: CreateWorkoutViewModel.WorkoutResultHandler) async {
        switch handler {
        case .created:
            await fetchLocations()
        case .cancelled:
            break
        }
        await MainActor.run { destination = nil }
    }

    func deleteItems(offsets: IndexSet) async {
        for index in offsets {
            let workout = workouts[index]
            do {
                switch workout.storage {
                case .cloud:
                    try await networkService.deleteWorkouts(workout: workout)
                case .local:
                    try databaseService.remove(workout: workout)
                    databaseService.reloadAllFetched()
                }
            } catch {
                NSLog("Could not delete workout: \(error)")
                // TODO: Handle errors
            }
        }
        await fetchLocations()
    }
}

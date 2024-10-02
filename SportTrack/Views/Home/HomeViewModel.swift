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
    @Dependency(StorageService.self) var storageService

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
        do {
            workouts = try await storageService.getAll()
        } catch {
            NSLog("Could not fetch workouts: \(error)")
        }
    }

    func addItemTapped() {
        destination = .createWorkout(
            CreateWorkoutViewModel(resultHandler: { [weak self] in
                await self?.createWorkoutResultHandler($0)
            })
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
                try await storageService.store(workout: workout)
            } catch {
                NSLog("Could not delete workout: \(error)")
                // TODO: Handle errors
            }
        }
        await fetchLocations()
    }
}

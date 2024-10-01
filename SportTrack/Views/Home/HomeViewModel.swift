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

    var destination: Destination?

    @CasePathable
    enum Destination {
        case createWorkout(CreateWorkoutViewModel)
    }

    private(set) var workouts: [Workout] = []

    init() {
        fetchLocations()
    }

    func fetchLocations() {
        workouts = databaseService.workouts
    }

    func addItemTapped() {
        destination = .createWorkout(
            CreateWorkoutViewModel(resultHandler: { [weak self] in self?.createWorkoutResultHandler($0) })
        )
    }

    func createWorkoutResultHandler(_ handler: CreateWorkoutViewModel.WorkoutResultHandler) {
        switch handler {
        case let .created(workout) where workout.storage == .cloud:
        case let .created(workout):
            databaseService.add(workout: workout)
            fetchLocations()
        case .cancelled:
            break
        }
        destination = nil
    }

    func deleteItems(offsets: IndexSet) {
        for index in offsets {
            databaseService.remove(workout: workouts[index])
        }
        fetchLocations()
    }
}

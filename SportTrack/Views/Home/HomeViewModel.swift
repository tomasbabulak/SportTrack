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

@Observable
final class HomeViewModel {
    var destination: Destination?

    @CasePathable
    enum Destination {
        case createWorkout(CreateWorkoutViewModel)
    }

    private(set) var workouts: [Workout] = []
    let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        fetchLocations()
    }

    func fetchLocations() {
        workouts = dependencies.databaseService.workouts
    }

    func addItemTapped() {
        destination = .createWorkout(
            CreateWorkoutViewModel(resultHandler: { [weak self] in self?.createWorkoutResultHandler($0) })
        )
    }

    func createWorkoutResultHandler(_ handler: CreateWorkoutViewModel.WorkoutResultHandler) {
        switch handler {
        case let .created(workout, type) where type == .cloud:
            dependencies.databaseService.add(workout: workout)
            fetchLocations()
        case let .created(workout, _):
            dependencies.databaseService.add(workout: workout)
            fetchLocations()
        case .cancelled:
            break
        }
        destination = nil
    }

    func deleteItems(offsets: IndexSet) {
        for index in offsets {
            dependencies.databaseService.remove(workout: workouts[index])
        }
        fetchLocations()
    }

//    func     var backgroundColor: Color {
//        switch storageType {
//        case .local:
//            return .gray.opacity(0.2)
//        case .cloud:
//            return .blue.opacity(0.2)
//        }
//    }

}

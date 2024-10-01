//
//  CreateWorkoutViewModel.swift
//  SportTrack
//
//  Created by Tomas on 30.09.2024.
//

import SwiftUI

@Observable
final class CreateWorkoutViewModel: Identifiable {
    enum WorkoutResultHandler {
        case cancelled
        case created(Workout, StorageType)
    }

    let resultHandler: (WorkoutResultHandler) -> Void

    init(resultHandler: @escaping (WorkoutResultHandler) -> Void) {
        self.resultHandler = resultHandler
    }
}

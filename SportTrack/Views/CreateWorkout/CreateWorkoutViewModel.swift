//
//  CreateWorkoutViewModel.swift
//  SportTrack
//
//  Created by Tomas on 30.09.2024.
//

import SwiftUI
import SwiftUINavigation
import Dependencies

@Observable
final class CreateWorkoutViewModel: Identifiable {
    let id: UUID = UUID()
    @ObservationIgnored
    @Dependency(\.date.now) var now
    @ObservationIgnored
    @Dependency(\.uuid) var uuid

    var destination: Destination?

    @CasePathable
    enum Destination {
      case locationAlert
    }

    enum WorkoutResultHandler {
        case cancelled
        case created(Workout)
    }

    let resultHandler: (WorkoutResultHandler) -> Void

    var location: String = ""
    var selectedHours: Int = 0
    var selectedMinutes: Int = 0
    var isCloud: Bool = false

    let hoursRange: [Int] = Array(0...23)
    let minutesRange: [Int] = Array(0...59)

    init(resultHandler: @escaping (WorkoutResultHandler) -> Void) {
        self.resultHandler = resultHandler
    }

    func saveTapped() {
        guard
            !location.isEmpty
        else {
            destination = .locationAlert
            return
        }
        let workout = Workout(
            id: uuid(),
            timestamp: now,
            location: location,
            duration: .seconds(selectedHours * 3600 + selectedMinutes * 60),
            storage: isCloud ? .cloud : .local
        )
        resultHandler(.created(workout))
    }

    func cancelTapped() {
        resultHandler(.cancelled)
    }
}

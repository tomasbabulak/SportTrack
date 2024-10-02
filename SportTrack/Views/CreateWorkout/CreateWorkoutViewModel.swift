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
    @ObservationIgnored
    @Dependency(StorageService.self) var storageService

    var destination: Destination?

    @CasePathable
    enum Destination {
        case locationAlert
        case failure
        case loading
    }

    enum WorkoutResultHandler {
        case cancelled
        case created
    }

    let resultHandler: (WorkoutResultHandler) async -> Void

    var location: String = ""
    var selectedHours: Int = 0
    var selectedMinutes: Int = 0
    var isCloud: Bool = false

    let hoursRange: [Int] = Array(0...23)
    let minutesRange: [Int] = Array(0...59)

    init(resultHandler: @escaping (WorkoutResultHandler) async -> Void) {
        self.resultHandler = resultHandler
    }

    func saveTapped() async {
        guard
            !location.isEmpty
        else {
            await MainActor.run { destination = .locationAlert }
            return
        }
        let workout = Workout(
            id: uuid(),
            timestamp: now,
            location: location,
            duration: .seconds(selectedHours * 3600 + selectedMinutes * 60),
            storage: isCloud ? .cloud : .local
        )
        await createWorkout(workout: workout)
    }

    func cancelTapped() async {
        await resultHandler(.cancelled)
    }

    func createWorkout(workout: Workout) async {
        do {
            await MainActor.run { destination = .loading }
            try await storageService.store(workout: workout)
            await resultHandler(.created)
        } catch {
            NSLog("Could not create workout: \(error)")
            await MainActor.run { destination = .failure }
        }
    }
}

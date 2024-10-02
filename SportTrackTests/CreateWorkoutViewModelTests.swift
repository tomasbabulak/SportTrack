//
//  WorkoutViewModelTests.swift
//  SportTrackTests
//
//  Created by Tomas on 02.10.2024.
//

import Testing
import Dependencies
import Foundation
@testable import SportTrack

@Suite("Save Workout")
struct CreateWorkoutViewModelTests {
    @Test
    func saveWithEmptyFields() async throws {
        let model = withDependencies {
            $0.uuid = .constant(UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
            $0.date.now = Date(timeIntervalSinceReferenceDate: 1234567890)
            $0[StorageService.self] = StorageService(databaseService: DatabaseServiceMock(), networkService: NetworkServiceMock())
        } operation: {
            CreateWorkoutViewModel(resultHandler: { _ in })
        }

        await model.saveTapped()

        #expect(model.destination == .inputWarning)

        model.destination = nil
        model.workoutType = "Run"
        await model.saveTapped()

        #expect(model.destination == .inputWarning)

        model.destination = nil
        model.location = "Brno"
        await model.saveTapped()

        #expect(model.destination == nil)
    }

    @Test
    func saveWithSuccess() async throws {
        var resultHandler: CreateWorkoutViewModel.WorkoutResultHandler?
        var savedWorkout: Workout?

        let databaseService = DatabaseServiceMock()
        databaseService.addHandler = { savedWorkout = $0 }
        let model = withDependencies {
            $0.uuid = .constant(UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
            $0.date.now = Date(timeIntervalSinceReferenceDate: 1234567890)
            $0[StorageService.self] = StorageService(databaseService: databaseService, networkService: NetworkServiceMock())
        } operation: {
            CreateWorkoutViewModel(resultHandler: { resultHandler = $0 })
        }

        model.workoutType = "Run"
        model.location = "Brno"
        model.selectedHours = 1
        model.selectedMinutes = 31
        model.isCloud = false

        await model.saveTapped()

        #expect(model.destination == nil)
        #expect(
            savedWorkout == Workout(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                timestamp: Date(timeIntervalSinceReferenceDate: 1234567890),
                type: "Run",
                location: "Brno",
                duration: .seconds(1 * 3600 + 31 * 60),
                storage: .local
            )
        )
        #expect(resultHandler == .created)
    }

    @Test
    func saveWithFailure() async throws {
        var resultHandler: CreateWorkoutViewModel.WorkoutResultHandler?

        let databaseService = DatabaseServiceMock()
        databaseService.addHandler = { _ in throw TestError.error }
        let model = withDependencies {
            $0.uuid = .constant(UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
            $0.date.now = Date(timeIntervalSinceReferenceDate: 1234567890)
            $0[StorageService.self] = StorageService(databaseService: databaseService, networkService: NetworkServiceMock())
        } operation: {
            CreateWorkoutViewModel(resultHandler: { resultHandler = $0 })
        }

        model.workoutType = "Run"
        model.location = "Brno"
        model.selectedHours = 1
        model.selectedMinutes = 31

        await model.saveTapped()

        #expect(model.destination == .failure)
        #expect(resultHandler == nil)
    }
}

@Suite("Cancel Workout Creating")
struct CancelWorkoutViewModelTests {
    @Test
    func cancel() async throws {
        var resultHandler: CreateWorkoutViewModel.WorkoutResultHandler?
        let model = CreateWorkoutViewModel(resultHandler: { resultHandler = $0 })

        await model.cancelTapped()

        #expect(resultHandler == .cancelled)
    }
}

@Suite("Textfield Sumbit")
struct TextfieldWorkoutViewModelTests {
    @Test
    func focus() async throws {
        let model = CreateWorkoutViewModel(resultHandler: { _ in })

        model.formFocus = .workoutType
        // First text field submit should change to location
        model.textFieldSubmitTapped()

        #expect(model.formFocus == .location)

        // Second time keyboard should be defocussed
        model.textFieldSubmitTapped()

        #expect(model.formFocus == nil)
    }
}

//
//  DatabaseService.swift
//  SportTrack
//
//  Created by Tomas on 01.10.2024.
//

import Foundation
import SwiftData

@Model
class DatabaseWorkout {
    var localId: UUID
    /// Workout created
    var timestamp: Date
    /// Location
    var location: String
    /// Duration in seconds
    var duration: Int

    init(localId: UUID, timestamp: Date, location: String, duration: Int) {
        self.localId = localId
        self.timestamp = timestamp
        self.location = location
        self.duration = duration
    }

    init(from workout: Workout) {
        self.localId = workout.id
        self.timestamp = workout.timestamp
        self.location = workout.location
        self.duration = Int(workout.duration.components.seconds)
    }
}

protocol DatabaseServiceProtocol {
    var workouts: [Workout] { get }

    func add(_ workout: Workout) throws
    func remove(_ workout: Workout) throws
    func reloadAllFetched() throws
}

final class DatabaseService: DatabaseServiceProtocol {
    private var container: ModelContainer
    private var context: ModelContext

    private var databaseWorkouts: [DatabaseWorkout] = []

    var workouts: [Workout] {
        databaseWorkouts.map {
            Workout(
                id: $0.localId,
                timestamp: $0.timestamp,
                location: $0.location,
                duration: Duration.seconds($0.duration),
                storage: .local
            )
        }
    }

    init() {
        let sharedModelContainer: ModelContainer = {
            let schema = Schema([
                DatabaseWorkout.self,
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()

        self.container = sharedModelContainer
        self.context = ModelContext(container)
    }

    func reloadAllFetched() throws {
        let fetchDescriptor = FetchDescriptor<DatabaseWorkout>(
            sortBy: [SortDescriptor(\.timestamp)]
        )
        let workouts = try context.fetch(fetchDescriptor)
        databaseWorkouts = workouts
    }

    func add(_ workout: Workout) throws {
        context.insert(DatabaseWorkout(from: workout))
        try context.save()
    }

    func remove(_ workout: Workout) throws {
        guard let databaseWorkout = databaseWorkouts.first(where: { $0.localId == workout.id }) else {
            assertionFailure("Could not find database workout!")
            return
        }
        context.delete(databaseWorkout)
        try context.save()
    }
}

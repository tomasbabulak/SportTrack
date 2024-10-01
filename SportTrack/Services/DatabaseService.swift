//
//  DatabaseService.swift
//  SportTrack
//
//  Created by Tomas on 01.10.2024.
//

import Foundation
import SwiftData
import Dependencies

extension DatabaseService: DependencyKey {
  static let liveValue = DatabaseService()
}

final class DatabaseService {
    @Model
    class DatabaseWorkout {
        var id: UUID
        /// Workout created
        var timestamp: Date
        /// Location
        var location: String
        /// Duration in seconds
        var duration: Int

        init(id: UUID, timestamp: Date, location: String, duration: Int) {
            self.id = id
            self.timestamp = timestamp
            self.location = location
            self.duration = duration
        }

        init(from workout: Workout) {
            self.id = workout.id
            self.timestamp = workout.timestamp
            self.location = workout.location
            self.duration = Int(workout.duration.components.seconds)
        }
    }

    private var container: ModelContainer
    private var context: ModelContext

    var workouts: [Workout] {
        let fetchDescriptor = FetchDescriptor<DatabaseWorkout>(
            sortBy: [SortDescriptor(\.timestamp)]
        )
        return ((try? context.fetch(fetchDescriptor)) ?? []).map {
            Workout(
                id: $0.id,
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

    func add(workout: Workout) {
        context.insert(DatabaseWorkout(from: workout))
    }

    func remove(workout: Workout) {
        context.delete(DatabaseWorkout(from: workout))
    }
}

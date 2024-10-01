//
//  DatabaseService.swift
//  SportTrack
//
//  Created by Tomas on 01.10.2024.
//

import Foundation
import SwiftData

protocol DatabaseService {
    var workouts: [Workout] { get }

    func add(workout: Workout)
    func remove(workout: Workout)
}

final class ProductionDatabaseService: DatabaseService {
    var container: ModelContainer
    var context: ModelContext

    var workouts: [Workout] {
        let fetchDescriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\.timestamp)]
        )
        return (try? context.fetch(fetchDescriptor)) ?? []
    }

    init() {
        let sharedModelContainer: ModelContainer = {
            let schema = Schema([
                Workout.self,
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
        context.insert(workout)
    }

    func remove(workout: Workout) {
        context.delete(workout)
    }
}

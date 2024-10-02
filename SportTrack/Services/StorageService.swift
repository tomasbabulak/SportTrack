//
//  StorageService.swift
//  SportTrack
//
//  Created by Tomas on 02.10.2024.
//

import Foundation
import Dependencies

extension StorageService: DependencyKey {
    static let liveValue = StorageService(
        databaseService: DatabaseService(),
        networkService: NetworkService()
    )
}

final class StorageService {
    private let databaseService: DatabaseServiceProtocol
    private let networkService: NetworkServiceProtocol

    init(databaseService: DatabaseServiceProtocol, networkService: NetworkServiceProtocol) {
        self.databaseService = databaseService
        self.networkService = networkService
    }

    func store(workout: Workout) async throws {
        switch workout.storage {
        case .cloud:
            try await networkService.create(workout)
        case .local:
            try databaseService.add(workout)
        }
    }

    func remove(workout: Workout) async throws {
        switch workout.storage {
        case .cloud:
            try await networkService.delete(workout)
        case .local:
            try databaseService.remove(workout)
        }
    }

    func getAll() async throws -> [Workout] {
        try databaseService.reloadAllFetched()
        let databaseWorkouts = databaseService.workouts
        let cloudWorkouts = try await networkService.getWorkouts()

        return (databaseWorkouts + cloudWorkouts).sorted(by: { $0.timestamp > $1.timestamp })
    }
}

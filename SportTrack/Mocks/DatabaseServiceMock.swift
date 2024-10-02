//
//  StorageServiceMock.swift
//  SportTrack
//
//  Created by Tomas on 02.10.2024.
//

import Foundation

final class DatabaseServiceMock: DatabaseServiceProtocol {
    var workouts: [Workout] = [
        Workout(id: UUID(), timestamp: Date(), type: "Walk", location: "Brno", duration: .seconds(60*60), storage: .local),
        Workout(id: UUID(), timestamp: Date(), type: "Bike", location: "Prague", duration: .seconds(30*60), storage: .local),
    ]

    var addHandler: ((_ workout: Workout) throws -> Void)?
    func add(_ workout: Workout) throws {
        try addHandler?(workout)
    }

    func remove(_ workout: Workout) throws {  }

    func reloadAllFetched() throws { }
}

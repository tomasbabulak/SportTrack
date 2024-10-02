//
//  NetworkServiceMock.swift
//  SportTrack
//
//  Created by Tomas on 02.10.2024.
//

import Foundation

final class NetworkServiceMock: NetworkServiceProtocol {
    func getWorkouts() async throws -> [Workout] {
        [
            Workout(id: UUID(), timestamp: Date(), type: "Run", location: "Brno", duration: .seconds(60*60), storage: .cloud),
            Workout(id: UUID(), timestamp: Date(), type: "Swim", location: "Prague", duration: .seconds(30*60), storage: .cloud),
        ]
    }

    func create(_ workout: Workout) async throws { }

    func delete(_ workout: Workout) async throws { }
}

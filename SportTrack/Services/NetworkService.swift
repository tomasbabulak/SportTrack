//
//  NetworkService.swift
//  SportTrack
//
//  Created by Tomas on 01.10.2024.
//

import Foundation
import Firebase
import FirebaseFirestore

struct ApiWorkout: Codable {
    /// Workout created
    var timestamp: Date
    /// Workout type
    var type: String
    /// Location
    var location: String
    /// Duration in seconds
    var duration: Int
}

protocol NetworkServiceProtocol {
    func getWorkouts() async throws -> [Workout]
    func create(_ workout: Workout) async throws
    func delete(_ workout: Workout) async throws
}

final class NetworkService: NetworkServiceProtocol {
    let deviceId = UIDevice.current.identifierForVendor!.uuidString
    let db: Firestore

    init() {
        db = Firestore.firestore()
    }

    func getWorkouts() async throws -> [Workout] {
        let snapshot = try await workoutsColletion()
            .getDocuments()

        return try snapshot
            .documents
            .map { ($0.documentID, try $0.data(as: ApiWorkout.self)) }
            .map {
                Workout(
                    id: UUID(uuidString: $0) ?? UUID(),
                    timestamp: $1.timestamp,
                    type: $1.type,
                    location: $1.location,
                    duration: .seconds($1.duration),
                    storage: .cloud
                )
            }
    }

    func create(_ workout: Workout) async throws {
        let apiWorkout = ApiWorkout(
            timestamp: workout.timestamp,
            type: workout.type,
            location: workout.location,
            duration: Int(workout.duration.components.seconds)
        )
        try workoutsColletion()
            .document(workout.id.uuidString)
            .setData(from: apiWorkout)
    }

    func delete(_ workout: Workout) async throws {
        try await workoutsColletion()
            .document(workout.id.uuidString)
            .delete()
    }

    private func workoutsColletion() -> CollectionReference {
        db
            .collection("users")
            .document(deviceId)
            .collection("workouts")
    }
}

//
//  NetworkService.swift
//  SportTrack
//
//  Created by Tomas on 01.10.2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import Dependencies

extension NetworkService: DependencyKey {
  static let liveValue = NetworkService()
}

final class NetworkService {
    struct ApiWorkout: Codable {
        /// Workout created
        var timestamp: Date
        /// Location
        var location: String
        /// Duration in seconds
        var duration: Int
    }

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
            .map { Workout(id: UUID(uuidString: $0)!, timestamp: $1.timestamp, location: $1.location, duration: .seconds($1.duration), storage: .cloud) }
    }

    func postWorkouts(workout: Workout) async throws {
        let apiWorkout = ApiWorkout(timestamp: workout.timestamp, location: workout.location, duration: Int(workout.duration.components.seconds))
        try workoutsColletion()
            .document(workout.id.uuidString)
            .setData(from: apiWorkout)
    }

    func deleteWorkouts(workout: Workout) async throws {
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

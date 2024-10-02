//
//  Workout.swift
//  SportTrack
//
//  Created by Tomas on 30.09.2024.
//

import Foundation
import SwiftUI
import SwiftData

struct Workout: Identifiable, Equatable {
    let id: UUID
    /// Workout created
    let timestamp: Date
    /// Workout type
    var type: String
    /// Location
    let location: String
    /// Duration in seconds
    let duration: Duration
    /// Storage type
    let storage: StorageType


    var backgroundColor: Color {
        switch storage {
        case .local:
            return .gray.opacity(0.2)
        case .cloud:
            return .blue.opacity(0.2)
        }
    }
}

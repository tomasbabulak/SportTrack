//
//  Workout.swift
//  SportTrack
//
//  Created by Tomas on 30.09.2024.
//

import Foundation
import SwiftData

@Model
class Workout {
    /// Workout created
    @Attribute(.unique) var timestamp: Date
    /// Location
    var location: String
    /// Duration in seconds
    var duration: Int

    init(timestamp: Date, location: String, duration: Int) {
        self.timestamp = timestamp
        self.location = location
        self.duration = duration
    }
}

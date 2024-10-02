//
//  WorkoutCell.swift
//  SportTrack
//
//  Created by Tomas on 30.09.2024.
//

import SwiftUI

struct WorkoutCellConfiguration {
    let workout: Workout

    let timesFormat: Date.FormatStyle = {
        Date.FormatStyle(date: .numeric, time: .standard)
    }()

    let durationFormat: Duration.UnitsFormatStyle = {
        Duration.UnitsFormatStyle(allowedUnits: [.hours, .minutes, .seconds], width: .abbreviated)
    }()
}

struct WorkoutCell: View {
    let configuration: WorkoutCellConfiguration

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(configuration.workout.location)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("It took: \(configuration.workout.duration, format: configuration.durationFormat)")
                    .font(.body)

                Text("Created at \(configuration.workout.timestamp, format: configuration.timesFormat)")
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            icon
        }
        .padding()
    }

    var icon: Image {
        switch configuration.workout.storage {
        case .local:
            AppSymbol.externaldrive.body
        case .cloud:
            AppSymbol.cloud.body
        }
    }
}

#Preview {
    WorkoutCell(
        configuration: WorkoutCellConfiguration(
            workout: Workout(
                id: UUID(),
                timestamp: Date(),
                type: "Running",
                location: "Here",
                duration: .seconds(3),
                storage: .cloud
            )
        )
    )
}

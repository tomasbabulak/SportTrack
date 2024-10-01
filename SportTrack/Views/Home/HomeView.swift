//
//  HomeView.swift
//  SportTrack
//
//  Created by Tomas on 30.09.2024.
//

import SwiftUI
import SwiftData
import SwiftUINavigation

struct HomeView: View {
    @State var viewModel: HomeViewModel

    var body: some View {
        NavigationSplitView {
            content
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(
                            action: viewModel.addItemTapped,
                            label: {
                                Label("Add Item", systemImage: "plus")
                            }
                        )
                    }
                }
                .navigationTitle("Workouts")
        } detail: {
            Text("Select workout")
        }
        .overlay {
            if viewModel.workouts.isEmpty {
                noWorkoutsView
            }
        }
        .animation(.default, value: viewModel.workouts)
        .sheet(item: $viewModel.destination.createWorkout) { model in
            NavigationStack {
                CreateWorkoutView(viewModel: model)
            }
        }
    }

    @ViewBuilder
    var content: some View {
        List {
            ForEach(viewModel.workouts) { workout in
                WorkoutCell(
                    configuration: WorkoutCellConfiguration(
                        workout: workout
                    )
                )
                .listRowBackground(workout.backgroundColor)
            }
            .onDelete(perform: viewModel.deleteItems)
        }
    }

    @ViewBuilder
    var noWorkoutsView: some View {
        ContentUnavailableView {
            Text("No workouts!")
        } description: {
            Text("Seems you dont have any workout saved yet.")
        } actions: {
            Button(
                action: viewModel.addItemTapped,
                label: { Text("Create Workout") }
            )
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel()
    )
}

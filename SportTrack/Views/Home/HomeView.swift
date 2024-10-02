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
                    ToolbarItem(placement: .primaryAction) {
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
            if viewModel.fileteredWorkouts.isEmpty {
                noWorkoutsView
            }
        }
        .animation(.default, value: viewModel.fileteredWorkouts)
        .sheet(item: $viewModel.destination.createWorkout) { model in
            NavigationStack {
                CreateWorkoutView(viewModel: model)
            }
        }
        .task { await viewModel.task() }
    }

    @ViewBuilder
    private var content: some View {
        VStack {
            Picker("Workout selection", selection: $viewModel.selection) {
                ForEach(HomeViewModel.WorkoutSelection.allCases, id: \.self) { selection in
                    Text(selection.description).tag(selection)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            List {
                ForEach(viewModel.fileteredWorkouts) { workout in
                    WorkoutCell(
                        configuration: WorkoutCellConfiguration(
                            workout: workout
                        )
                    )
                    .listRowBackground(workout.backgroundColor)
                }
                .onDelete(perform: { offset in Task { await viewModel.deleteItems(offsets: offset) } })
            }
        }
    }

    @ViewBuilder
    private var noWorkoutsView: some View {
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

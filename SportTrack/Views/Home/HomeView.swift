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
        .overlay(content: {
            if viewModel.isLoading {
                loadingView
            }
        })
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
            .refreshable {
                await viewModel.fetchLocations()
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

    private var loadingView: some View {
        ProgressView { Text("Loading data...") }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel()
    )
}

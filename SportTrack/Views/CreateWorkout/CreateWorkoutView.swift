//
//  CreateWorkoutView.swift
//  SportTrack
//
//  Created by Tomas on 30.09.2024.
//

import SwiftUI
import SwiftUINavigation

struct CreateWorkoutView: View {
    @State var viewModel: CreateWorkoutViewModel
    @FocusState private var focus: CreateWorkoutViewModel.FormFocus?

    var body: some View {
        Form {
            TextField("Workout Type", text: $viewModel.workoutType)
                .submitLabel(.next)
                .focused($focus, equals: .workoutType)

            TextField("Location", text: $viewModel.location)
                .submitLabel(.done)
                .focused($focus, equals: .workoutType)

            durationPicker

            storageTypePicker
        }
        .onSubmit {
            viewModel.textFieldSubmitTapped()
        }
        .bind($viewModel.formFocus, to: $focus)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    Task { await viewModel.saveTapped() }
                }, label: {
                    Text("Save")
                })
            }

            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    Task { await viewModel.cancelTapped() }
                }, label: {
                    Text("Cancel")
                })
            }
        }
        .navigationTitle("New Workout")
        .alert(
            "Missing fields",
            isPresented: Binding($viewModel.destination.inputWarning),
            actions: {
                Button("Okay", role: .cancel) { }
            },
            message: {
                Text("All fields need to be filled out.")
            }
        )
        .alert(
            "Could not save workout",
            isPresented: Binding($viewModel.destination.failure),
            actions: {
                Button("Cancel", role: .cancel) { }
                Button("Retry") { Task { await viewModel.saveTapped() } }
            },
            message: {
                Text("Workout could not be saved.")
            }
        )
        .overlay(content: {
            if viewModel.destination == .loading {
                loadingView
            }
        })
        .animation(.default, value: viewModel.destination)
    }

    @ViewBuilder
    private var durationPicker: some View {
        VStack(alignment: .leading) {
            Text("Enter Duration")
                .font(.subheadline)

            HStack {
                Picker(selection: $viewModel.selectedHours, label: Text("Selected hours")) {
                    ForEach(viewModel.hoursRange, id: \.self) { hour in
                        Text("\(hour) h")
                            .tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())

                Picker(selection: $viewModel.selectedMinutes, label: Text("Selected minutes")) {
                    ForEach(viewModel.minutesRange, id: \.self) { minute in
                        Text("\(minute) min")
                            .tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
        }
    }

    private var storageTypePicker: some View {
        VStack {
            Toggle(
                isOn: $viewModel.isCloud,
                label: {
                    Text("Store in cloud")
                }
            )
            Text("If you store in cloud, your workout will backed up to the cloud. Otherwise, it will be stored locally.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var loadingView: some View {
        ProgressView { Text("Saving...") }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        CreateWorkoutView(viewModel: CreateWorkoutViewModel(resultHandler: { _ in }))
    }
}

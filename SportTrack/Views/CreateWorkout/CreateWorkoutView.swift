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

    var body: some View {
        Form {
            TextField("Enter Location", text: $viewModel.location)

            durationPicker

            storageTypePicker
        }
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
            "Missing Location",
            isPresented: Binding($viewModel.destination.locationAlert),
            actions: {
                Button("Okay", role: .cancel) { }
            },
            message: {
                Text("A workout must have a location.")
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
        Toggle(
            isOn: $viewModel.isCloud,
            label: {
                Text("Store in cloud")
            }
        )
    }

    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.5)
            ProgressView() { Text("Uploading") }
        }
    }
}

#Preview {
    NavigationStack {
        CreateWorkoutView(viewModel: CreateWorkoutViewModel(resultHandler: { _ in }))
    }
}

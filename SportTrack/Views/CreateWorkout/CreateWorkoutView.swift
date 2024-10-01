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
        }
    }
}

#Preview {
    NavigationStack {
        CreateWorkoutView(viewModel: CreateWorkoutViewModel(resultHandler: { _ in }))
    }
}

//
//  SportTrackApp.swift
//  SportTrack
//
//  Created by Tomas on 30.09.2024.
//

import SwiftUI
import SwiftData

@main
struct SportTrackApp: App {
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel())
        }
    }
}

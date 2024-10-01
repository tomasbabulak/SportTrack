//
//  AppSymbol.swift
//  SportTrack
//
//  Created by Tomas on 30.09.2024.
//

import SwiftUI

enum AppSymbol: String, View {
    case cloud = "cloud"
    case externaldrive = "externaldrive"

    var body: Image {
        Image(systemName: rawValue)
    }
}

#if DEBUG
extension AppSymbol: CaseIterable { }

#Preview {
    VStack {
        ForEach(AppSymbol.allCases, id: \.rawValue) { $0 }
    }
}
#endif

//
//  BeneathTheSurfaceApp.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/14/25.
//

import SwiftUI

@main
struct BeneathTheSurfaceApp: App {
    @Environment(\.colorScheme) var systemColorScheme
    
    var body: some Scene {
            WindowGroup {
                ExpandableListView()
                    .environment(\.colorTheme,
                                 systemColorScheme == .dark ? .dark : .light)
            }
        }
}

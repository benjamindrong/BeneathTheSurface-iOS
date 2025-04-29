//
//  Font.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/29/25.
//

import SwiftUI

struct FontTheme {
    let largeTitle: Font
    let title: Font
    let body: Font
    let caption: Font
    // Add more as needed
}

extension FontTheme {
    static let apex = FontTheme(
        largeTitle: .custom("ApexCoreTechs", size: 34),
        title: .custom("ApexCoreTechs", size: 24),
        body: .custom("ApexCoreTechs", size: 17),
        caption: .custom("ApexCoreTechs", size: 13)
    )
}

private struct FontThemeKey: EnvironmentKey {
    static let defaultValue: FontTheme = .apex // Fallback if none injected
}

extension EnvironmentValues {
    var fontTheme: FontTheme {
        get { self[FontThemeKey.self] }
        set { self[FontThemeKey.self] = newValue }
    }
}

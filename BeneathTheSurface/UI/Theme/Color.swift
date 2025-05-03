//
//  Color.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 5/1/25.
//
import SwiftUI

struct ColorTheme {
    let background: Color
    let surface: Color
    let primary: Color
    let onPrimary: Color
    let textColor: Color
}

extension ColorTheme {
    static let light = ColorTheme(
        background: Color.red,
        surface: Color("Ivory"),
        primary: Color.blue,
        onPrimary: .white,
        textColor: .black
    )

    static let dark = ColorTheme(
        background: Color.red,
        surface: Color("Ivory"),
        primary: Color.blue,
        onPrimary: .white,
        textColor: .white
    )
}

private struct ColorThemeKey: EnvironmentKey {
    static let defaultValue = ColorTheme.light
}

extension EnvironmentValues {
    var colorTheme: ColorTheme {
        get { self[ColorThemeKey.self] }
        set { self[ColorThemeKey.self] = newValue }
    }
}


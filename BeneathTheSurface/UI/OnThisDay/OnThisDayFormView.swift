//
//  OnThisDayFormView.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/19/25.
//

import SwiftUI

struct OnThisDayFormView: View {
    @State private var selectedMonth: Int?
    @State private var selectedDay: Int?
    @State private var errorMessage: String?

    let onSubmit: (_ day: Int, _ month: Int) -> Void
    
    @Environment(\.fontTheme) var fontTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Month Picker
            Picker("month", selection: Binding(
                get: { selectedMonth ?? 1 },
                set: { selectedMonth = $0 }
            )) {
                ForEach(1...12, id: \.self) { month in
                    Text(String(format: "%02d", month)).font(fontTheme.title).tag(month)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Day Picker
            Picker("day", selection: Binding(
                get: { selectedDay ?? 1 },
                set: { selectedDay = $0 }
            )) {
                ForEach(1...31, id: \.self) { day in
                    Text(String(format: "%02d", day)).font(fontTheme.title).tag(day)
                        
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Error message
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(fontTheme.caption)
            }

            // Submit Button
            HStack {
                Spacer()
                Button("get history") {
                    validateAndSubmit()
                }
                .buttonStyle(.borderedProminent).font(fontTheme.title)
            }
        }
        .padding()
    }

    private func validateAndSubmit() {
        guard let month = selectedMonth, let day = selectedDay else {
            errorMessage = "both fields are required."
            return
        }

        guard (1...12).contains(month) else {
            errorMessage = "month must be between 1 and 12."
            return
        }

        guard (1...31).contains(day) else {
            errorMessage = "day must be between 1 and 31."
            return
        }

        errorMessage = nil
        onSubmit(day, month)
    }
}

import SwiftUI

struct OnThisDayFormView: View {
    @State private var selectedMonth: Int = 1
    @State private var selectedDay: Int = 1
    @State private var selectedYear: Int = 2025  // Default to some year
    @State private var errorMessage: String?

    let onSubmit: (_ day: Int, _ month: Int, _ year: Int) -> Void
    
    @Environment(\.fontTheme) var fontTheme
    @Environment(\.colorScheme) var systemColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Month Picker
            Picker("Month", selection: $selectedMonth) {
                ForEach(1...12, id: \.self) { month in
                    Text(String(format: "%02d", month)).font(fontTheme.title).tag(month)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: selectedMonth) { newMonth in
                // Adjust the selected day when the month changes
                selectedDay = min(selectedDay, daysInMonth(for: selectedMonth, year: selectedYear))
            }

            // Day Picker
            Picker("Day", selection: $selectedDay) {
                ForEach(1...daysInMonth(for: selectedMonth, year: selectedYear), id: \.self) { day in
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

            // Button Row: Today Button + Get History Button
            HStack {
                Button("Today") {
                    setToCurrentDate()
                }
                .buttonStyle(.bordered)
                .font(fontTheme.title)

                Spacer()

                Button("Get History") {
                    validateAndSubmit()
                }
                .buttonStyle(.borderedProminent)
                .font(fontTheme.title)
            }
        }
        .padding()
    }

    // Function to set the date pickers to today's date
    private func setToCurrentDate() {
        let currentDate = Date()
        let calendar = Calendar.current
        
        selectedMonth = calendar.component(.month, from: currentDate)
        selectedDay = calendar.component(.day, from: currentDate)
        selectedYear = calendar.component(.year, from: currentDate)
    }

    // Function to calculate number of days in the selected month using Calendar
    private func daysInMonth(for month: Int, year: Int) -> Int {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month)
        if let date = calendar.date(from: dateComponents) {
            // Calculate the range of days for the selected month
            let range = calendar.range(of: .day, in: .month, for: date)
            return range?.count ?? 31 // Default to 31 if something goes wrong
        }
        return 31
    }

    // Function to validate and submit
    private func validateAndSubmit() {
        guard (1...12).contains(selectedMonth) else {
            errorMessage = "Month must be between 1 and 12."
            return
        }

        guard (1...daysInMonth(for: selectedMonth, year: selectedYear)).contains(selectedDay) else {
            errorMessage = "Day must be valid for the selected month."
            return
        }

        errorMessage = nil
        onSubmit(selectedDay, selectedMonth, selectedYear)
    }
}

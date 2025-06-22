import SwiftUI
import _AVKit_SwiftUI
import AVFoundation

struct OnThisDayFormView: View {
    @State private var selectedMonth: Int = 0
    @State private var selectedDay: Int = 0
    @State private var errorMessage: String?
    

    let onSubmit: (_ day: Int, _ month: Int, _ year: Int) -> Void

    @Environment(\.fontTheme) var fontTheme
    @Environment(\.colorScheme) var systemColorScheme

    private var selectedYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Month Picker
            Picker(
                selection: $selectedMonth,
                label: Text(selectedMonth == 0 ? "MONTH" : Calendar.current.monthSymbols[selectedMonth - 1])
                    .foregroundColor(selectedMonth == 0 ? .gray : .primary)
            ) {
                Text("MONTH").tag(0) // Placeholder tag
                ForEach(1...12, id: \.self) { month in
                    Text(Calendar.current.monthSymbols[month - 1]).tag(month)
                }
            }
            .pickerStyle(.menu)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.94, green: 0.92, blue: 0.96)) // Light purple-grey
            .cornerRadius(12)


            // Compute fallback values before the Picker
            let fallbackMonth = selectedMonth == 0 ? 1 : selectedMonth
            let fallbackYear = selectedYear == 0 ? Calendar.current.component(.year, from: Date()) : selectedYear

            // Day Picker
            Picker(
                selection: $selectedDay,
                label: Text(selectedDay == 0 ? "DAY" : "\(selectedDay)")
                    .foregroundColor(selectedDay == 0 ? .gray : .primary)
            ) {
                Text("DAY").tag(0) // Placeholder tag
                ForEach(1...daysInMonth(for: fallbackMonth), id: \.self) { day in
                    Text("\(day)").tag(day)
                }
            }
            .pickerStyle(.menu)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.94, green: 0.92, blue: 0.96))
            .cornerRadius(12)




            // Error message
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(fontTheme.caption)
            }

            // Buttons
            HStack {
                Button("Today") {
                    setToCurrentDate()
                }
                .font(fontTheme.title)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(red: 0.0, green: 0.29, blue: 0.71)) // Royal blue
                .foregroundColor(.white)
                .cornerRadius(20)

                Button("Get History") {
                    validateAndSubmit()
                }
                .font(fontTheme.title)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(red: 0.0, green: 0.29, blue: 0.71)) // Royal blue
                .foregroundColor(.white)
                .cornerRadius(20)

            }
        }
        .padding()
    }

    private func setToCurrentDate() {
        let currentDate = Date()
        let calendar = Calendar.current

        selectedMonth = calendar.component(.month, from: currentDate)
        selectedDay = calendar.component(.day, from: currentDate)
    }

    private func daysInMonth(for month: Int) -> Int {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: selectedYear, month: month)
        if let date = calendar.date(from: dateComponents),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 31
    }

    private func validateAndSubmit() {
        guard selectedMonth != 0 else {
            errorMessage = "Please select a month."
            return
        }

        guard selectedDay != 0 else {
            errorMessage = "Please select a day."
            return
        }

        errorMessage = nil
        onSubmit(selectedDay, selectedMonth, selectedYear)
    }
}


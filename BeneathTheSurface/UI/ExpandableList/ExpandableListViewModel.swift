//
//  ExpandableListViewModel.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/15/25.
//

import Foundation
import Combine

class ExpandableListViewModel: ObservableObject {
    @Published var items: [ExpandableItem] = []
    @Published var selectedImageURL: URL?
    @Published var isShowingFullImage = false
    @Published var aiFormSuccess: Bool = false
    @Published var aiFormError: String?
    @Published var isLoading: Bool = false
    @Published var aiLoadingComplete: Bool = false
    @Published var onThisDayLoadingComplete: Bool = false
    @Published var videoResetTrigger = UUID()

    private var cancellables = Set<AnyCancellable>()
    private let repository = OnThisDayRepository()
    private let aiRepository = AIFormDataRepository()

    func toggleItem(_ item: ExpandableItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isExpanded.toggle()
        }
    }

    func loadData(month: Int, day: Int) {
        print("📥 Starting data load")
        
        // Reset loading state
        isLoading = true
        aiLoadingComplete = false
        onThisDayLoadingComplete = false
        videoResetTrigger = UUID()
        items = []

        let formattedDate = "\(month)/\(day)"
        let formData = AIFormData(
            utcTimestamp: Date().timeIntervalSince1970 * 1000,
            date: formattedDate,
            month: month,
            day: day,
            isFreeRide: true,
            freeText: formattedDate
        )

        // Load On This Day data
        repository.fetchOnThisDayData(month: month, day: day)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("❌ OnThisDay fetch failed: \(error)")
                }
            }, receiveValue: { [weak self] data in
                guard let self = self else { return }
                self.items.append(contentsOf: data.toExpandableItems())
                self.onThisDayLoadingComplete = true
                self.checkIfAllFinished()
            })
            .store(in: &cancellables)

        // Send AI form
        aiRepository.sendFormData(formData)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("❌ AI form failed: \(error)")
                }
            }, receiveValue: { [weak self] chatData in
                guard let self = self else { return }
                self.items.insert(chatData.toExpandableItem(), at: 0)
                self.aiFormSuccess = true
                self.aiLoadingComplete = true
                self.checkIfAllFinished()
            })
            .store(in: &cancellables)
    }

    private func checkIfAllFinished() {
        if aiLoadingComplete && onThisDayLoadingComplete {
            print("✅ All data finished loading")
            isLoading = false
        }
    }
}

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

    private var cancellables = Set<AnyCancellable>()
    private let repository = OnThisDayRepository()
    private let aiRepository = AIFormDataRepository()

    func toggleItem(_ item: ExpandableItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isExpanded.toggle()
        }
    }

    func loadData(month: Int, day: Int) {
        isLoading = true
        
        let formattedDate = String(format: "%02d/%02d", month, day)
        let formData = AIFormData(
            utcTimestamp: Date().timeIntervalSince1970 * 1000,
            date: formattedDate,
            month: month,
            day: day,
            isFreeRide: true,
            freeText: formattedDate
        )

        let onThisDayPublisher = repository.fetchOnThisDayData(month: month, day: day)
        let aiFormPublisher = aiRepository.sendFormData(formData)

        onThisDayPublisher
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    print("❌ OnThisDay API failed: \(error)")
                }
            }, receiveValue: { [weak self] data in
                let historyItems = data.toExpandableItems()
                DispatchQueue.main.async {
                    self?.items = historyItems
                    self?.isLoading = false // done loading history data
                }
            })
            .store(in: &cancellables)

        aiFormPublisher
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    print("❌ AIFormData API failed: \(error)")
                    self?.aiFormError = "Failed to send AIFormData"
                }
            }, receiveValue: { [weak self] chatData in
                DispatchQueue.main.async {
                    self?.items.insert(chatData.toExpandableItem(), at: 0)
                    self?.aiFormSuccess = true
                }
            })
            .store(in: &cancellables)
    }
}

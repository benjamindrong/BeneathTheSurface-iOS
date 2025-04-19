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
    
    private var cancellables = Set<AnyCancellable>()
    private let repository = OnThisDayRepository()
    
//    init() {
//        loadSampleData()
//    }
    
    func toggleItem(_ item: ExpandableItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isExpanded.toggle()
        }
    }
    
//    private func loadSampleData() {
//        if let sampleData = DataLoader.loadJSON(named: "sample_onthisday", as: OnThisDayData.self) {
//            items = sampleData.selected.map { selected in
//                ExpandableItem(
//                    title: "\(selected.year ?? 0): \(selected.text)",
//                    pages: selected.pages
//                )
//            }
//        }
//    }
    
    // Fetch data from the repository and update items
        func loadOnThisDayData(month: Int, day: Int) {
            repository.fetchOnThisDayData(month: month, day: day)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("❌ API fetch failed: \(error)")
                    }
                }, receiveValue: { [weak self] data in
                    self?.items = data.toExpandableItems()  // Map the data to ExpandableItems
                })
                .store(in: &cancellables)
        }
}

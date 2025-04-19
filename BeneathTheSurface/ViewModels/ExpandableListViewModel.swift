//
//  ExpandableListViewModel.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/15/25.
//

import Foundation

class ExpandableListViewModel: ObservableObject {
    @Published var items: [ExpandableItem] = []
    @Published var selectedImageURL: URL?
    @Published var isShowingFullImage = false

    
    init() {
        loadSampleData()
    }
    
    func toggleItem(_ item: ExpandableItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isExpanded.toggle()
        }
    }
    
    private func loadSampleData() {
        if let sampleData = DataLoader.loadJSON(named: "sample_onthisday", as: OnThisDayData.self) {
            items = sampleData.selected.map { selected in
                ExpandableItem(
                    title: "\(selected.year ?? 0): \(selected.text)",
                    pages: selected.pages
                )
            }
        }
    }
}

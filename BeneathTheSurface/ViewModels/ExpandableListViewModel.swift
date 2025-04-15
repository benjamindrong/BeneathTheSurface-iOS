//
//  ExpandableListViewModel.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/15/25.
//

import Foundation

class ExpandableListViewModel: ObservableObject {
    @Published var items: [ExpandableItem] = []

    init() {
        items = [
            ExpandableItem(title: "Fruits", children: ["Apple", "Banana", "Mango"]),
            ExpandableItem(title: "Vegetables", children: ["Carrot", "Spinach", "Potato"]),
            ExpandableItem(title: "Dairy", children: ["Milk", "Cheese", "Yogurt"])
        ]
    }

    func toggleItem(_ item: ExpandableItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isExpanded.toggle()
        }
    }
}

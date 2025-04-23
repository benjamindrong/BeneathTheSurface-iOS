//
//  ExpandableItem.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/15/25.
//

import Foundation

struct ExpandableItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String?
    let pages: [Page]?
    var isExpanded: Bool = false
    let year: String?
}

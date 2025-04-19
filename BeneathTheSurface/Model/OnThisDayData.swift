//
//  OnThisDayData.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/17/25.
//

import Foundation

struct OnThisDayData: Codable {
    let selected: [Selected]
    let timestamp: Int64?
    let formMonth: String?
    let formDay: String?

    static let getRoute = "/onThisDay"
    static let fullUrl = "https://en.wikipedia.org/api/rest_v1/feed/onthisday/selected"
    
    // Function to map OnThisDayData to ExpandableItems
    func toExpandableItems() -> [ExpandableItem] {
        return selected.map { selected in
            ExpandableItem(
                title: "\(selected.year ?? 0): \(selected.text)", // Set the title as "year: text"
                pages: selected.pages
            )
        }
    }
}

struct OnThisDayRequest {
    let month: Int
    let day: Int
}

struct Selected: Codable {
    let pages: [Page]
    let text: String
    let year: Int?
}

struct Page: Codable {
    let contentUrls: ContentUrls?
    let coordinates: Coordinates?
    let description: String?
    let descriptionSource: String?
    let dir: String?
    let displayTitle: String?
    let extract: String?
    let extractHtml: String?
    let lang: String?
    let namespace: Namespace?
    let normalizedTitle: String?
    let originalImage: OriginalImage?
    let pageID: Int?
    let revision: String?
    let thumbnail: Thumbnail?
    let tid: String?
    let timestamp: String?
    let title: String?
    let titles: Titles?
    let type: String?
    let wikibaseItem: String?

    enum CodingKeys: String, CodingKey {
        case contentUrls = "content_urls"
        case coordinates, description
        case descriptionSource = "description_source"
        case dir, displayTitle = "displaytitle"
        case extract, extractHtml = "extract_html"
        case lang, namespace, normalizedTitle = "normalizedtitle"
        case originalImage = "originalimage"
        case pageID = "pageid"
        case revision, thumbnail, tid, timestamp, title, titles, type
        case wikibaseItem = "wikibase_item"
    }
}

struct ContentUrls: Codable {
    let desktop: Desktop?
    let mobile: Mobile?
}

struct Namespace: Codable {
    let id: Int
    let text: String
}

struct Thumbnail: Codable {
    let height: Int
    let source: String
    let width: Int
}

struct OriginalImage: Codable {
    let height: Int
    let source: String
    let width: Int
}

struct Desktop: Codable {
    let edit: String?
    let page: String?
    let revisions: String?
    let talk: String?
}

struct Mobile: Codable {
    let edit: String?
    let page: String?
    let revisions: String?
    let talk: String?
}

struct Titles: Codable {
    let canonical: String
    let display: String
    let normalized: String
}

struct Coordinates: Codable {
    let lat: Double?
    let lon: Double?
}

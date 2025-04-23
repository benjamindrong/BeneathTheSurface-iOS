//
//  AIFormData.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/22/25.
//

import Foundation

protocol ShopRoute {
    var route: String { get }
}

struct AIFormData: Codable, ShopRoute {
    // TODO: let id = UUID().uuidString
    var userName: String = ""
    var userEmail: String = ""
    var description: String = ""
    var additionalPreferences: String = ""
    var orderId: String = ""
    var utcTimestamp: Double
    var isPaid: Bool = false
    var wantInvitationDraft: Bool = false
    var date: String = ""
    var month: Int = 0
    var day: Int = 0
    var partyTime: String = ""
    var isFreeRide: Bool = false
    var freeText: String = ""
    
    static let getPath = "/aiFormData"
    
    var route: String {
        return AIFormData.getPath
    }
}

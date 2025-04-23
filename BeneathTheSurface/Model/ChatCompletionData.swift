//
//  ChatCompletionData.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/22/25.
//

import Foundation

extension ChatCompletionData {
    func toExpandableItem() -> ExpandableItem {
        let pages: [Page] = choices.enumerated().map { (index, choice) in
            Page(
                contentUrls: nil,
                coordinates: nil,
                description: nil,
                descriptionSource: nil,
                dir: nil,
                displayTitle: nil,
                extract: choice.message.content,
                extractHtml: nil,
                lang: nil,
                namespace: nil,
                normalizedTitle: nil,
                originalImage: nil,
                pageID: nil,
                revision: nil,
                thumbnail: nil,
                tid: nil,
                timestamp: nil,
                title: "AI Response \(index + 1)",
                titles: nil,
                type: nil,
                wikibaseItem: nil
            )
        }

        return ExpandableItem(
            title: "AI Insights",
            detail: "",
            pages: pages,
            year: ""
        )
    }
}

struct ChatCompletionData: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
    let systemFingerprint: String

    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
    }
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let logprobs: String?
    let finishReason: String

    enum CodingKeys: String, CodingKey {
        case index, message, logprobs
        case finishReason = "finish_reason"
    }
}

struct Message: Codable {
    let role: String
    let content: String
    let refusal: String?
}

struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    let promptTokensDetails: TokenDetails?
    let completionTokensDetails: TokenDetails?

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case promptTokensDetails = "prompt_tokens_details"
        case completionTokensDetails = "completion_tokens_details"
    }
}

struct TokenDetails: Codable {
    let cachedTokens: Int?
    let audioTokens: Int?
    let reasoningTokens: Int?
    let acceptedPredictionTokens: Int?
    let rejectedPredictionTokens: Int?

    enum CodingKeys: String, CodingKey {
        case cachedTokens = "cached_tokens"
        case audioTokens = "audio_tokens"
        case reasoningTokens = "reasoning_tokens"
        case acceptedPredictionTokens = "accepted_prediction_tokens"
        case rejectedPredictionTokens = "rejected_prediction_tokens"
    }
}

//
//  AIFormDataRepository.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/22/25.
//

import Foundation
import Combine

class AIFormDataRepository {
    func sendFormData(_ data: AIFormData) -> AnyPublisher<ChatCompletionData, Error> {
        guard let url = URL(string: "https://databridge.apexcoretechs.com/aiFormData") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(data)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ChatCompletionData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

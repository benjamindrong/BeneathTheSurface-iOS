// OnThisDayRepository.swift
// BeneathTheSurface
//
//  Created by Benjamin Drong on 4/19/25.
//

import Foundation
import Combine

class OnThisDayRepository {

    private let baseURL = "https://en.wikipedia.org/api/rest_v1/feed/onthisday/selected"

    func fetchOnThisDayData(month: Int, day: Int) -> AnyPublisher<OnThisDayData, Error> {
        let urlString = "\(baseURL)/\(month)/\(day)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: OnThisDayData.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

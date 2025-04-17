//
//  DataLoader.swift
//  BeneathTheSurface
//
//  Created by Benjamin Drong on 4/17/25.
//

import Foundation

enum DataLoader {
    static func loadJSON<T: Decodable>(named name: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to find or load \(name).json")
            return nil
        }

        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print("❌ Decoding error: \(error)")
            return nil
        }
    }
}

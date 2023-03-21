//
//  LocationModel.swift
//  WeatherApp
//
//  Created by Abdullah Magat on 3/20/23.
//

import Foundation

// MARK: - Location
struct Location: Codable {
    let name: String
    let lat, lon: Double
    let country, state: String

    enum CodingKeys: String, CodingKey {
        case name
        case lat, lon, country, state
    }
}

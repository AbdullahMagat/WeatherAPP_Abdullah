//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Abdullah Magat on 3/20/23.
//

import Foundation

// MARK: - Weather
struct Weather: Codable {
    let weather: [WeatherElement]
    let main: Main
    let name: String
    let cod: Int
}

// MARK: - Main
struct Main: Codable {
    let temp, tempMin, tempMax: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

// MARK: - WeatherElement
struct WeatherElement: Codable {
    let id: Int
    let main, description, icon: String
}


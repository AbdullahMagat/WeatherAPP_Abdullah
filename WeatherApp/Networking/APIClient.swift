//
//  APIClient.swift
//  WeatherApp
//
//  Created by Abdullah Magat on 3/20/23.
//

import Foundation
import Combine

enum APIError: Error {
  case locationNotFound
  case emptyWeatherData
}

struct APIClient {

    // GET Requests
    
    func getWeather(lat:String, lon: String) -> AnyPublisher<Weather, Error> {
        let path = "\(APIConstants.shared.weatherAPIBaseURL)lat=\(lat)&lon=\(lon)&appid=\(APIConstants.shared.apiKey)"
        let url = URL(string: path)!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
        .decode(type: Weather.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    
    func getLocation(cityName: String, stateName: String) -> AnyPublisher<[Location], Error> {
        let cityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let stateName = stateName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let path = "\(APIConstants.shared.locationAPIBaseURL)\(cityName),\(stateName),US&limit=5&appid=\(APIConstants.shared.apiKey)"
        let url = URL(string: path)!
      return URLSession.shared.dataTaskPublisher(for: url)
        .map({ $0.data })
        .decode(type: [Location].self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
}

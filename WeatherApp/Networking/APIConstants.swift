//
//  APIConstants.swift
//  WeatherApp
//
//  Created by Abdullah Magat on 3/20/23.
//

import Foundation

class APIConstants {
    
    public static var shared: APIConstants = APIConstants()
    
    private init() {
        // Singleton
    }
    
    public var weatherAPIBaseURL: String {
        get {
            return "https://api.openweathermap.org/data/2.5/weather?"
        }
    }
    
    public var locationAPIBaseURL: String {
        get {
            return "http://api.openweathermap.org/geo/1.0/direct?q="
        }
    }
    
    public var iconAPIBaseURL: String {
        get {
            return "https://openweathermap.org/img/wn/"
        }
    }
    
    //I normally externalize it but am skipping the security concern for now
    public var apiKey: String {
        get {
            return "432847d9a51dae7e7d61418e518ab842"
        }
    }
}



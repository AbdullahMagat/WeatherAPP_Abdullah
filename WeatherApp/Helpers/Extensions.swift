//
//  Extensions.swift
//  WeatherApp
//
//  Created by Abdullah Magat on 3/20/23.
//
import CoreLocation
import Foundation


extension Double {
    func convertToFahrenheit() -> Int {
        let kelvin = Measurement(value: self, unit: UnitTemperature.kelvin)
        let fahrenheit = kelvin.converted(to: .fahrenheit).value
        return Int(fahrenheit)
    }
    
    func toString() -> String {
        return String(format: "%.5f",self)
    }
}


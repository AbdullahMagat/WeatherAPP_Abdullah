//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Abdullah Magat on 3/20/23.
//
import Combine
import CoreLocation
import CoreData
import Foundation
import UIKit

class WeatherViewModel : ObservableObject {
    var isLoading: Observable<Bool> = Observable(false)
    var weather: Observable<Weather> = Observable(nil)
    var weatherIcon: Observable<UIImage> = Observable(nil)
    var weatherData: Weather?
    private let apiClient = APIClient()
    private let persistencyManager = CoreDataManager()
    private var subscribers = Set<AnyCancellable>()

    
//    @Published var weather: Weather = Weather(coord: Coord(lon: 40.73, lat: 37.31), weather: [], base: "stations", main: Main(temp: 278.36, feelsLike: 276.17, tempMin: 278.36, tempMax: 278.36, pressure: 1010, humidity: 85), visibility: 10000, wind: Wind(speed: 2.66, deg: 10), clouds: Clouds(all: 94), dt: 1679350901, sys: Sys(country: "TR", sunrise: 1679368800, sunset: 1679412527), timezone: 10800, id: 1, name: "Aynysich", cod: 200)
//    @Published var location: [Location] = []
    
    func getWeather(cityName: String, stateName: String) {
        if isLoading.value ?? true {
            return
        }

        isLoading.value = true
        
        apiClient.getLocation(cityName: cityName, stateName: stateName).flatMap { [weak self] locations -> AnyPublisher<Weather, Error> in
            if let location = locations.first, let this = self {
                return this.apiClient.getWeather(lat: location.lat.toString(), lon: location.lon.toString())
         } else {
             self?.isLoading.value = false
             return Fail(error: APIError.locationNotFound).eraseToAnyPublisher()
         }
       }.sink { [weak self] result in
           self?.isLoading.value = false
         switch result {
         case .failure(let error):
           print(error.localizedDescription)
         default:
           print("completed!")
         }
       } receiveValue: { [weak self] weather in
           self?.weather.value = weather
           self?.handleImageCache(icon: weather.weather.first?.icon)
           self?.saveLastCityWeather(weather: weather)
       }.store(in: &subscribers)
     }
    
    func getWeather(lattitude: String, longitude: String) {
        if isLoading.value ?? true {
            return
        }

        isLoading.value = true
        
        apiClient.getWeather(lat: lattitude, lon: longitude).sink { [weak self] result in
           self?.isLoading.value = false
         switch result {
         case .failure(let error):
           print(error.localizedDescription)
         default:
           print("completed!")
         }
       } receiveValue: { [weak self] weather in
           self?.weather.value = weather
           self?.handleImageCache(icon: weather.weather.first?.icon)
           self?.saveLastCityWeather(weather: weather)
       }.store(in: &subscribers)
     }
    
    func handleImageCache(icon: String?) {
        guard let icon = icon else { return }
        let stringURL = ("\(APIConstants.shared.iconAPIBaseURL)\(icon)@2x.png")
        if let dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String] {
            if let path = dict[stringURL] {
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    let image = UIImage(data: data)
                    self.weatherIcon.value = image
                }
            }
        }
        guard let url = URL(string: stringURL) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {return}
            guard let data = data else {return}
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    self.storeImage(stringURL: stringURL, image: image)
                    self.weatherIcon.value = image
                }
            }
        }
        task.resume()

    }
    
    func storeImage(stringURL: String, image: UIImage) {
        let path = NSTemporaryDirectory().appending(UUID().uuidString)
        let url = URL(fileURLWithPath: path)
        let data = image.jpegData(compressionQuality: 1)
        try? data?.write(to: url)
        var dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String]
        if dict == nil {
            dict = [String:String]()
        }
        if var dict = dict {
            dict[stringURL] = path
        }
        
        UserDefaults.standard.set(dict, forKey: "ImageCache")
        
    }
    
    func getCurrentLocation(locationManager: CLLocationManager) {
        // Ask for Authorization from the User.
        locationManager.requestAlwaysAuthorization()

        // For use in foreground
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func saveLastCityWeather(weather: Weather) {
        let name = weather.name
        let temp = "\(weather.main.temp.convertToFahrenheit())°"
        let desc = weather.weather.first?.description ?? "09n"
        let highAndLow = "H:\(weather.main.tempMin.convertToFahrenheit())° L:\(weather.main.tempMax.convertToFahrenheit())°"
        let icon = weather.weather.first?.icon ?? ""
        let iconURL = ("\(APIConstants.shared.iconAPIBaseURL)\(icon)@2x.png")
        persistencyManager.saveWeatherObject(name: name, temparature: temp, desc: desc, haghAndLow: highAndLow, iconURL: iconURL)
    }
    
    func getLastCityWeather() -> LastSearchedCityWeather? {
        return persistencyManager.getWeatherObject()
    }
}

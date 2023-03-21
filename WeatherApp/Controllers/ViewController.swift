//
//  ViewController.swift
//  WeatherApp
//
//  Created by Abdullah Magat on 3/13/23.
//
import Combine
import CoreLocation
import UIKit

class ViewController: UIViewController {
    //Outlets
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var getWeatherButton: UIButton!
    @IBOutlet weak var stateNameTextField: UITextField!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var weatherDisplayView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var cityNamelabel: UILabel!
    @IBOutlet weak var temparatureLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var highiestLowestTemp: UILabel!
    
    
    
    var weatherViewModel:WeatherViewModel = WeatherViewModel()
    let locationManager = CLLocationManager()
    var userLocation: (Double,Double)? = nil
    var lastSearchedCity: Weather? = nil
    
    // Define publishers
    @Published private var cityName = ""
    @Published private var stateName = ""

    // Combine publishers into single stream
    private var validToGetWeather: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest($cityName, $stateName)
            .map { city, state in
                return !city.isEmpty && !state.isEmpty
            }.eraseToAnyPublisher()
    }

    // Define subscriber
    private var buttonSubscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkRules()
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: {
            self.checkRules()
        })
    }
    
    private func setupUI() {
        getWeatherButton.layer.cornerRadius = 15
        outerView.layer.cornerRadius = 15
        weatherDisplayView.layer.cornerRadius = 15
        
        cityNameTextField.delegate = self
        stateNameTextField.delegate = self
        
        locationManager.delegate = self

        // Hook subscriber up to publisher
        buttonSubscriber = validToGetWeather
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: getWeatherButton)
    }
    
    private func checkRules(){
        if let lastSearchedCityWeather = weatherViewModel.getLastCityWeather() {
            let stringURL = lastSearchedCityWeather.iconURL ?? ""
            if let dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String] {
                if let path = dict[stringURL] {
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                        let image = UIImage(data: data)
                        self.imageView.image = image
                    }
                }
            }
            self.cityNamelabel.text = lastSearchedCityWeather.name
            self.temparatureLabel.text = lastSearchedCityWeather.temparature
            self.descriptionLabel.text = lastSearchedCityWeather.desc
            self.highiestLowestTemp.text = lastSearchedCityWeather.highAndLow
            
        } else {
            weatherViewModel.getCurrentLocation(locationManager: locationManager)
        }
    }
    
    
    
    
    @IBAction func cityNameUpdated(_ sender: UITextField) {
        cityName = sender.text ?? ""
    }
    
    @IBAction func stateNameUpdated(_ sender: UITextField) {
        stateName = sender.text ?? ""
    }
    
    @IBAction func getWeatherButtonTapped(_ sender: Any) {
        weatherViewModel.getWeather(cityName: cityName, stateName: stateName)
    }
    
    
    
    func bindViewModel() {
        weatherViewModel.isLoading.bind({ [weak self] isLoading in
            guard let self = self, let isLoading = isLoading else {
                return
            }
                DispatchQueue.main.async {
                    if isLoading {
                        self.activityIndicator.startAnimating()
                    } else {
                        self.activityIndicator.stopAnimating()
                    }
                }
             
        })
        weatherViewModel.weather.bind({[weak self] weather in
            guard let self = self, let weather = weather else {
                return
            }
            DispatchQueue.main.async {
                self.cityNamelabel.text = weather.name
                self.temparatureLabel.text = "\(weather.main.temp.convertToFahrenheit())°"
                self.descriptionLabel.text = weather.weather.first?.description
                self.highiestLowestTemp.text = "H:\(weather.main.tempMin.convertToFahrenheit())° L:\(weather.main.tempMax.convertToFahrenheit())°"
            }
        })
        weatherViewModel.weatherIcon.bind({[weak self] image in
            guard let self = self, let image = image else {
                return
            }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        })
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        userLocation = (locValue.latitude, locValue.longitude)
        if lastSearchedCity == nil {
            weatherViewModel.getWeather(lattitude: locValue.latitude.toString(), longitude: locValue.longitude.toString())
        }
    }
}

//
//  CoreDataManager.swift
//  WeatherApp
//
//  Created by Abdullah Magat on 3/20/23.
//
import CoreData
import UIKit
import Foundation

final class CoreDataManager {
    lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "WeatherApp")
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            print(error?.localizedDescription ?? "unknown error")
        })
        return persistentContainer
    }()
    
    var context : NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveWeatherObject(name:String, temparature: String, desc: String, haghAndLow: String, iconURL: String) {
        let lastSearchedCityWeather = LastSearchedCityWeather(context: context)
        lastSearchedCityWeather.setValue(name, forKey: "name")
        lastSearchedCityWeather.setValue(temparature, forKey: "temparature")
        lastSearchedCityWeather.setValue(desc, forKey: "desc")
        lastSearchedCityWeather.setValue(haghAndLow, forKey: "highAndLow")
        lastSearchedCityWeather.setValue(iconURL, forKey: "iconURL")
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func getWeatherObject() -> LastSearchedCityWeather? {
        do {
            let fetchRequest = NSFetchRequest<LastSearchedCityWeather>(entityName: "LastSearchedCityWeather")
            let lastSearchedCityWeather = try context.fetch(fetchRequest)
            return lastSearchedCityWeather.last
        } catch {
            print(error)
            return nil
        }
    }
}

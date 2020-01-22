//
//  WeatherService.swift
//  JournalDarkSky
//
//  Created by Devin Singh on 1/22/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import Foundation

class WeatherService {
    
    // MARK: - Properties
    
    static private let baseURL = URL(string: "https://api.darksky.net")
    static private let forecastComponent = "forecast"
    static private let apiKeyComponent = retrieveAPIKey()
    
    // MARK: - Methods
    
    /// Fetchest the current weather using a given Latitude and Longitude.
    static func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<Weather, NetworkError>) -> Void) {
        // Build URL
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL))}
        let forecastURL = baseURL.appendingPathComponent(forecastComponent)
        let apiKeyURL = forecastURL.appendingPathComponent(apiKeyComponent)
        let coordinateURL = apiKeyURL.appendingPathComponent("\(latitude),\(longitude)")
        
        URLSessionManager.fetchData(for: coordinateURL) { (result) in
            switch result {
            case .success(let data):
                do {
                    let topLevelObj = try JSONDecoder().decode(TopLevelWeatherObject.self, from: data)
                    completion(.success(topLevelObj.currently))
                } catch {
                    print(error, error.localizedDescription)
                    completion(.failure(.thrownError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    // API Key
    
   private static func retrieveAPIKey() -> String {
       guard let filepath = Bundle.main.path(forResource: "Authorization", ofType: "plist") else { print("APIKey.plist not found."); return "error" }
       let propertyList = NSDictionary.init(contentsOfFile: filepath)
       guard let apiKey = propertyList?.value(forKey: "DarkSkyAPIKey") as? String else { print("Improper drilling into PropertyList file."); return "" }
       return apiKey
   }
}

//
//  WeatherService.swift
//  JournalDarkSky
//
//  Created by Devin Singh on 1/22/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import Foundation

class WeatherService {
    
    static private let baseURL = URL(string: "https://api.darksky.net")
    static private let forecastComponent = "forecast"
    static private let apiKeyComponent = "3a084a60524149b1aa411598c98b6555"
    
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
}

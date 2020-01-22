//
//  Weather.swift
//  JournalDarkSky
//
//  Created by Devin Singh on 1/22/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import Foundation

struct TopLevelWeatherObject: Decodable {
    let currently: Weather
}

struct Weather: Decodable {
    let summary: String
    let temperature: Double
}

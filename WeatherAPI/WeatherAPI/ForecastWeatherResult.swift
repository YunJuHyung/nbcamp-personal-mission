//
//  ForecastWeatherResult.swift
//  WeatherAPI
//
//  Created by 윤주형 on 4/17/25.
//

import Foundation

struct ForecastWeatherResult: Codable {
    let list: [ForecastWeather]

}

struct ForecastWeather: Codable {
    let main: WeatherMain
    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case main
        case dtTxt = "dt_txt"
    }
}

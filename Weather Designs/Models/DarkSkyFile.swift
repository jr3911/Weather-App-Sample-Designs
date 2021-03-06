import Foundation

class DarkSkyAPIClient {
    private init() {}
    static let manager = DarkSkyAPIClient()
    
    func fetchWeatherForecast(lat: Double, long: Double, completionHandler: @escaping (Result<WeatherForecast, AppError>) -> () ) {
        
        let urlStr = "https://api.darksky.net/forecast/\(Secrets.darkSky_key)/\(lat),\(long)"
        guard let url = URL(string: urlStr) else { return }
        
        NetworkHelper.manager.performDataTask(withUrl: url, andMethod: HTTPMethod.get, completionHandler: { (result) in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let data):
                do {
                    let darkSkyResult = try JSONDecoder().decode(WeatherForecast.self, from: data)
                    guard let _ = darkSkyResult.daily, let _ = darkSkyResult.hourly else {
                        completionHandler(.failure(.invalidJSONResponse))
                        return
                    }
                    completionHandler(.success(darkSkyResult))
                } catch let error {
                    completionHandler(.failure(.couldNotParseJSON(rawError: error)))
                }
            }
        })
    }
    
}

struct WeatherForecast: Codable {
    let timezone: String?
    let daily: DailyForecast?
    let hourly: HourlyForecast?
    
    struct DailyForecast: Codable {
        let summary: String?
        let icon: String?
        let data: [DayForecastDetails]?
        let alerts: [AlertsWrapper]?
    }

    struct HourlyForecast: Codable {
        let summary: String?
        let icon: String?
        let data: [HourForecastDetails]?
    }

    struct AlertsWrapper: Codable {
        let title: String?
        let time: Int?
        let expires: Int?
        let descriptiption: String?
        let uri: String?
    }

    
}

struct DayForecastDetails: Codable {
    let time: Int?
    let summary: String?
    let icon: String?
    let sunriseTime: Int?
    let sunsetTime: Int?
    let precipIntensityMax: Double?
    let precipProbability: Double?
    let precipType: String?
    let temperatureHigh: Double?
    let temperatureLow: Double?
    let apparentTemperatureHigh: Double?
    let windSpeed: Double?
    let humidity: Double?
    let cloudCover: Double?
    let visibility: Double?
}

struct HourForecastDetails: Codable {
    let time: Int?
    let summary: String?
    let icon: String?
    let precipIntensity: Double?
    let precipProbability: Double?
    let precipType: String?
    let temperature: Double?
    let apparentTemperature: Double?
    let humidity: Double?
    let windSpeed: Double?
    let cloudCover: Double?
    let visibility: Double?
}

import Foundation

struct AnglerLocation {
    let name: String
    let imageName: String
    let obsCode: String
    let lat: Double
    let lon: Double
}

struct Angler {
    let name: String
    let temperature: String
    let waterTemp: String
    let status: String
    let imageName: String
    let wind: String
    let highTideList: [String]
    let lowTideList: [String]
    let hourlyForecast: [TimeWeatherInfo]

}

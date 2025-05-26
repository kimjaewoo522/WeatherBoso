
struct StadiumModel {
    let stadiumName: String
    let teamLogo: String
    let lat: Double
    let lon: Double
    var temp: String?
    var description: String?
}

struct WeatherResponse: Decodable {
    let weather: [Weather]
    let main: Main
    let clouds: Clouds?
    let wind: Wind?
    let rain: Rain?
    let dt: Int
}

struct Weather: Codable {
    let description, icon: String
}

struct Main: Decodable {
    let temp: Double
    let humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case humidity
    }
}

struct Rain: Codable {
    let the3H: Double?

    enum CodingKeys: String, CodingKey {
        case the3H = "3h"
    }
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct Clouds: Codable {
    let all: Int
}
extension StadiumModel {
    static var empty: StadiumModel {
        StadiumModel(stadiumName: "", teamLogo: "", lat: 0.0, lon: 0.0)
    }
}


import Foundation
import CoreLocation

struct AllNecessaryData {
    var weather: WeatherData?
    var placemark: CLPlacemark?
}

struct WeatherData: Codable {
    let location: Location?
    let current: Current?
    let forecast: Forecast?
}

struct Location: Codable {
    let name: String?
    let region: String?
    let country: String?
    let lat: Double?
    let lon: Double?
    let tzID: String?
    let localtimeEpoch: Int?
    let localtime: String?
}
struct Current: Codable {
    let lastUpdatedEpoch: Int?
    let lastUpdated: String?
    let tempC: Double?
    let tempF: Double?
    let isDay: Int?
    let condition: Condition?
    let windMph: Double?
    let windKph: Double?
    let windDegree: Int?
    let pressureMB: Double?
    let pressureIn: Double?
    let precipMm: Double?
    let precipIn: Double?
    let humidity: Int?
    let cloud: Int?
    let feelslikeC: Double?
    let feelslikeF: Double?
    let windchillC: Double?
    let windchillF: Double?
    let heatindexC: Double?
    let heatindexF: Double?
    let dewpointC: Double?
    let dewpointF: Double?
    let visKM: Int?
    let visMiles: Int?
    let uv: Double?
    let gustMph: Double?
    let gustKph: Double?
    let timeEpoch: Int?
    let time: String?
    let snowCM: Double?
    let willItRain: Int?
    let chanceOfRain: Int?
    let willItSnow: Int?
    let chanceOfSnow: Int?
}
struct Condition: Codable {
    let text: String?
    let icon: String?
    let code: Int?
}
struct Forecast: Codable {
    let forecastday: [Forecastday]?
}
struct Forecastday: Codable {
    let date: String?
    let dateEpoch: Int?
    let day: Day?
    let astro: Astro?
    let hour: [Current]?
}
struct Astro: Codable {
    let sunrise: String?
    let sunset: String?
    let moonrise: String?
    let moonset: String?
    let moonPhase: String?
    let moonIllumination: Int?
    let isMoonUp: Int?
    let isSunUp: Int?
}
struct Day: Codable {
    let maxtempC: Double?
    let maxtempF: Double?
    let mintempC: Double?
    let mintempF: Double?
    let avgtempC: Double?
    let avgtempF: Double?
    let maxwindMph: Double?
    let maxwindKph: Double?
    let totalprecipMm: Double?
    let totalprecipIn: Double?
    let totalsnowCM: Double?
    let avgvisKM: Double?
    let avgvisMiles: Double?
    let avghumidity: Int?
    let dailyWillItRain: Int?
    let dailyChanceOfRain: Int?
    let dailyWillItSnow: Int?
    let dailyChanceOfSnow: Int?
    let condition: Condition?
    let uv: Double?
}



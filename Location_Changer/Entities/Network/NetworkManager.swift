
import UIKit

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let numberOfDays: Int
    private let apiKey: String
    private let session: URLSession
        
    init(apiKey: String = "fa8b3df74d4042b9aa7135114252304",
         numberOfDays: Int = 3,
         session: URLSession = .shared) {
        self.apiKey = apiKey
        self.numberOfDays = numberOfDays
        self.session = session
    }

    func fetchWeatherData(latitude: Double,
                          longitude: Double) async throws -> WeatherData {
        guard var components = URLComponents(string: "http://api.weatherapi.com/v1/forecast.json") else {
            throw WeatherAPIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "days", value: String(numberOfDays))
        ]
        guard let url = components.url else {
            throw WeatherAPIError.invalidURL
        }
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherAPIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(WeatherData.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw WeatherAPIError.decodingError(error)
        }
    }
}


enum WeatherAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL constructed"
        case .invalidResponse: return "Received invalid response from server"
        case .requestFailed(let statusCode): return "Request failed with status code: \(statusCode)"
        case .decodingError(let error): return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

//
//  SwiftCoralCombine.swift
//  
//
//  Created by Yunus Uzun on 5.07.2023.
//

import Combine
import SwiftCoral
import Foundation

/// `APIService` is the final class for handling API requests and downloads using Combine.
public extension APIService {
    
    /// `combinePerform` method is responsible for performing a given API request.
    ///
    /// - Parameters:
    ///    - request: The API request to be made. Conforms to the `APIRequest` protocol.
    ///    - response: The expected response type. Conforms to the `Decodable` protocol.
    ///
    /// - Returns: A publisher that emits the response when the request completes.
    ///
    /// # Notes: #
    /// This method builds the URL, constructs the request object, and handles encoding for JSON and multipart body data.
    /// It performs a URLSession data task, checks for errors in the server's response, and decodes the data into the expected response type.
    ///
    /// # Example: #
    /// ```
    /// apiService.combinePerform(request: someAPIRequest, response: SomeDecodableType.self)
    /// .sink(receiveCompletion: { completion in
    ///     switch completion {
    ///     case .failure(let error):
    ///         print("Error: \(error.localizedDescription)")
    ///     case .finished:
    ///         break
    ///     }
    /// }, receiveValue: { response in
    ///     print("Response: \(response)")
    /// })
    /// ```
    func combinePerform<T: APIRequest, R: Decodable>(request: T, response: R.Type) -> AnyPublisher<R, APIError> {
        let url = buildURL(with: request)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        
        if let task = request.task {
            switch task {
            case .requestWithJSON(let encodable):
                let encoder = JSONEncoder()
                if let encodedBody = try? encoder.encode(encodable) {
                    urlRequest.httpBody = encodedBody
                }
            case .requestWithMultipart(let multipartData):
                let boundary = "Boundary-\(UUID().uuidString)"
                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = createBody(with: multipartData, boundary: boundary)
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.requestFailed
                }
                return data
            }
            .decode(type: R.self, decoder: JSONDecoder())
            .mapError { error in
                switch error {
                case is Swift.DecodingError:
                    return APIError.jsonParsingFailure
                case let urlError as URLError:
                    return APIError.other(urlError.localizedDescription)
                default:
                    return APIError.other(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

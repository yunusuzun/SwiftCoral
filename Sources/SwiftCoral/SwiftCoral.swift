//
//  APIService.swift
//  Deneme
//
//  Created by Yunus Uzun on 4.07.2023.
//

import Foundation

/// `APIService` is the final class for handling API requests and downloads.
public final class APIService {
    /// `perform` method is responsible for performing a given API request.
    ///
    /// - Parameters:
    ///    - request: The API request to be made. Conforms to the `APIRequest` protocol.
    ///    - response: The expected response type. Conforms to the `Decodable` protocol.
    ///    - completion: A closure to be executed once the request completes.
    ///
    /// # Notes: #
    /// This method builds the URL, constructs the request object, and handles encoding for JSON and multipart body data.
    /// It performs a URLSession data task, checks for errors in the server's response, and decodes the data into the expected response type.
    ///
    /// # Example: #
    /// ```
    /// apiService.perform(request: someAPIRequest, response: SomeDecodableType.self) { result in
    ///    switch result {
    ///    case .success(let response):
    ///        print("Response: \(response)")
    ///    case .failure(let error):
    ///        print("Error: \(error.localizedDescription)")
    ///    }
    /// }
    /// ```
    func perform<T: APIRequest, R: Decodable>(request: T, response: R.Type, completion: @escaping (Result<R, APIError>) -> Void) {
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
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(APIError.other(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.invalidData))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.responseUnsuccessful))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.requestFailed))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let decodedResponse = try decoder.decode(R.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(APIError.jsonParsingFailure))
            }
        }
        
        task.resume()
    }
    
    /// `downloadFile` method is responsible for downloading a file with a given API request.
    ///
    /// - Parameters:
    ///    - request: The API request for the download. Conforms to the `APIRequest` protocol.
    ///    - destinationURL: The URL to which the downloaded file should be moved.
    ///    - completion: A closure to be executed once the download completes.
    ///
    /// # Notes: #
    /// This method builds the URL, constructs the request object and performs a URLSession download task.
    /// It checks for errors in the server's response and moves the downloaded file to the desired destination URL.
    ///
    /// # Example: #
    /// ```
    /// apiService.downloadFile(with: someAPIRequest, to: someDestinationURL) { result in
    ///    switch result {
    ///    case .success(let fileURL):
    ///        print("File downloaded to: \(fileURL)")
    ///    case .failure(let error):
    ///        print("Download error: \(error.localizedDescription)")
    ///    }
    /// }
    /// ```
    func downloadFile(with request: APIRequest, to destinationURL: URL, completion: @escaping (Result<URL, APIError>) -> Void) {
        let url = buildURL(with: request)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        
        let task = URLSession.shared.downloadTask(with: urlRequest) { (location, response, error) in
            if let error = error {
                completion(.failure(APIError.other(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.responseUnsuccessful))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.requestFailed))
                return
            }
            
            guard let tempLocation = location else {
                completion(.failure(APIError.invalidData))
                return
            }
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: tempLocation, to: destinationURL)
                completion(.success(destinationURL))
            } catch {
                completion(.failure(APIError.other(error.localizedDescription)))
            }
        }
        
        task.resume()
    }
}

extension APIService {
    public func buildURL<T: APIRequest>(with request: T) -> URL {
        var components = URLComponents(url: request.baseURL.appendingPathComponent(request.path), resolvingAgainstBaseURL: false)
        
        if let queryParams = request.queryParams {
            components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        return components?.url ?? request.baseURL.appendingPathComponent(request.path)
    }
    
    public func createBody(with multipartData: [MultipartData], boundary: String) -> Data {
        var body = Data()
        
        for multipart in multipartData {
            let boundaryPrefix = "--\(boundary)\r\n"
            body.append(boundaryPrefix.data(using: .utf8)!)
            let contentDispositionString = "Content-Disposition: form-data; name=\"\(multipart.name)\""
            let contentDispositionData = contentDispositionString.data(using: .utf8)!
            body.append(contentDispositionData)
            
            if let fileName = multipart.fileName {
                body.append("; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            } else {
                body.append("\r\n".data(using: .utf8)!)
            }
            
            body.append("Content-Type: \(multipart.mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(multipart.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--".appending(boundary.appending("--")).data(using: .utf8)!)
        
        return body
    }
}

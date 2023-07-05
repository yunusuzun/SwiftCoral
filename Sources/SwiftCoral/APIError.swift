//
//  APIError.swift
//  
//
//  Created by Yunus Uzun on 5.07.2023.
//

/// Define the error cases that your API could throw
public enum APIError: Error {
    case requestFailed /// If the request fails
    case jsonConversionFailure /// If the JSON cannot be converted
    case invalidData /// If the data is invalid
    case responseUnsuccessful /// If the response from the API is unsuccessful
    case jsonParsingFailure /// If the JSON cannot be parsed
    case other(String) /// For other unspecified errors
    
    /** Localized description for each error case
     - Example: APIError.requestFailed.localizedDescription would return "Request Failed"
     */
    var localizedDescription: String {
        switch self {
        case .requestFailed: return "Request Failed"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        case .invalidData: return "Invalid Data"
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .other(let error): return error
        }
    }
}

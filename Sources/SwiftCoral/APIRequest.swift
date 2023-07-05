//
//  APIRequest.swift
//  
//
//  Created by Yunus Uzun on 5.07.2023.
//

import Foundation

/** Protocol that any API request must conform to
 - baseURL: The base URL for the request
 - path: The path for the request
 - method: The HTTP method of the request
 - headers: The headers to be attached to the request
 - queryParams: The query parameters for the request
 - task: The task to be performed with the request
 */
public protocol APIRequest {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParams: [String: String]? { get }
    var task: APITask? { get }
}

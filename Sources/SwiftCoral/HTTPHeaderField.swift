//
//  HTTPHeaderField.swift
//  
//
//  Created by Yunus Uzun on 5.07.2023.
//

/** Define the common HTTP header fields
 - authentication: Represents 'Authentication' HTTP header field
 - contentType: Represents 'Content-Type' HTTP header field
 - acceptType: Represents 'Accept' HTTP header field
 - acceptEncoding: Represents 'Accept-Encoding' HTTP header field
 - authorization: Represents 'Authorization' HTTP header field
 - acceptLanguage: Represents 'Accept-Language' HTTP header field
 - userAgent: Represents 'User-Agent' HTTP header field
 */
public enum HTTPHeaderField: String {
    case authentication = "Authentication"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
    case authorization = "Authorization"
    case acceptLanguage = "Accept-Language"
    case userAgent = "User-Agent"
}

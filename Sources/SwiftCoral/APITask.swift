//
//  APITask.swift
//  
//
//  Created by Yunus Uzun on 5.07.2023.
//

/** Define different types of tasks for API requests
 - requestWithJSON: If the task is to make a request with a JSON body
 - requestWithMultipart: If the task is to make a request with multipart data
 */
public enum APITask {
    case requestWithJSON(Encodable)
    case requestWithMultipart([MultipartData])
}

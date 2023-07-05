//
//  MultipartData.swift
//  
//
//  Created by Yunus Uzun on 5.07.2023.
//

import Foundation

/** Define the structure for multipart data
 - name: The name of the part
 - fileName: The name of the file for the part (if applicable)
 - data: The data of the part
 - mimeType: The MIME type of the part
 */
public struct MultipartData {
    let name: String
    let fileName: String?
    let data: Data
    let mimeType: String
}

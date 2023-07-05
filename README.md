# SwiftCoral
Swift Network Library is a simple, yet powerful and extensible HTTP networking library for iOS, built on top of Swift's native URLSession. It provides an easy-to-use API for making all types of HTTP requests (GET, POST, PUT, DELETE), supports multipart form-data requests, and file downloading. Now, it includes Combine support for handling asynchronous tasks more efficiently.

## Features 
This Swift Network Layer provides several features to help manage and make HTTP network requests more effectively. Here are the main features:

- **Simplicity:** This library simplifies making HTTP requests by providing an easy-to-use API built on top of Swift's URLSession.
- **Versatility:** It supports all types of HTTP requests such as GET, POST, PUT, DELETE, and even supports multipart form-data requests for uploading files.
- **Error Handling:** It has a comprehensive error handling mechanism. It uses a custom error enum (APIError) to represent different types of errors that can occur during an HTTP request.
- **Combine Framework Integration:** It offers Combine integration for asynchronous tasks, which can simplify chaining multiple operations and handling errors.
- **Enum-Based API Request Management:** This library encourages best practices by organizing different endpoints in a clean, organized way using enums.
- **URL Building:** It contains helper methods for constructing URLs from base URLs, paths, and query parameters.
- **File Downloading:** It has a built-in method for downloading files from the network and saving them to a specified location.
- **Extensible Design:** You can easily extend it to add custom behavior, such as modifying the default headers or configuring the URLRequest in a specific way for each API endpoint.
- **JSON Encoding and Decoding:** It makes it easy to encode and decode JSON data with Swift's Codable protocol.
- **Data Tasks and Download Tasks:** The library provides the functionality to execute URLSession data tasks and download tasks.

In summary, this network layer abstracts a lot of the complexity involved in making network requests, allowing you to focus on the specifics of your application's API and data models.
## Getting Started
To use this package in your project, add the following line to the dependencies in your `Package.swift` file:
```swift
dependencies: [
    .package(url: "https://github.com/yunusuzun/SwiftCoral.git", .upToNextMajor(from: "1.0.0"))
]
```
After adding the dependency, you can import it in your Swift files like so:
```swift
import SwiftCoral
```
## Usage Examples
The library is straightforward and simple to use. Here are examples of different types of requests.

### Sample template
```swift
enum API {
    case posts
    case comments(String)
    case createPost(Encodable)
    case updatePost(Encodable)
    case deletePost
    case uploadFile(MultipartData)
}

extension API: APIRequest {
    var baseURL: URL {
        switch self {
            
        case .posts, .comments, .createPost, .updatePost, .deletePost:
            return URL(string: "https://jsonplaceholder.typicode.com")!
        case .uploadFile(_):
            return URL(string: "https://api.escuelajs.co/api/v1")!
        }
    }
    
    var path: String {
        switch self {
            
        case .posts, .createPost:
            return "/posts"
        case .comments(_):
            return "/comments"
        case .updatePost, .deletePost:
            return "/posts/1"
        case .uploadFile:
            return "/files/upload"
        }
    }
    
    var method: HTTPMethod {
        switch self {
            
        case .posts, .comments:
            return .get
        case .createPost,.uploadFile:
            return .post
        case .updatePost:
            return .put
        case .deletePost:
            return .delete
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .posts, .comments, .createPost, .updatePost, .deletePost:
            return [
                HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            ]
        case .uploadFile(_):
            return [HTTPHeaderField.contentType.rawValue: "multipart/form-data"]
        }
        
        
    }
    
    var queryParams: [String : String]? {
        switch self {
            
        case .posts, .createPost, .updatePost, .deletePost, .uploadFile:
            return nil
        case .comments(let postId):
            return ["postId": postId]
        }
    }
    
    var task: APITask? {
        switch self {
            
        case .posts, .comments, .deletePost:
            return nil
        case .createPost(let model):
            return .requestWithJSON(model)
        case .updatePost(let model):
            return .requestWithJSON(model)
        case .uploadFile(let data):
            return .requestWithMultipart([data])
        }
    }
}
```

### GET Request
```swift
let service = APIService()

service.perform(request: API.posts, response: [Posts].self) { result in
    switch result {
    case .success(let response):
        print("Response: \(response)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}

```
### POST Request
```swift
let service = APIService()
let model = PostsRequest(title: "foo", body: "bar", userId: 1)

service.perform(request: API.createPost(model), response: Posts.self) { result in
    switch result {
    case .success(let response):
        print("Response: \(response)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```
### PUT Request
```swift
let service = APIService()
let model = PostsUpdate(id: 1, title: "foo", body: "bar", userId: 1)

service.perform(request: API.updatePost(model), response: Posts.self) { result in
    switch result {
    case .success(let response):
        print("Response: \(response)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```
### DELETE Request
```swift
let service = APIService()

service.perform(request: API.deletePost, response: [Posts].self) { result in
    switch result {
    case .success(let response):
        print("Response: \(response)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}

```
### File Upload (Multipart Form-Data Request)
```swift
let apiService = APIService()

let multipartData = MultipartData(name: "file", fileName: "myImage.jpg", data: imageData, mimeType: "image/jpeg")

service.perform(request: API.uploadFile(multipartData), response: UploadModel.self) { result in
    switch result {
    case .success(let response):
        print("Response: \(response)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```
### GET Request with Combine
```swift
service.combinePerform(request: API.posts, response: [Posts].self)
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }, receiveValue: { response in
        print("Response: \(response)")
    })
    .store(in: &cancellables)
```
### File Download
```swift
let apiService = APIService()

let downloadRequest: APIRequest = MyDownloadRequest() // This should conform to the APIRequest protocol

let destinationURL = URL(fileURLWithPath: "/path/to/destination/file")

apiService.downloadFile(with: downloadRequest, to: destinationURL) { result in
    switch result {
    case .success(let url):
        print("Downloaded file's URL: \(url)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```
Each of the `API` enums above are examples. You should replace them with your own classes/structs/enums that conform to the `APIRequest` protocol.

Please note that this library only provides the networking functionality. It's up to you to handle the specifics of your API, like setting the correct path, method, headers, and query parameters.

## License 
This package is available under the **MIT** license. See the **LICENSE** file for more info.

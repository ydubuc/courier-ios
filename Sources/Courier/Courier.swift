import Foundation

public struct Courier {
    // properties
    private let url: String
    private let session: URLSession

    // init
    public init(url: String, session: URLSession? = nil) {
        guard url.hasPrefix("https://") || url.hasPrefix("http://")
        else {
            preconditionFailure("Courier url must start in https:// or http://")
        }
        guard url.hasSuffix("/")
        else {
            preconditionFailure("Courier url must end in /")
        }

        self.url = url
        self.session = session ?? URLSession(configuration: Courier.defaultConfiguration())
    }

    // functions
    public func get<T: Decodable>(
        path: String,
        headers: [String: String] = [:],
        queries: [String: Any] = [:],
        completion: @escaping (T?, Error?) -> Void
    ) {
        func handleCompletion(_ result: T?, _ error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }

        var request: URLRequest
        do {
            request = try newRequest(path, headers, queries)
        } catch let e {
            return handleCompletion(nil, e)
        }
        
        request.httpMethod = "GET"

        session.dataTask(with: request) { (data, res, error) in
            if let httpRes = res as? HTTPURLResponse {
                guard (200...299).contains(httpRes.statusCode)
                else {
                    return handleCompletion(nil, CourierError("An error occurred.", httpRes.statusCode, data, error))
                }
            }

            guard error == nil, let data = data, !data.isEmpty
            else {
                return handleCompletion(nil, error)
            }

            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                handleCompletion(result, nil)
            } catch let e {
                handleCompletion(nil, e)
            }
        }
        .resume()
    }

    public func post<T: Decodable>(
        path: String,
        headers: [String: String] = [:],
        body: Data?,
        completion: @escaping (T?, Error?) -> Void
    ) {
        func handleCompletion(_ result: T?, _ error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }

        var request: URLRequest
        do {
            request = try newRequest(path, headers)
        } catch let e {
            return handleCompletion(nil, e)
        }
        
        request.httpMethod = "POST"
        request.httpBody = body

        session.dataTask(with: request) { (data, res, error) in
            if let httpRes = res as? HTTPURLResponse {
                guard (200...299).contains(httpRes.statusCode)
                else {
                    return handleCompletion(nil, CourierError("An error occurred.", httpRes.statusCode, data, error))
                }
            }

            guard error == nil, let data = data, !data.isEmpty
            else {
                return handleCompletion(nil, error)
            }

            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                handleCompletion(result, nil)
            } catch let e {
                handleCompletion(nil, e)
            }
        }
        .resume()
    }

    public func post<T: Decodable>(
        path: String,
        headers: [String: String] = [:],
        form: CourierFormDataRequest,
        completion: @escaping (T?, Error?) -> Void
    ) {
        func handleCompletion(_ result: T?, _ error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }

        var request: URLRequest
        do {
            request = try newMultipartRequest(path, form.boundary, headers)
        } catch let e {
            return handleCompletion(nil, e)
        }
        
        request.httpMethod = "POST"
        request.httpBody = form.getBody()

        session.dataTask(with: request) { (data, res, error) in
            if let httpRes = res as? HTTPURLResponse {
                guard (200...299).contains(httpRes.statusCode)
                else {
                    return handleCompletion(nil, CourierError("An error occurred.", httpRes.statusCode, data, error))
                }
            }

            guard error == nil, let data = data, !data.isEmpty
            else {
                return handleCompletion(nil, error)
            }

            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                handleCompletion(result, nil)
            } catch let e {
                handleCompletion(nil, e)
            }
        }
        .resume()
    }

    public func patch<T: Decodable>(
        path: String,
        headers: [String: String] = [:],
        body: Data,
        completion: @escaping (T?, Error?) -> Void
    ) {
        func handleCompletion(_ result: T?, _ error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }

        var request: URLRequest
        do {
            request = try newRequest(path, headers)
        } catch let e {
            return handleCompletion(nil, e)
        }
        
        request.httpMethod = "PATCH"
        request.httpBody = body

        session.dataTask(with: request) { (data, res, error) in
            if let httpRes = res as? HTTPURLResponse {
                guard (200...299).contains(httpRes.statusCode)
                else {
                    return handleCompletion(nil, CourierError("An error occurred.", httpRes.statusCode, data, error))
                }
            }

            guard error == nil, let data = data, !data.isEmpty
            else {
                return handleCompletion(nil, error)
            }

            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                handleCompletion(result, nil)
            } catch let e {
                handleCompletion(nil, e)
            }
        }
        .resume()
    }

    public func delete(
        path: String,
        headers: [String: String] = [:],
        completion: @escaping (Error?) -> Void
    ) {
        func handleCompletion(_ error: Error?) {
            DispatchQueue.main.async {
                completion(error)
            }
        }

        var request: URLRequest
        do {
            request = try newRequest(path, headers)
        } catch let e {
            return handleCompletion(e)
        }
        
        request.httpMethod = "DELETE"

        session.dataTask(with: request) { (data, res, error) in
            if let httpRes = res as? HTTPURLResponse {
                guard (200...299).contains(httpRes.statusCode)
                else {
                    return handleCompletion(CourierError("An error occurred.", httpRes.statusCode, data, error))
                }
            }

            handleCompletion(error)
        }
        .resume()
    }

    private func newRequest(
        _ path: String,
        _ headers: [String: String],
        _ queries: [String: Any]? = nil
    ) throws -> URLRequest {
        guard let path = safePath(path),
              let url = URL(string: url + (queries != nil ? pathifyQueries(path, queries!) : path))
        else {
            throw CourierError("Invalid URL.", 404)
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }

        return request
    }

    private func newMultipartRequest(
        _ path: String,
        _ boundary: String,
        _ headers: [String: String]
    ) throws -> URLRequest {
        guard let path = safePath(path),
              let url = URL(string: url + path)
        else {
            throw CourierError("Invalid URL.", 404)
        }
        
        var request = URLRequest(url: url)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }

        return request
    }
    
    private func safePath(_ path: String) -> String? {
        return path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    }

    private func pathifyQueries(_ path: String, _ queries: [String: Any]) -> String {
        guard !queries.isEmpty
        else {
            return path
        }

        var queryPath = "?"

        for (index, query) in queries.enumerated() {
            let queryValue = "\(query.value)".replacingOccurrences(of: " ", with: "+")
            queryPath += query.key + "=" + queryValue
            if index != queries.count - 1 {
                queryPath += "&"
            }
        }

        guard let encodedQueryPath = queryPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else {
            return ""
        }
        
        return path + encodedQueryPath
    }

    private static func defaultConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(30)
        config.timeoutIntervalForResource = TimeInterval(30)
        
        return config
    }
}

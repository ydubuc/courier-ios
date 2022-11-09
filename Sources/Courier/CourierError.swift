//
//  File.swift
//  
//
//  Created by Yoan Dubuc on 11/4/22.
//

import Foundation

public struct CourierError: Error {
    public let statusCode: Int
    public let message: String
    public let data: Data?
    public let error: Error?
    
    init(_ message: String, _ statusCode: Int, _ data: Data? = nil, _ error: Error? = nil) {
        self.statusCode = statusCode
        self.message = message
        self.data = data
        self.error = error
    }
}

extension CourierError: LocalizedError {
    public var errorDescription: String? { return message }
}

//
//  File.swift
//  
//
//  Created by Yoan Dubuc on 11/4/22.
//

import Foundation

public struct CourierError: Error {
    public let code: Int?
    public let message: String
    public let data: Data?
    public let error: Error?
    
    init(_ message: String, _ data: Data? = nil, _ error: Error? = nil, _ code: Int? = nil) {
        self.code = code
        self.message = message
        self.data = data
        self.error = error
    }
}

extension CourierError: LocalizedError {
    public var errorDescription: String? { return message }
}

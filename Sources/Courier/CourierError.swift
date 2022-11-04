//
//  File.swift
//  
//
//  Created by Yoan Dubuc on 11/4/22.
//

import Foundation

struct CourierError: Error {
    let code: Int?
    let message: String
    let data: Data?
    let error: Error?
    
    init(_ message: String, _ data: Data? = nil, _ error: Error? = nil, _ code: Int? = nil) {
        self.code = code
        self.message = message
        self.data = data
        self.error = error
    }
}

extension CourierError: LocalizedError {
    var errorDescription: String? { return message }
}

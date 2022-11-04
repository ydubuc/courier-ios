//
//  File.swift
//  
//
//  Created by Yoan Dubuc on 11/4/22.
//

import Foundation

public struct CourierFormDataRequest {
    // properties
    internal let boundary: String = UUID().uuidString
    private var httpBody = NSMutableData()
    
    // init
    public init() { }
    
    // functions
    public func addTextField(named name: String, value: String) {
        httpBody.append(textFormField(named: name, value: value))
    }

    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }

    public func addDataField(named name: String, data: Data) {
        httpBody.append(dataFormField(named: name, data: data))
    }

    private func dataFormField(named name: String, data: Data) -> Data {
        let fieldData = NSMutableData()

        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(name)\"\r\n")
        fieldData.append("Content-Type: \(data.mimeType)\r\n")
        fieldData.append("\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")

        return fieldData as Data
    }

    internal func getBody() -> Data {
        httpBody.append("--\(boundary)--")
        return httpBody as Data
    }
}

extension NSMutableData {
    fileprivate func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

extension Data {
    private static let mimeTypeSignatures: [UInt8: String] = [
        0xFF: "image/jpeg",
        0x89: "image/png",
        0x47: "image/gif",
        0x49: "image/tiff",
        0x4D: "image/tiff",
        0x25: "application/pdf",
        0xD0: "application/vnd",
        0x46: "text/plain"
    ]

    var mimeType: String {
        var c: UInt8 = 0
        copyBytes(to: &c, count: 1)
        return Data.mimeTypeSignatures[c] ?? "application/octet-stream"
    }
}

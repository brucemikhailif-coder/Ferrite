//
//  FormDataBody.swift
//  Ferrite
//
//  Created by Brian Dashore on 6/12/24.
//

import Foundation

struct FormDataBody {
    let boundary: String = UUID().uuidString
    let body: Data

    init(params: [String: String]) {
        var body = Data()

        for (key, value) in params {
            let bodyItems = [
                "--\(boundary)\r\n",
                "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n",
                "\(value)\r\n"
            ]

            for item in bodyItems {
                if let data = item.data(using: .utf8) {
                    body.append(data)
                }
            }
        }

        if let footerData = "--\(boundary)--\r\n".data(using: .utf8) {
            body.append(footerData)
        }

        self.body = body
    }
}

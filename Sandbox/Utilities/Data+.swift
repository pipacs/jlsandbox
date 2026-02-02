//
// Created by Akos Polster on 2025-05-20
//

import Foundation

extension Data {
    /// Hex-encode data
    var hexString: String {
        return map { String(format: "%02x", $0) }.joined(separator: "")
    }
}

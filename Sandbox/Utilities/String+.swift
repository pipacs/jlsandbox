//
//  String+.swift
//  Sandbox
//
//  Created by Akos Polster on 07/05/2026.
//

import Foundation

extension String {
    private static let hexByteRegEx = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)

    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        let preprocessed = self.replacingOccurrences(of: "0[xX]", with: "", options: .regularExpression)
        Self.hexByteRegEx.enumerateMatches(in: preprocessed, range: NSRange(startIndex..., in: preprocessed)) { match, _, _ in
            let byteString = (preprocessed as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        guard !data.isEmpty else { return nil }
        return data
    }
}

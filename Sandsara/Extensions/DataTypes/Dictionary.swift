//
//  Dictionary.swift
//  Sandsara
//
//  Created by Tín Phan on 11/7/20.
//

import Foundation

extension Dictionary {
    /// Convert dictionary to encoded data in UTF-8.
    var toData: Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return jsonData
        } catch {
            return nil
        }
    }

    mutating func update(other: Dictionary) {
        for (key, value) in other {
            self.updateValue(value, forKey: key)
        }
    }
}

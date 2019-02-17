//
//  NSData+Hexadecimal.swift
//  ios-ble-explorer
//
//  Created by João Marcelo on 20/06/15.
//  Copyright (c) 2015 João Marcelo Oliveira. All rights reserved.
//

import Foundation

extension Data {
    
    /// Create hexadecimal string representation of NSData object.
    ///
    /// :returns: String representation of this NSData object.
    
    func hexadecimalString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

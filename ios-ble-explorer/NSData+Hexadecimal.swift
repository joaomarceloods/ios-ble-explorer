//
//  NSData+Hexadecimal.swift
//  ios-ble-explorer
//
//  Created by João Marcelo on 20/06/15.
//  Copyright (c) 2015 João Marcelo Oliveira. All rights reserved.
//

import Foundation

extension NSData {
    
    /// Create hexadecimal string representation of NSData object.
    ///
    /// :returns: String representation of this NSData object.
    
    func hexadecimalString() -> String {
        var string = NSMutableString(capacity: length * 2)
        var byte: UInt8 = 0
        
        for i in 0 ..< length {
            getBytes(&byte, range: NSMakeRange(i, 1))
            string.appendFormat("%02x", byte)
        }
        
        return string as String
    }
}
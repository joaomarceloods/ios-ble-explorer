//
//  String+DataFromHex.swift
//  ios-ble-explorer
//
//  Created by João Marcelo on 20/06/15.
//  Copyright (c) 2015 João Marcelo Oliveira. All rights reserved.
//

import Foundation

extension String {
    
    /// Create NSData from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a NSData object. Note, if the string has any spaces, those are removed. Also if the string started with a '<' or ended with a '>', those are removed, too. This does no validation of the string to ensure it's a valid hexadecimal string
    ///
    /// The use of `strtoul` inspired by Martin R at http://stackoverflow.com/a/26284562/1271826
    ///
    /// :returns: NSData represented by this hexadecimal string. Returns nil if string contains characters outside the 0-9 and a-f range.
    
    func dataFromHexadecimalString() -> Data? {
        let trimmedString = self.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")
        
        // make sure the cleaned up string consists solely of hex digits, and that we have even number of them
        
        do {
            let regex = try NSRegularExpression(pattern: "^[0-9a-f]*$", options: .caseInsensitive)
            let found = regex.firstMatch(in: trimmedString, options: [], range: NSMakeRange(0, trimmedString.count))
            if found == nil || found?.range.location == NSNotFound || trimmedString.count % 2 != 0 {
                return nil
            }
        } catch {
            print("Unexpected error: \(error).")
            return nil
        }

        // everything ok, so now let's build NSData
        
        var data = Data(capacity: trimmedString.count / 2)
        var index = trimmedString.startIndex
        while index < trimmedString.endIndex {
            let nextIndex = trimmedString.index(index, offsetBy: 2)
            let byteString = trimmedString[index..<nextIndex]
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
            
            index = nextIndex
        }
        
        return data
    }
    
    /// Create NSData from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a String object from taht. Note, if the string has any spaces, those are removed. Also if the string started with a '<' or ended with a '>', those are removed, too.
    ///
    /// :param: encoding The NSStringCoding that indicates how the binary data represented by the hex string should be converted to a String.
    ///
    /// :returns: String represented by this hexadecimal string. Returns nil if string contains characters outside the 0-9 and a-f range or if a string cannot be created using the provided encoding
    
    func stringFromHexadecimalStringUsingEncoding(encoding: String.Encoding) -> String? {
        if let data = dataFromHexadecimalString() {
            return String(data: data, encoding: encoding)
        }
        
        return nil
    }
    
    /// Create hexadecimal string representation of String object.
    ///
    /// :param: encoding The NSStringCoding that indicates how the string should be converted to NSData before performing the hexadecimal conversion.
    ///
    /// :returns: String representation of this String object.
    
    func hexadecimalStringUsingEncoding(encoding: String.Encoding) -> String? {
        let resultingData = data(using: String.Encoding.utf8)
        return resultingData?.hexadecimalString()
    }
}

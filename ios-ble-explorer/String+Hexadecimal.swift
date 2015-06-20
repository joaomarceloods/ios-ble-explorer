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
    
    func dataFromHexadecimalString() -> NSData? {
        let trimmedString = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // make sure the cleaned up string consists solely of hex digits, and that we have even number of them
        
        var error: NSError?
        let regex = NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive, error: &error)
        let found = regex?.firstMatchInString(trimmedString, options: nil, range: NSMakeRange(0, count(trimmedString)))
        if found == nil || found?.range.location == NSNotFound || count(trimmedString) % 2 != 0 {
            return nil
        }
        
        // everything ok, so now let's build NSData
        
        let data = NSMutableData(capacity: count(trimmedString) / 2)
        
        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
            let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data?.appendBytes([num] as [UInt8], length: 1)
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
    
    func stringFromHexadecimalStringUsingEncoding(encoding: NSStringEncoding) -> String? {
        if let data = dataFromHexadecimalString() {
            return NSString(data: data, encoding: encoding) as? String
        }
        
        return nil
    }
    
    /// Create hexadecimal string representation of String object.
    ///
    /// :param: encoding The NSStringCoding that indicates how the string should be converted to NSData before performing the hexadecimal conversion.
    ///
    /// :returns: String representation of this String object.
    
    func hexadecimalStringUsingEncoding(encoding: NSStringEncoding) -> String? {
        let data = dataUsingEncoding(NSUTF8StringEncoding)
        return data?.hexadecimalString()
    }
}
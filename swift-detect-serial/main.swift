//
//  main.swift
//  swift-detect-serial
//
//  Created by Jeroen Arnoldus on 17-01-15.
//  Copyright (c) 2015 Repleo. All rights reserved.
//

import Foundation

import IOKit
import IOKit.serial

func findSerialDevices(deviceType: String, inout serialPortIterator: io_iterator_t ) -> kern_return_t {
    var result: kern_return_t = KERN_FAILURE
    var classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue).takeUnretainedValue()
    var classesToMatchDict = (classesToMatch as NSDictionary) as Dictionary<String, AnyObject>
    classesToMatchDict[kIOSerialBSDTypeKey] = deviceType
    let classesToMatchCFDictRef = (classesToMatchDict as NSDictionary) as CFDictionaryRef
    result = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatchCFDictRef, &serialPortIterator);
    return result
}

func printSerialPaths(portIterator: io_iterator_t) {
    var serialService: io_object_t
    do {
        serialService = IOIteratorNext(portIterator)
        if (serialService != 0) {
            let key: CFString! = "IOCalloutDevice"
            let bsdPathAsCFtring: AnyObject? = IORegistryEntryCreateCFProperty(serialService, key, kCFAllocatorDefault, 0).takeUnretainedValue()
            var bsdPath = bsdPathAsCFtring as String?
            if let path = bsdPath {
                println(path)
            }
       }
    } while serialService != 0;
}


var portIterator: io_iterator_t = 0
let kernResult = findSerialDevices(kIOSerialBSDAllTypes, &portIterator)
if kernResult == KERN_SUCCESS {
    printSerialPaths(portIterator)
}

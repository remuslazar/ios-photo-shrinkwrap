//
//  NSURL+Ext.swift
//  Photo Shrinkwrap
//
//  Created by Remus Lazar on 05.11.15.
//  Copyright © 2015 Remus Lazar. All rights reserved.
//

import Foundation

extension NSURL {
    var fileSize: Int? {
        get {
            let info = try! self.resourceValuesForKeys([NSURLFileSizeKey])
            if let fileSize = info[NSURLFileSizeKey] {
                return fileSize.integerValue
            }
            return nil
        }
    }
}
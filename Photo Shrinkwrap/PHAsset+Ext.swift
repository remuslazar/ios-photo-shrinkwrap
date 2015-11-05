//
//  PHAsset+Ext.swift
//  Photo Shrinkwrap
//
//  Created by Remus Lazar on 05.11.15.
//  Copyright © 2015 Remus Lazar. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
    func getURLWithCompletionHandler(completionHandler: (url: NSURL?) -> Void) {
        let options = PHContentEditingInputRequestOptions()
        self.requestContentEditingInputWithOptions(options) { (contentEditingInput, info) in
            completionHandler(url: contentEditingInput?.fullSizeImageURL)
        }
    }
}
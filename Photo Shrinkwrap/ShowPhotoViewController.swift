//
//  ShowPhotoViewController.swift
//  Photo Shrinkwrap
//
//  Created by Remus Lazar on 03.11.15.
//  Copyright © 2015 Remus Lazar. All rights reserved.
//

import UIKit
import Photos

class ShowPhotoViewController: UIViewController {

    // our model
    var photo: PHAsset!
    
    private let pim = PHImageManager()
    
    private func fetchImage() {

        if (photo == nil) {
            imageView.image = nil
            loadingProgressView.hidden = true
            return
        }
        
        let options = PHImageRequestOptions()
        loadingProgressView.setProgress(0, animated: false)
        loadingProgressView.hidden = false
        options.progressHandler = { (progress, error, stop, info) in
            dispatch_async(dispatch_get_main_queue()) {
                self.loadingProgressView.progress = Float(progress)
            }
        }
        options.networkAccessAllowed = true
        print("\(self.imageView.bounds.size)")
        pim.requestImageForAsset(photo, targetSize: self.imageView.bounds.size, contentMode: .AspectFill, options: options) {
            (image, info) -> Void in
            print("\(image?.size)")
            self.loadingProgressView.hidden = true
            self.imageView.image = image
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingProgressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

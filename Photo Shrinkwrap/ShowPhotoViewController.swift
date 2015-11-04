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
    private var requestIdentifier: PHImageRequestID = 0
    
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
        requestIdentifier = pim.requestImageForAsset(photo, targetSize: self.imageView.bounds.size, contentMode: .AspectFill, options: options) {
            (image, info) -> Void in
            if !info![PHImageResultIsDegradedKey]!.boolValue {
                self.requestIdentifier = 0
                self.loadingProgressView.hidden = true
            }
            self.imageView.image = image
            self.imageView.clipsToBounds = true
            self.imageView.contentMode = .ScaleAspectFit
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingProgressView: UIProgressView!

    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchImage()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        if requestIdentifier != 0 {
            // cancel a pending request if the view will go away
            pim.cancelImageRequest(requestIdentifier)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//
//  ShowPhotoViewController.swift
//  Photo Shrinkwrap
//
//  Created by Remus Lazar on 03.11.15.
//  Copyright © 2015 Remus Lazar. All rights reserved.
//

import UIKit
import Photos

class ShowPhotoViewController: UIViewController, PHPhotoLibraryChangeObserver {

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
                self.title = "\(Int(image!.size.width))x\(Int(image!.size.height))"
                
                self.photo.getURLWithCompletionHandler { (url) in
                    if let url = url,
                        let fileSize = url.fileSize {
                            let fileSizeString = NSByteCountFormatter.stringFromByteCount(Int64(fileSize),
                                countStyle: .File)
                            self.title! += " \(fileSizeString)"
                    }
                }

                
            }
            self.imageView.image = image
            self.imageView.clipsToBounds = true
            self.imageView.contentMode = .ScaleAspectFit
        }
    }
    
    private func resizeImageForPreset(preset: Int) {
        
        let options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = PhotoResizeEngine.canHandleAdjustmentData
        
        spinner.startAnimating()
        photo.requestContentEditingInputWithOptions(options) { (contentEditingInput, info) in
            
            let contentEditingOutput = PhotoResizeEngine.resizeImageForPreset(preset, contentEditingInput: contentEditingInput!)
            
            // perform the changes
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                let request = PHAssetChangeRequest(forAsset: self.photo)
                request.contentEditingOutput = contentEditingOutput
                }, completionHandler: { (success, _) in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.spinner.stopAnimating()
                    }
            })
        }
    }

    private func getCurrentPresetWithBlock(block: (preset: Int?) -> Void) {
        let options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = PhotoResizeEngine.canHandleAdjustmentData
        photo.requestContentEditingInputWithOptions(options) { (contentEditingInput, info) in
            let preset = PhotoResizeEngine.presetForAdjustmentData(contentEditingInput!.adjustmentData)
            dispatch_async(dispatch_get_main_queue()) {
                block(preset: preset)
            }
        }
    }
    
    // MARK: - Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingProgressView: UIProgressView!
    @IBOutlet weak var sizeSelector: UISegmentedControl!

    @IBAction func handleResize(sender: UISegmentedControl) {
        resizeImageForPreset(sender.selectedSegmentIndex)
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    // MARK: - ViewController Life Cycle
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if photo != nil {
            getCurrentPresetWithBlock() { (preset) in
                self.sizeSelector?.selectedSegmentIndex = preset == nil ? -1 : preset!
            }
        }
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
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
    
    // MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange) {
        if photo == nil { return }
        
        dispatch_async(dispatch_get_main_queue()) {
            if let changeDetails = changeInstance.changeDetailsForObject(self.photo) {
                if let photo = changeDetails.objectAfterChanges as? PHAsset {
                    self.photo = photo
                    if (changeDetails.assetContentChanged) {
                        self.fetchImage()
                    }
                } else {
                    self.photo = nil
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }
    
}

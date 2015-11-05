//
//  PhotosTableViewController.swift
//  Photo Shrinkwrap
//
//  Created by Remus Lazar on 02.11.15.
//  Copyright © 2015 Remus Lazar. All rights reserved.
//

import UIKit
import Photos

class PhotosTableViewController: UITableViewController, PHPhotoLibraryChangeObserver {

    struct Storyboard {
        static let CellIdentifier = "Photo Cell"
        static let PhotoSize = CGSize(width: 80, height: 80)
    }
    
    var allPhotos: PHFetchResult = {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return PHAsset.fetchAssetsWithMediaType(.Image, options: options)
    }()
    
    let pim = PHImageManager()
    
    // MARK: - View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(changeInstance: PHChange) {
        dispatch_async(dispatch_get_main_queue()) {
            if let changeDetails = changeInstance.changeDetailsForFetchResult(self.allPhotos) {
                self.allPhotos = changeDetails.fetchResultAfterChanges
                
                if changeDetails.hasIncrementalChanges || changeDetails.hasMoves {
                    
                    // perform a batch deletion/insertion/update on the table
                    self.tableView.beginUpdates()
                    
                    if let removedIndexes = changeDetails.removedIndexes {
                        self.tableView.deleteRowsAtIndexPaths(removedIndexes.getIndexPathArray(), withRowAnimation: .Fade)
                    }
                    if let insertedIndexes = changeDetails.insertedIndexes {
                        self.tableView.insertRowsAtIndexPaths(insertedIndexes.getIndexPathArray(), withRowAnimation: .Fade)
                    }
                    if let updatedIndexes = changeDetails.changedIndexes {
                        self.tableView.reloadRowsAtIndexPaths(updatedIndexes.getIndexPathArray(), withRowAnimation: .Fade)
                    }
                    
                    self.tableView.endUpdates()
                    
                } else {
                    // reload table if incremental diffs are not available
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPhotos.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier,
            forIndexPath: indexPath) as! PhotoTableViewCell
        
        if let asset = allPhotos[indexPath.row] as? PHAsset {
            cell.representedAssetIdentifier = asset.localIdentifier
            
            cell.photoLabel.text = NSDateFormatter.localizedStringFromDate(asset.creationDate!, dateStyle: .MediumStyle,
                timeStyle: .MediumStyle)
            
            if let resource = PHAssetResource.assetResourcesForAsset(asset).first {
                cell.filenameLabel.text = resource.originalFilename
            }
            cell.resolutionLabel.text = "\(asset.pixelWidth) x \(asset.pixelHeight)"
            
            asset.getURLWithCompletionHandler { (url) in
                if cell.representedAssetIdentifier == asset.localIdentifier { // check if the cell is still the same as before
                    if let url = url {
                        if let fileSize = url.fileSize {
                            let fileSizeString = NSByteCountFormatter.stringFromByteCount(Int64(fileSize),
                                countStyle: .File)
                            cell.resolutionLabel.text! += " \(fileSizeString)"
                        }
                    }
                }
            }


            let options = PHImageRequestOptions()
            // we dont want to go out to the network to fetch the thumbnails
            options.networkAccessAllowed = false

            pim.requestImageForAsset(asset, targetSize: Storyboard.PhotoSize, contentMode: .AspectFill, options: options) {
                (image, info) -> Void in
                if cell.representedAssetIdentifier == asset.localIdentifier { // check if the cell is still the same as before
                    cell.thumbnail.image = image
                    cell.thumbnail.contentMode = .ScaleAspectFill
                    cell.thumbnail.clipsToBounds = true
                }
            }
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? ShowPhotoViewController,
            cell = sender as? PhotoTableViewCell,
            indexPath = tableView.indexPathForCell(cell),
            asset = allPhotos[indexPath.row] as? PHAsset {
            dvc.photo = asset
        }
    }
    
}

extension NSIndexSet {
    func getIndexPathArray() -> [NSIndexPath] {
        return self.map { index in NSIndexPath(forRow: index, inSection: 0) }
    }
}

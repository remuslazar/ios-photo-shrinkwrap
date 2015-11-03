//
//  PhotosTableViewController.swift
//  Photo Shrinkwrap
//
//  Created by Remus Lazar on 02.11.15.
//  Copyright © 2015 Remus Lazar. All rights reserved.
//

import UIKit
import Photos

class PhotosTableViewController: UITableViewController {

    struct Storyboard {
       static let CellIdentifier = "Photo Cell"
    }
    
    let allPhotos: PHFetchResult = {
        let options = PHFetchOptions()
        options.sortDescriptors?.append(NSSortDescriptor(key: "creationDate", ascending: false))
        return PHAsset.fetchAssetsWithOptions(options)
    }()
    
    let pim = PHImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPhotos.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath)
        if let asset = allPhotos[indexPath.row] as? PHAsset {
            cell.textLabel?.text = NSDateFormatter.localizedStringFromDate(asset.creationDate!, dateStyle: .MediumStyle,
                timeStyle: .MediumStyle)
            cell.detailTextLabel?.text = "\(asset.pixelWidth) x \(asset.pixelHeight)"
            pim.requestImageForAsset(asset, targetSize: CGSize(width: 80, height: 80), contentMode: .AspectFill, options: nil) {
                (image, info) -> Void in
                print("info: \(info), image: \(image)")
                if self.tableView.indexPathForCell(cell) == indexPath {
                    cell.imageView?.image = image
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
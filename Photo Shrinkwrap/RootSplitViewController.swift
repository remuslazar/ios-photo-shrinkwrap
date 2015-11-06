//
//  RootSplitViewController.swift
//  Shrinkwrap
//
//  Created by Remus Lazar on 06.11.15.
//  Copyright © 2015 Remus Lazar. All rights reserved.
//

import UIKit

class RootSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        preferredDisplayMode = .AllVisible
    }
    
    func splitViewController(splitViewController: UISplitViewController,
        collapseSecondaryViewController secondaryViewController: UIViewController,
        ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
            
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

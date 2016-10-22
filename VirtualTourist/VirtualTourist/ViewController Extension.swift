//
//  ViewController Extension.swift
//  VirtualTourist
//
//  Created by Andrew Olson on 9/28/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit

extension UIViewController
{
    func displayActionSheet(title: String,message: String,actions: [UIAlertAction])
    {
        let alert = UIAlertController(title: title, message: message,preferredStyle: .ActionSheet)
        for action in actions
        {
            alert.addAction(action)
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(message: String)
    {
        let alert = UIAlertController(title: "Error",message: message,preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK",style: .Cancel,handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

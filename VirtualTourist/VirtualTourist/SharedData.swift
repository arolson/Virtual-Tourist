//
//  Context.swift
//  VirtualTourist
//
//  Created by Andrew Olson on 9/28/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit
import CoreData

class SharedData
{
    static let sharedInstance = SharedData()
    static let stack = CoreDataStack(modelName:  "Model")
    
    class func getSharedInstance()->SharedData
    {
        return sharedInstance
    }
    class func getContext()-> NSManagedObjectContext
    {
        return stack!.context
    }
    private init(){}
    func fetchPins()->[Pin]
    {
        let context = SharedData.getContext()
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Get the saved pins
        do {
            return try context.executeFetchRequest(fetchRequest) as! [Pin]
        } catch {
            print("There was an error fetching the list of pins.")
            return [Pin]()
        }
    }
    
}

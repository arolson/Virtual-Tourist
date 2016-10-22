//
//  Photo.swift
//  VirtualTourist
//
//  Created by Andrew Olson on 9/28/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    convenience init(id: String, url: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            
            self.id = id
            self.url = url
            print("Photo Created")
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}

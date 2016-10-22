//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Andrew Olson on 9/28/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var photos: [Photo]?

}

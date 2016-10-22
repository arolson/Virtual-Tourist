//
//  Pin.swift
//  VirtualTourist
//
//  Created by Andrew Olson on 9/28/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {

    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.latitude = latitude
            self.longitude = longitude
            print("Pin Created")
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}

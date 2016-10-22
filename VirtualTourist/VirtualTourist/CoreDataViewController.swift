//
//  CoreDataViewController.swift
//  VirtualTourist
//
//  Created by Andrew Olson on 9/28/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit
import CoreData

class CoreDataViewController: UIViewController,NSFetchedResultsControllerDelegate
{
    let context = SharedData.getContext()
    
    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
            fetchedResultsController?.delegate = self
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController) {
        fetchedResultsController = fc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func fetchPins()->[Pin]
    {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true), NSSortDescriptor(key: "longitude", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Get the saved pins
        do {
            return try context.executeFetchRequest(fetchRequest) as! [Pin]
        } catch {
            print("There was an error fetching the list of pins.")
            return [Pin]()
        }
    }
    func fetchPhotos(pin: Pin)->[Photo]
    {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true), NSSortDescriptor(key: "imageData", ascending: true),NSSortDescriptor(key: "url", ascending: true)]
        let predicate = NSPredicate(format: "pin = %@",argumentArray: [pin])
        fetchRequest.predicate = predicate

       fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Get the saved pins
        do {
            return try context.executeFetchRequest(fetchRequest) as! [Photo]
        } catch {
            print("There was an error fetching the list of pins.")
            return [Photo]()
        }
    }
    func save()
    {
        do {
            return try context.save()
        } catch {
            print("There was a problem While trying to save the Context")
        }
    }
    
    func runInBackQueue(handler: (Void)->Void)
    {
        if let coord = context.persistentStoreCoordinator
        {
            let bckgContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            bckgContext.persistentStoreCoordinator = coord
            bckgContext.performBlock()
                {
                    handler()
            }
        }
        
    }

}

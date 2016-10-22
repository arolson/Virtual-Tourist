//
//  PinCollectionViewController.swift
//  VirtualTourist
//
//  Created by Andrew Olson on 9/28/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PinCollectionViewController:CoreDataViewController , UICollectionViewDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let flikr = FlikrClient.getSharedInstance()
    var pin: TouristPin?
    typealias Handler = ((Void)->Void)?
    var photos = [Photo]()
    {
        didSet
        {
            
            performUIUpdatesOnMain(){
                self.collectionView.reloadData()
            }
            
        }
    }
    override func viewDidLoad() {
        setUpMapView()
        setUpCollectionView()
    }
    override func viewWillAppear(animated: Bool)
    {
        photos = fetchPhotos(pin!.pin!)
        if (photos.isEmpty)
        {
            fetchImages()
        }
    }

    @IBAction func newCollectionAction(sender: UIButton)
    {
        for photo in photos
        {
            self.context.deleteObject(photo)
        }
        photos = []
        save()
        fetchImages()
    }
    func fetchImages()
    {
        activityIndicator.startAnimating()
        runInBackQueue(){
            //" " more thread safe
            self.createImages()
            {
                self.photos = self.fetchPhotos(self.pin!.pin!)
                performUIUpdatesOnMain()
                {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    func createImages(handler: Handler = nil)
    {
        if photos.isEmpty
        {
            var count = 0
            flikr.searchByLatLon(pin!,view: self)
            {
                urls in
                if urls.isEmpty
                {
                    performUIUpdatesOnMain()
                    {
                        self.activityIndicator.stopAnimating()
                        self.showErrorAlert("There are no Images to display.")
                    }
                    return
                }
                for url in urls
                {
                    let photo = Photo(id: "\(count)", url: url, context: self.context)
                    photo.pin = self.pin!.pin!
                    self.flikr.performImageRequest(url)
                    {
                        imageData in
                        photo.imageData = imageData
                        self.save()
                        print(photo.id)
                        handler?()
                    }
                    count += 1
                    print(photo)
                }
                print(self.photos.count)
            }
        }
    }
    func setUpMapView()
    {
        let annotation = pin
        mapView.addAnnotation(annotation!)
        mapView.region.center = annotation!.coordinate
        let span = MKCoordinateSpanMake(0.25, 0.25)
        mapView.region.span = span
    }
    func setUpCollectionView()
    {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let space: CGFloat = 3.0
        //Find the smallest side
        let smallSide = min(view.frame.size.width, view.frame.size.height)
        
        let dimension = (smallSide - (2 * space)) / 3.0
        
        layout.minimumInteritemSpacing = space
        layout.itemSize = CGSizeMake(dimension, dimension)
        collectionView.collectionViewLayout = layout
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if photos.count > 0
        {
            print("Sections")
            return 1
        }
        return 0
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
    
        if photos.count > 0 {
             print("Items")
            print(photos.count)
            return photos.count
        }
        return 0
    }
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! PinCell
       
        if photos[indexPath.row].imageData != nil
        {
        
                let imageData = photos[indexPath.row].imageData!
                cell.activityIndicator.stopAnimating()
                cell.imageView.image = UIImage(data: imageData)
        }
        else
        {
            cell.activityIndicator.startAnimating()
        }
        
        return cell
    }
    func cellImageRetrieval(indexPath: NSIndexPath,handler: (Void)->Void)
    {
        if photos[indexPath.row].imageData == nil
        {
            for photo in photos
            {
                if let url = photo.url
                {
                    flikr.performImageRequest(url)
                    {
                        imageData in
                        
                        let photo = self.photos[indexPath.row]
                        photo.imageData = imageData
                        self.save()
                        print(photo.id)
                    }
                }
            }
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
            deleteImage(indexPath)
    }
    func deleteImage(index: NSIndexPath)
    {
        let title = "Delete Image"
        let message = "Would you like to delete this image?"
        let deleteAction = UIAlertAction(title: "Delete",style: .Destructive)
        {
            action in
            let photo = self.photos[index.row]
            
            self.context.deleteObject(photo)
            self.photos = self.fetchPhotos(self.pin!.pin!)
            self.save()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",style: .Cancel,handler: nil)
        let actions = [cancelAction,deleteAction]
        displayActionSheet(title, message: message, actions: actions)
    }

}
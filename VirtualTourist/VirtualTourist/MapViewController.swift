//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Andrew Olson on 9/28/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: CoreDataViewController,MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var pinSelected: TouristPin!
    let collectionViewSequeIdentifier = "FlikrMapImageCollection"
    enum State
    {
        case Normal
        case Delete
    }
    private var state: State = .Normal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the Normal State
        state = .Normal
        
        //Create a LongPressGestureRecognizer for Pin Placement
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPressMapView(_:)))
        let firstLaunch = !NSUserDefaults.standardUserDefaults()
            .boolForKey(DefaultKeys.launched)
        
        mapView.addGestureRecognizer(longPressRecognizer)
        
        if firstLaunch
        {
            setDefaults()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: DefaultKeys.launched)
        }
        else
        {
            setupMapView()
        }
        addPins()
        autoSave(5)
    }
    override func viewWillAppear(animated: Bool) {
        removeSelectedAnnotations()
        //create annotations out of the fetched results controller
    }
    
    @IBAction func deletePinAction(sender: UIBarButtonItem)
    {
        removeSelectedAnnotations()
        
        self.displayActionSheet("Pin Support", message: actionBulder().1, actions: actionBulder().0)
    }
    func removeSelectedAnnotations() {
        //Remove all selected Annotations
        mapView.selectedAnnotations = []
    }
    
    /*MARK: Annotation Setup */
    func onLongPressMapView(gestureRecognizer: UILongPressGestureRecognizer) {
        
        runInBackQueue(){
            if gestureRecognizer.state == .Began && self.state == .Normal
            {
                //get the location of the press
                let location = gestureRecognizer.locationInView(self.mapView)
            
                //convert that into usable coordinates
                let coordinate = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
            
                //create a usable annotation from the coordinates
                let annotation = self.createPinAnnotation(coordinate)
                performUIUpdatesOnMain()
                {
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    func createPinAnnotation(coordinate: CLLocationCoordinate2D)->TouristPin
    {
        let annotation = TouristPin(coordinate: coordinate)
    
        return annotation
    }
    /*MARK: - Defaults and initial setup*/
    
    //Set the NSUserDefaults for the map Preferences
    func setDefaults() {
        let region = mapView.region
        let dict: [String : Double] = [DefaultKeys.centerLatitude : region.center.latitude,
                                       DefaultKeys.centerLongitude : region.center.longitude,
                                       DefaultKeys.spanLatitude : region.span.latitudeDelta,
                                       DefaultKeys.spanLongitude : region.span.longitudeDelta]
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "Map")
    }
    //setup the map with the NSUserDefaults
    func setupMapView() {
        
        let dict = NSUserDefaults.standardUserDefaults().dictionaryForKey("Map")
        if let centerLatitude = dict![DefaultKeys.centerLatitude] as? Double,
            centerLongitude = dict![DefaultKeys.centerLongitude] as? Double,
            spanLatitude = dict![DefaultKeys.spanLatitude] as? Double,
            spanLongitude = dict![DefaultKeys.spanLongitude] as? Double
        {
            
            var region = MKCoordinateRegion()
            region.center.latitude = centerLatitude
            region.center.longitude = centerLongitude
            region.span.latitudeDelta = spanLatitude
            region.span.longitudeDelta = spanLongitude
            mapView.region = region
        }
        else
        {
            
            print("Defaults Faild to be retrieved")
        }
    }
    
    func autoSave(delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            
            setDefaults()
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInNanoSeconds))
            
            dispatch_after(time, dispatch_get_main_queue(), {
                self.autoSave(delayInSeconds)
            })
            
        }
    }
    //UIActionSheet Action Builder
    func actionBulder()->([UIAlertAction],String)
    {
        let action: UIAlertAction
        let message: String
        
        //Create actions for Alert ActionSheet depending on the state of the controller
        if state == .Normal
        {
            message = "Would you like to begin pin deletion?"
            action = UIAlertAction(title: "Delete",style: .Destructive)
            {
                action in
                self.state = .Delete
            }
        }
        else
        {
            message = "Would you like to return to normal mode?"
            action = UIAlertAction(title: "Normal",style: .Default)
            {
                action in
                self.state = .Normal
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",style: .Cancel, handler: nil)
        
        let actions = [action, cancelAction]
        return (actions, message)
    }
    
    /*MARK - MapView Delegate */
    //customize the annotation
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.tintColor = UIColor.redColor()
            pinView?.canShowCallout = false
            pinView?.enabled = true
            pinView?.animatesDrop = true
        }
        else
        {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    //click event on Annotation
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("DidSelectAnnotation")
        if let pin = view.annotation as? TouristPin
        {
            if state == .Normal
            {
                pinSelected = pin
                self.performSegueWithIdentifier(collectionViewSequeIdentifier, sender: self)
                print("Normal State")
            }
            else
            {
                deletePin(pin.pin!)
                mapView.removeAnnotation(view.annotation!)
                print("Delete State")
            }
        }
    }
    //MARK: FetchController functions
    func addPins()
    {
        let pins = fetchPins()
        for pin in pins
        {
            let annotation = TouristPin(pin: pin)
            mapView.addAnnotation(annotation)
        }
    }
    func deletePin(pin: Pin)
    {
        do
        {
            SharedData.getContext().deleteObject(pin)
            try SharedData.getContext().save()
        }
        catch
        {
            print("Could Not Save Context")
        }
    }
    //MARK: Perform Seque
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        save()
        if segue.identifier == collectionViewSequeIdentifier
        {
            if let controller = segue.destinationViewController as? PinCollectionViewController
            {
                controller.pin = pinSelected
            }
        }
    }

}


//
//  TouristPins.swift
//  VirtualTourist
//
//  Created by Andrew Olson on 9/28/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit
import MapKit
class TouristPin: NSObject, MKAnnotation
{
        let context = SharedData.getContext()
        var coordinate: CLLocationCoordinate2D
    // Title and subtitle for use by selection UI.
        var title: String? = " "
        var subtitle: String? = " "
        var pin: Pin?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.pin = Pin(latitude: coordinate.latitude,longitude: coordinate.longitude,context: context)
    }
    init(pin: Pin)
    {
        let latitude = Double(pin.latitude!)
        let longitude = Double(pin.longitude!)
        self.coordinate = CLLocationCoordinate2D(latitude: latitude,longitude: longitude)
        self.pin = pin
    }

}

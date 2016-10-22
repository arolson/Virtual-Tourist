//
//  FlickerClient.swift
//  Virtual Tourist
//
//  Created by Andrew Olson on 9/25/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FlikrClient
{
    //create a sharedInstance
    static let sharedInstance = FlikrClient()
    private var photos = [NSDictionary]()
    
    class func getSharedInstance()->FlikrClient
    {
        return sharedInstance
    }
    private init(){}
    
    enum Error: String
    {
        case Success = "Success: "
        
        case Error = "Error: "
    }
    
    func searchByLatLon(pin: MKAnnotation,view: UIViewController, completionHandler: (imageURLs: [String])-> Void) {
        
        // TODO: Set necessary parameters!
        let methodParameters: [String: String!] =
            [
                FlickrKeys.method: FlickrValues.searchMethod,
                FlickrKeys.apiKey: FlickrValues.apiKey,
                FlickrKeys.bbox: bboxString(pin),
                FlickrKeys.safeSearch: FlickrValues.useSafeSearch,
                FlickrKeys.extras: FlickrValues.mediumURL,
                FlickrKeys.format: FlickrValues.responseFormat,
                FlickrKeys.noJSONCallback: FlickrValues.disableJSONCallback,
                FlickrKeys.page : "\(randomPageValue())"
        ]
        retrieveImageURLFromFlikr(methodParameters,view: view)
        {
            imageURLs in
            completionHandler(imageURLs: imageURLs)
        }
    }
    func randomPageValue() -> Int {
        // Generate a random Int32 using arc4Random
        let randomValue = 1 + arc4random() % 3
        
        // Return a more convenient Int, initialized with the random value
        return Int(randomValue)
    }

    private func bboxString(pin: MKAnnotation) -> String {
        // ensure bbox is bounded by minimum and maximums
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        
        let minimumLon = max(longitude - FlickrHTTP.searchBBoxHalfWidth, FlickrHTTP.searchLonRange.0)
        let minimumLat = max(latitude - FlickrHTTP.searchBBoxHalfHeight, FlickrHTTP.searchLatRange.0)
        let maximumLon = min(longitude + FlickrHTTP.searchBBoxHalfWidth, FlickrHTTP.searchLonRange.1)
        let maximumLat = min(latitude + FlickrHTTP.searchBBoxHalfHeight, FlickrHTTP.searchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    // MARK: Flickr API
    
    private func retrieveImageURLFromFlikr(methodParameters: [String:AnyObject],view: UIViewController, completionHandler: (imageURLs: [String])->Void)
    {
        
        let url = flickrURLFromParameters(methodParameters)
        let request = NSMutableURLRequest(URL: url)
        taskFromRequest(request)
        {
            data , error , result in
            
            guard error == .Success
            else
            {
                self.handelError(error.rawValue + result, view: view)
            return
            }
            guard let parsedResult = self.parseData(data) as? NSDictionary
            else
            {
                let message = "Could not Parse the Result"
                self.handelError(message, view: view)
                return
            }
            if let request = parsedResult[FlickrResponseKeys.photos] as? NSDictionary, status = parsedResult[FlickrResponseKeys.status] as? String
            {
                if status == "ok"
                {
                     var imageURLs = [String]()
                    
                    if let photos = request[FlickrResponseKeys.photo] as? [NSDictionary]
                    {
                       
                       
                        if photos.count > 30 {
                            
                            imageURLs = self.indexing(photos, endIndex: 30)
                        }
                        else
                        {
                            imageURLs = self.indexing(photos, endIndex: photos.count)
                        }
                        completionHandler(imageURLs: imageURLs)
                    }
                    else
                    {
                        print("Not a Dictionary")
                    }
                }
                else
                {
                    let message = "Error: Status was not 'ok' "
                    performUIUpdatesOnMain()
                    {
                        view.showErrorAlert(message)
                    }
                    print(message)
                }
            }
            
        }
    }
    func handelError(message: String,view: UIViewController)
    {
        
        performUIUpdatesOnMain()
        {
            view.showErrorAlert(message)
        }
        print(message)

    }
    func indexing(photos: [NSDictionary], endIndex: Int)->[String]
    {
        var imageURLs = [String]()
        for index in 0 ..< endIndex
        {
            if let url = photos[index]["url_m"] as? String
            {
                imageURLs.append(url)
            }
        }
    return imageURLs
    }

    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        
        components.scheme = FlickrHTTP.scheme
        components.host = FlickrHTTP.host
        components.path = FlickrHTTP.path
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    //MARK: Check For Errors
    func checkForErrors(data: NSData?,response: NSURLResponse?,error:NSError?)->[String:String]?
    {
        let displayError =
        {
                (s:String)->[String:String] in
                print(s)
                return ["error": s]
        }
        /* GUARD: Was there an error? */
        guard (error == nil)
        else
        {
            return displayError("There was an error with your request: \n\(error!.localizedDescription)")
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode
            where statusCode >= 200 && statusCode <= 299
        else
        {
            return displayError("Your request returned a status code other than 2xx!")
        }
        
        /* GUARD: Was there any data returned? */
        guard data != nil
        else
        {
            return displayError("No data was returned by the request!")
        }
        return nil
    }
    
    //MARK: Task From Request
    func taskFromRequest(request: NSMutableURLRequest?,completionHandler:(data:NSData?,error: Error,result: String)->Void)
    {
        let session = NSURLSession.sharedSession()
        if let request = request
        {
            
            let task = session.dataTaskWithRequest(request)
            {
                data, response, error in
                if let er = self.checkForErrors(data, response: response, error: error)
                {
                    
                    completionHandler(data: data,error: .Error,result: er["error"]!)
                }
                else
                {
                    completionHandler(data: data,error: .Success,result: "Retrived Data")
                }
            }
            task.resume()
        }
    }
    
    //MARK: Parse Data
    func parseData(data: NSData?)->AnyObject?
    {
        var parsedResult: AnyObject!
        do
        {
            if let data = data
            {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }
            else
            {
                let message = "Data Retruned Empty!"
                return message
            }
        }
        catch
        {
            print("Could not retrieve Students Information \(data)")
        }
        
        return parsedResult
        
    }
    func performImageRequest(url: String, completionHandler: (imageData: NSData)->Void)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.taskFromRequest(request)
        {
            data, error, result in
            if error == .Success
            {
                completionHandler(imageData: data!)
            }
            else
            {
                print(error.rawValue + result)
            }
        }
    }
    
}

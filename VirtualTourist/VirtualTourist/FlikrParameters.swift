//
//  FlikrParameters.swift
//  VirtualTourist
//
//  Created by Andrew Olson on 9/29/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit

struct FlickrHTTP {
    static let scheme = "https"
    static let host = "api.flickr.com"
    static let path = "/services/rest"
    
    static let searchBBoxHalfWidth = 1.0
    static let searchBBoxHalfHeight = 1.0
    static let searchLatRange = (-90.0, 90.0)
    static let searchLonRange = (-180.0, 180.0)
}

struct FlickrKeys {
    static let method = "method"
    static let apiKey = "api_key"
    static let galleryID = "gallery_id"
    static let extras = "extras"
    static let format = "format"
    static let noJSONCallback = "nojsoncallback"
    static let safeSearch = "safe_search"
    static let text = "text"
    static let bbox = "bbox"
    static let page = "page"
}

struct FlickrValues {
    static let searchMethod = "flickr.photos.search"
    static let apiKey = "bd4b9ef4f0634a8eabbbdd8cfde6db51"
    static let responseFormat = "json"
    static let disableJSONCallback = "1" /* 1 means "yes" */
    static let galleryPhotosMethod = "flickr.galleries.getPhotos"
    static let galleryID = "5704-72157622566655097"
    static let mediumURL = "url_m"
    static let useSafeSearch = "1"
}

struct FlickrResponseKeys {
    static let status = "stat"
    static let photos = "photos"
    static let photo = "photo"
    static let title = "title"
    static let mediumURL = "url_m"
    static let pages = "pages"
    static let total = "total"
}
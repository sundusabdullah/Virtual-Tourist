//
//  DataVC.swift
//  Virtual Tourist
//
//  Created by sundus on 01/09/1440 AH.
//  Copyright © 1440 sundus. All rights reserved.
//


struct Contact {
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIBaseURL = "/services/rest"
        
        static let SearchBoxWidth = 0.5
        static let SearchBoxHeight = 0.5
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLongRange = (-180.0, 180.0)
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let page = "page"
        static let pages = "pages"
    }
    struct FlickrParameterValues {
        static let PhotosSearchMethod = "flickr.photos.search"
        static let APIKey = "6460b4b527fc6c5f0e3fd56719e77846"
        static let MediumURL = "url_m"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "nojsoncallback"
        static let SafeSearch = "1"
    }
    
    struct FlickrResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let ImageUrl = "url_m"
        static let Status = "status"
    }
}



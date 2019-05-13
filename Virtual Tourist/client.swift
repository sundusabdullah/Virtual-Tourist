//
//  client.swift
//  Virtual Tourist
//
//  Created by sundus on 03/09/1440 AH.
//  Copyright © 1440 sundus. All rights reserved.
//

import Foundation


class client {
    let session = URLSession.shared
    
    static let shared = client()
    
    func bulidUrl(parameters: [String: AnyObject]) -> URL {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = Contact.Flickr.APIScheme
        urlComponents.host = Contact.Flickr.APIHost
        urlComponents.path = Contact.Flickr.APIBaseURL
        urlComponents.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let quary = URLQueryItem(name: key, value: "\(value)")
            urlComponents.queryItems!.append(quary)
        }
        
        return urlComponents.url!
        
    }
    
    func getParm(pin: Pin) -> Dictionary<String, Any> {
        return [
            Contact.FlickrParameterKeys.Method: Contact.FlickrParameterValues.PhotosSearchMethod,
            Contact.FlickrParameterKeys.APIKey: Contact.FlickrParameterValues.APIKey,
            Contact.FlickrParameterKeys.Extras: Contact.FlickrParameterValues.MediumURL,
            Contact.FlickrParameterKeys.Format: Contact.FlickrParameterValues.ResponseFormat,
            Contact.FlickrParameterKeys.NoJSONCallback: Contact.FlickrParameterValues.DisableJSONCallback,
            Contact.FlickrParameterKeys.SafeSearch: Contact.FlickrParameterValues.SafeSearch,
            Contact.FlickrParameterKeys.BoundingBox: getbox(pin: pin)
        ]
    }
    
    
    func getbox(pin: Pin) -> String {
        
        let minLong = max(pin.longitude - Contact.Flickr.SearchBoxWidth, Contact.Flickr.SearchLongRange.0)
        let minLat =  max(pin.latitude - Contact.Flickr.SearchBoxHeight, Contact.Flickr.SearchLatRange.0)
        let maxLong = min(pin.longitude + Contact.Flickr.SearchBoxWidth, Contact.Flickr.SearchLongRange.1)
        let maxLat = min(pin.latitude + Contact.Flickr.SearchBoxHeight, Contact.Flickr.SearchLatRange.1)
        
        return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
    }
    
    func creatReq(pin: Pin) -> URLRequest {
        return URLRequest(url: bulidUrl(parameters: getParm(pin: pin) as [String : AnyObject]))

            }
    
    //@escaping
    
    func makeRequest(request: URLRequest, completion: @escaping (_ result: NSArray?, _ error: String?) -> Void) {
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            guard error == nil else {
                completion(nil, "Connection Error")
                return
                
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(nil, "Your request returned a status code")
                return
        }
            
            guard let data = data else {
                completion(nil, "No data was return")
                return
            }
            
            let result : [String: AnyObject]!
            
            do {
                result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
                
            }catch {
                completion(nil, "Could not parse the data : '\(data)'")
                return
            }
            
            guard let photoDic = result?[Contact.FlickrResponseKeys.Photos] as? [String: AnyObject], let photoArr =  photoDic[Contact.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                completion(nil, "Can not find Keys: \(Contact.FlickrResponseKeys.Photos) in \(result)")
                return
            }
            
            guard(photoArr.count>0) else {
                completion(nil, "No Photo Found")
                return
            }
            
            completion(photoArr as NSArray, nil)
            
    }
        task.resume()
}
    func downloadImg(imgUrl: String, completion: @escaping (_ image: Data?, _ error: String?) -> Void ){
        
        let task = session.dataTask(with: URL(string: imgUrl)!){
            (data, response, error) in
            
            guard error == nil else {
                completion(nil, "Error")
                return
            }
            guard let status = (response as? HTTPURLResponse)?.statusCode, status >= 200 && status <= 299 else {
                completion(nil, "Your request returned a status code")
                return
            }
            completion(data, nil)

        }
        
        task.resume()

        
    }
}

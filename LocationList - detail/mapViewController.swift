//
//  mapViewController.swift
//  LocationList2.0
//
//  Created by Adrian Dan on 11/22/15.
//  Copyright © 2015 Adrian Dan. All rights reserved.
//

import Foundation

import UIKit
import MapKit
import AVFoundation
import CoreData

class mapViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        get()
        mapView.showsUserLocation = true
        self.centerMapOnLocation(location!)
       

        
        
    }
    
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius*2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    //MARK: Web Services Stuff
    func get(){
        
        let postEndpoint: String = "https://stark-ocean-4729.herokuapp.com/annotations/"
        guard let url = NSURL(string: postEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSURLRequest(URL: url)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            guard error == nil else {
                print("error calling GET on /posts/1")
                print(error)
                return
            }
            // parse the result as JSON, since that's what the API provides
            let itemList: NSArray
            do {
                itemList = try NSJSONSerialization.JSONObjectWithData(responseData,
                    options: []) as! NSArray
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            
            
            for anno in itemList{
                
                let post = anno
                
                // the post object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                let postTitle = post["title"] as? String
                let postSub = post["subtitle"] as? String
                let postLat = post["latitude"] as? Double
                let postLon = post["longitude"] as? Double
                
                let coord = CLLocationCoordinate2DMake(CLLocationDegrees(postLat!), CLLocationDegrees(postLon!))
                
                let annotation = MyAnnotation(coordinate: coord,
                    title: postTitle!,
                    subtitle: postSub!)
                
                self.addPinToMapView(annotation)
                
            }
            
            
        })
        task.resume()
    }
    
    func addPinToMapView(detailItem: MyAnnotation){
        
        let annotation = MyAnnotation(coordinate: detailItem.coordinate,
            title: (detailItem.valueForKey("title") as? String)!,
            subtitle: (detailItem.valueForKey("subtitle") as? String)!)
       
        dispatch_async(dispatch_get_main_queue()){
             self.mapView.addAnnotation(annotation)
        }
       
        
    }

        
}


    

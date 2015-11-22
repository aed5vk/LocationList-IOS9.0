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
    
    var location: CLLocation?
    var personLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let location_lat = detailItem?.valueForKey("latitude") as? CLLocationDegrees
        let location_lon = detailItem?.valueForKey("longitude") as? CLLocationDegrees
        location = CLLocation(latitude: location_lat!, longitude: location_lon!)
        if let initialLocation = location {
            centerMapOnLocation(initialLocation)
        }
        self.configureView()
        
        let object = self.detailItem
        self.navigationItem.title = object!.valueForKey("title") as? String
        
        mapView.showsUserLocation = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius*2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }


    
}
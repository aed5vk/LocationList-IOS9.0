//
//  DetailViewController.swift
//  LocationList - detail
//
//  Created by Adrian Dan on 10/26/15.
//  Copyright © 2015 Adrian Dan. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
import CoreData

class DetailViewController: UIViewController, AVAudioPlayerDelegate {

    @IBAction func postFunc(sender: AnyObject) {
        post()
        let controller = UIAlertController(title: "Task Uploaded",
            message: "Your Task has been uploaded to the web service",
            preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
    }
   
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var location: CLLocation?
    var personLocation: CLLocation?

    var audioPlayer: AVAudioPlayer?
    
    var detailItem: NSManagedObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("Finished playing the song")
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("title") as? String
            }
        }
    }
    
    
    func addPinToMapView(){
        let location_lat = detailItem?.valueForKey("latitude") as? CLLocationDegrees
        let location_lon = detailItem?.valueForKey("longitude") as? CLLocationDegrees
        
        /* This is just a sample location */
        let location = CLLocationCoordinate2D(latitude: location_lat!,
            longitude: location_lon!)
        
        let distance = self.location!.distanceFromLocation(personLocation!)
        /* Create the annotation using the location */
        
        let annotation = MyAnnotation(coordinate: location,
            title: (detailItem!.valueForKey("title") as? String)!,
            subtitle: String(distance) + " meters")
        
        /* And eventually add it to the map */
        mapView.addAnnotation(annotation)
        
    }

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
        addPinToMapView()
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
    
    
    //Mark: Segue stuff
    @IBAction func cancelToDetailViewController(segue:UIStoryboardSegue) {
    }
    
    @IBAction func saveTaskDetail(segue:UIStoryboardSegue) {
    }
    
    override func motionEnded(motion: UIEventSubtype,
        withEvent event: UIEvent?) {
            
            if motion == .MotionShake{
                
                // play the music
                let dispatchQueue =
                dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                
                dispatch_async(dispatchQueue, {
                    let mainBundle = NSBundle.mainBundle()
                    
                    /* Find the location of our file to feed to the audio player */
                    let filePath = mainBundle.pathForResource("beep22", ofType:"mp3")
                    
                    if let path = filePath{
                        let fileData = NSData(contentsOfFile: path)
                        
                        do {
                            /* Start the audio player */
                            self.audioPlayer = try AVAudioPlayer(data: fileData!)
                            
                            guard let player = self.audioPlayer else{
                                return
                            }
                            
                            /* Set the delegate and start playing */
                            player.delegate = self
                            if player.prepareToPlay() && player.play(){
                                /* Successfully started playing */
                            } else {
                                /* Failed to play */
                            }
                            
                        } catch{
                            self.audioPlayer = nil
                            return
                        }
                        
                    }
                    
                })
                
                
                let controller = UIAlertController(title: "Shake",
                    message: "The map has been recentered",
                    preferredStyle: .Alert)
                
                self.centerMapOnLocation(personLocation!)
                
               controller.addAction(UIAlertAction(title: "OK",
                    style: .Default,
                    handler: nil))
                
                presentViewController(controller, animated: true, completion: nil)
                
            }
            
    }
    
    func post(){
        let location_lat2 = detailItem?.valueForKey("latitude") as? CLLocationDegrees
        let location_lon2 = detailItem?.valueForKey("longitude") as? CLLocationDegrees
        
        let detail = self.detailItem
        let taskTitle = detail!.valueForKey("title") as? String
        
        let distance = self.location!.distanceFromLocation(personLocation!)
        let taskSub = String(distance) + " meters"
            
        
        let postsEndpoint: String = "https://stark-ocean-4729.herokuapp.com/annotations/"
        guard let postsURL = NSURL(string: postsEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        let postsUrlRequest = NSMutableURLRequest(URL: postsURL)
        postsUrlRequest.HTTPMethod = "POST"
        postsUrlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let newPost: NSDictionary = ["title": taskTitle!, "subtitle": taskSub, "latitude": location_lat2!, "longitude": location_lon2!]
        
        
        do {
           let jsonPost = try NSJSONSerialization.dataWithJSONObject(newPost, options: [])
            postsUrlRequest.HTTPBody = jsonPost
            
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            
            let task = session.dataTaskWithRequest(postsUrlRequest, completionHandler: {
                (data, response, error) in
                guard let responseData = data else {
                    print("Error: did not receive data")
                    return
                }
                guard error == nil else {
                    print("error calling GET on /posts/1")
                    print(error)
                    return
                }
            })
            
            task.resume()
        }catch {
            print("Error: cannot create JSON from post")
        }
        
    }
    
    func delete(){
        let firstPostEndpoint: String = "https://stark-ocean-4729.herokuapp.com/annotations/1"
        let firstPostUrlRequest = NSMutableURLRequest(URL: NSURL(string: firstPostEndpoint)!)
        firstPostUrlRequest.HTTPMethod = "DELETE"
        firstPostUrlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(firstPostUrlRequest, completionHandler: {
            (data, response, error) in
            guard let _ = data else {
                print("error calling DELETE on /posts/1")
                return
            }
        })
        task.resume()
    }

}


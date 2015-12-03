//
//  MasterViewController.swift
//  LocationList - detail
//
//  Created by Adrian Dan on 10/26/15.
//  Copyright © 2015 Adrian Dan. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class MasterViewController: UITableViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?

    var detailViewController: DetailViewController? = nil
    var objects = [NSManagedObject]()
    
    //Mark: Properties
    
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var objectLocation: CLLocation?
    var list: NSMutableArray?


    //Mark: LocationManager
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count == 0{
            //handle error here
            return
        }
        
        let newLocation = locations[0]
        
        objectLocation = newLocation
        latitude = newLocation.coordinate.latitude
        longitude = newLocation.coordinate.longitude
        print("Latitude = \(latitude)")
        print("Longitude = \(longitude)")
        
        
        
    }
    
    func locationManager(manager: CLLocationManager,
        didFailWithError error: NSError){
            print("Location manager failed with error = \(error)")
    }
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus){
            
            print("The authorization status of location services is changed to: ", terminator: "")
            
            switch CLLocationManager.authorizationStatus(){
            case .AuthorizedAlways:
                print("Authorized")
                manager.startUpdatingLocation()
            case .AuthorizedWhenInUse:
                print("Authorized when in use")
                manager.startUpdatingLocation()
            case .Denied:
                print("Denied")
            case .NotDetermined:
                print("Not determined")
            case .Restricted:
                print("Restricted")
            }
            
    }
    
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title,
            message: message,
            preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func createLocationManager(startImmediately startImmediately: Bool){
        locationManager = CLLocationManager()
        if let manager = locationManager{
            print("Successfully created the location manager")
            manager.delegate = self
            if startImmediately{
                manager.startUpdatingLocation()
            }
        }
    }
    
    
    //Mark: Views
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /* Are location services available on this device? */
        if CLLocationManager.locationServicesEnabled(){
            
            /* Do we have authorization to access location services? */
            switch CLLocationManager.authorizationStatus(){
            case .AuthorizedAlways:
                /* Yes, always */
                createLocationManager(startImmediately: true)
            case .AuthorizedWhenInUse:
                /* Yes, only when our app is in use */
                createLocationManager(startImmediately: true)
            case .Denied:
                /* No */
                displayAlertWithTitle("Not Determined",
                    message: "Location services are not allowed for this app")
            case .NotDetermined:
                /* We don't know yet, we have to ask */
                createLocationManager(startImmediately: false)
                if let manager = self.locationManager{
                    manager.requestWhenInUseAuthorization()
                }
            case .Restricted:
                /* Restrictions have been applied, we have no access
                to location services */
                displayAlertWithTitle("Restricted",
                    message: "Location services are not allowed for this app")
            }
            
            
        } else {
            /* Location services are not enabled.
            Take appropriate action: for instance, prompt the
            user to enable the location services */
            print("Location services are not enabled")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.07, green:0.32, blue:0.64, alpha:0.5)
        self.navigationController?.navigationBar.tintColor = UIColor.orangeColor()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Todo")
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            objects = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var enteredText = "Your ToDO"
    func insertNewObject(sender: AnyObject) {
        
        var alert = UIAlertController(title: "Enter Task Title", message: "Enter the title of your task", preferredStyle: .Alert)
  
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            
        })
        
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.enteredText = textField.text!
            print("Text field: \(textField.text)")
            let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            //2
            let entity =  NSEntityDescription.entityForName("Todo",
                inManagedObjectContext:managedContext)
            let object = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext: managedContext)
            
            //3
            let lati = self.latitude
            let longi = self.longitude
            object.setValue(self.enteredText, forKey: "title")
            object.setValue(0, forKey:"radius")
            object.setValue("", forKey:"note")
            object.setValue(lati, forKey:"latitude")
            object.setValue(longi, forKey:"longitude")
            let size = self.objects.count
            //4
            do {
                try managedContext.save()
                //5
                self.objects.insert(object, atIndex: size)
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            let indexPath = NSIndexPath(forRow: size, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }))
        
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    
        
    }
    
    
    // MARK: Geo
    func regionWithGeotification(geotification: NSManagedObject) -> CLCircularRegion {
        
        let geo_lat = geotification.valueForKey("latitude") as! Double
        let geo_lon = geotification.valueForKey("longitude") as! Double
        let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(geo_lat), CLLocationDegrees(geo_lon))
        // 1
        let region = CLCircularRegion(center: coordinate, radius: geotification.valueForKey("radius") as! Double, identifier: geotification.valueForKey("title") as! String)
        // 2
        region.notifyOnEntry = true
        return region
    }
    
//    
//    func startMonitoringGeotification(geotification: NSManagedObject) {
//        // 1
//        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
//            
//            var alert = UIAlertController(title: "Error", message: "LocationList is not supported on this device!", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//            
//        }
//        // 2
//        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
//            
//            var alert = UIAlertController(title: "Error", message: "Location services are required!", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)        }
//        
//        // 3
//        let region = regionWithGeotification(geotification)
//        // 4
//        locationManager.startMonitoringForRegion(region)
//    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
//                let obj_lati = object.valueForKey("latitude") as! Double
//                let obj_longi = object.valueForKey("longitude") as! Double
//                let lati = CLLocationDegrees(obj_lati)
//                let longi = CLLocationDegrees(obj_longi)
//                objectLocation = CLLocation(latitude: lati, longitude: longi)
//                let location = objectLocation
                controller.detailItem = object
                controller.personLocation = objectLocation
//                controller.location = location
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
        if segue.identifier == "goToMapView" {
            let controller = (segue.destinationViewController as! mapViewController)
            
            controller.location = objectLocation
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            
        }
    }
    
    


    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        
        cell.textLabel!.text = object.valueForKey("title") as? String
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            let object = objects[indexPath.row]
            let temp = object.valueForKey("title") as! String
            get(temp)
            
            managedContext.deleteObject(objects[indexPath.row] as NSManagedObject)
            objects.removeAtIndex(indexPath.row)
    
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    //MARK: Web Services Stuff
    
    func search(desiredTitle: String, list: NSArray){
        for obj in list{
            let t = obj.valueForKey("title") as! String
            if(t == desiredTitle){
                let url = obj.valueForKey("url") as! String
                deleteURL(url)
            }
        }
    }
    
    func deleteURL(url: String){
        let firstPostEndpoint: String = url
        let firstPostUrlRequest = NSMutableURLRequest(URL: NSURL(string: firstPostEndpoint)!)
        firstPostUrlRequest.HTTPMethod = "DELETE"
        
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
    
    func get(desiredTitle: String){
        let postEndpoint: String = "https://stark-ocean-4729.herokuapp.com/annotations/"
        let url = NSURL(string: postEndpoint)
        let urlRequest = NSURLRequest(URL: url!)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
        let responseData = data
        // parse the result as JSON, since that's what the API provides
            let itemList: NSArray
            do {
                itemList = try NSJSONSerialization.JSONObjectWithData(responseData!,
                    options: []) as! NSArray
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            self.search(desiredTitle, list: itemList)
            
        })
        task.resume()
    }


}


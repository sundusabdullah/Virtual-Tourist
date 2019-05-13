//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by sundus on 30/08/1440 AH.
//  Copyright © 1440 sundus. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class mapViewController: UIViewController {
    
    
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var deleteLabel: UILabel!
    
    
    var result: NSFetchedResultsController<Pin>!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteLabel.isHidden = true
        navigationItem.rightBarButtonItem = editButtonItem
        addGestureToMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setFetchedResultController()
        setMapRegion()
        setMarkers()
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        result = nil
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        deleteLabel.isHidden = !editing
        
    }
    
    func setFetchedResultController(){
        //Fetch Request
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        

        result = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataVC.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try result.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func setMarkers(){
        
        // get pins
        let pins = result.fetchedObjects
        
        // remove pins
        map.removeAnnotations(map.annotations)
        
        //new pins
        
        for pin in pins! {
             addMarkerToMap(coordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
        }
    }
    
    func setMapRegion(){
        if let mapRegion = UserDefaults.standard.dictionary(forKey: "mapRegion"){
            let center = CLLocationCoordinate2DMake(mapRegion["lat"] as! Double, mapRegion["log"] as! Double)
            let span = MKCoordinateSpan(latitudeDelta:mapRegion["latDelta"] as! Double, longitudeDelta: mapRegion["longDelta"] as! Double)
            let region = MKCoordinateRegion(center: center, span: span)
            map.setRegion(region, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueVC = segue.destination as? PhotoAlbumViewController {
            let pin = sender as! Pin
            segueVC.pinTap = pin            
        }
    }
    
    
}

extension mapViewController {
    func addGestureToMap(){
        let gestureReco = UILongPressGestureRecognizer(target: self, action: #selector(addMarker(gesture:)))
        gestureReco.minimumPressDuration = 0.5
        map.addGestureRecognizer(gestureReco)
    }
    
    @objc func addMarker(gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            let pinLocation = gesture.location(in: map)
            let pinCoordinate = map.convert(pinLocation, toCoordinateFrom: map)
            addMarkerToMap(coordinate: pinCoordinate)
            addpin(coordinate: pinCoordinate)
        }
    }
    
    func addMarkerToMap(coordinate: CLLocationCoordinate2D){
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        map.addAnnotation(pin)
    }
    func addpin(coordinate: CLLocationCoordinate2D){
        let pinToAdd = Pin(context: DataVC.shared.viewContext)
        pinToAdd.latitude = coordinate.latitude
        pinToAdd.longitude = coordinate.longitude
        saveViewContext()
}
    
    func getpin(latitude: Double, longitude: Double) -> Pin? {
        let fechRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let pred = NSPredicate(format: "latitude == %lf AND longitude == %lf", latitude, longitude)
        fechRequest.predicate = pred
    
    
    guard let pin = (try?
    DataVC.shared.viewContext.fetch(fechRequest))!.first
        else {
            return nil
    }
    
    return pin
}
    func saveViewContext(){
        try? DataVC.shared.viewContext.save()
    }
    
   
}

extension mapViewController : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // pin Result
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation,  reuseIdentifier: "pin")
        pinView?.animatesDrop = true
            
        } else {
            pinView!.annotation = annotation
    }
    return pinView

}
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        
        guard let pin = getpin(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!) else {
            self.messageAlert(massage: "Pin not found in DB")
            return
        }
        
        if isEditing {
            DataVC.shared.viewContext.delete(pin)
            saveViewContext()
            map.removeAnnotation(view.annotation!)
        }
        else {
            performSegue(withIdentifier: "detailView", sender: pin)

        }
        }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let defults = UserDefaults.standard
        let leco = [ "lat" : map.centerCoordinate.latitude,
                     "log": mapView.centerCoordinate.longitude,
                     "latDelta":mapView.region.span.latitudeDelta,
                     "longDelta":mapView.region.span.longitudeDelta]
        defults.set(leco, forKey: "mapRegion")
    
    }
        
    }
    
    




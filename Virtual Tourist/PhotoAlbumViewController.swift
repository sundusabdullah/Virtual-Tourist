//
//  DetailVC.swift
//  Virtual Tourist
//
//  Created by sundus on 01/09/1440 AH.
//  Copyright © 1440 sundus. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    
    
    
    var pinTap: Pin!

    @IBOutlet weak var deleteLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    
    var result: NSFetchedResultsController<Photo>!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        deleteLabel.isHidden = true
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2DMake(pinTap.latitude, pinTap.latitude)
        map.addAnnotation(pin)
        map.setRegion(MKCoordinateRegion(center: pin.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.title = "Photo"
   
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setFetchResult()
        
        if(result.fetchedObjects?.count)! < 1 {
            reloadImage(nil)
        }
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        result = nil
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        button.isHidden = editing
        deleteLabel.isHidden = !editing

    }
    
    func setFetchResult(){
        let fetchReq: NSFetchRequest<Photo> = Photo.fetchRequest()
        let pred = NSPredicate(format: "pin ==%@", pinTap)
        fetchReq.predicate = pred
        fetchReq.sortDescriptors = []
        result = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: DataVC.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        
        result.delegate = self as! NSFetchedResultsControllerDelegate
        
        do {
            try result.performFetch()
        } catch {
             fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    
    @IBAction func reloadImage(_ sender: Any?) {

        deletePhoto()
        reloadButton(isEnabled: false)
        
        let request = client.shared.creatReq(pin: pinTap)
        client.shared.makeRequest(request: request){
            (result, error) in
            
            guard error == nil else {
                self.messageAlert(massage: error!)
                self.reloadButton(isEnabled: true)
                return
            }
            
            guard result!.count > 0 else {
                self.reloadButton(isEnabled: true)
                return
                
            }
            
            self.addPhoto(photos: result!)
            self.reloadButton(isEnabled: true)
            self.button.isHidden = true
        }

        }
        
        func addPhoto(photos: NSArray) {
            for _ in 1...15 {
                let randomImage = Int(arc4random_uniform(UInt32(photos.count)))
                let photo = photos[randomImage] as! [String: AnyObject]
                guard let imgeUrl = photo[Contact.FlickrResponseKeys.ImageUrl] as?
                    String else {
                        return
                }
                let photoToAdd = Photo(context: DataVC.shared.viewContext)
                photoToAdd.pin = pinTap
                photoToAdd.imageUrl = imgeUrl
            
            }
            saveViewContext()

        }
        
         func deletePhoto() {
            for photo in (result!.fetchedObjects)! {
                DataVC.shared.viewContext.delete(photo)
                saveViewContext()
            }
        }
        
        func saveViewContext() {
            try? DataVC.shared.viewContext.save()
            }
        
    
        
        func reloadButton(isEnabled: Bool) {
            DispatchQueue.main.async {
                self.button.isHidden = isEnabled
            }
            
            DispatchQueue.main.async {
                self.button.isHidden = isEnabled
                self.collectionView.reloadData()
            }
        }

            }

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return result.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = result.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellView", for: indexPath) as! PhotoCell
        
        cell.imageView.image = nil
        cell.inde.startAnimating()
        
        if photo.image == nil {
            client.shared.downloadImg(imgUrl:photo.imageUrl!) {
                (image, error) in
                guard error == nil else {
                    self.messageAlert(massage: error!)
                    return
                }
                DispatchQueue.main.async {
                    photo.image = image
                    self.saveViewContext()
                    cell.inde.stopAnimating()
                }
            }
        } else {
            cell.imageView.image = UIImage(data: photo.image!)
            cell.inde.stopAnimating()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            let photo = result.object(at: indexPath)
            DataVC.shared.viewContext.delete(photo)
            saveViewContext()
        }
    }

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return result.sections?.count ?? 1
    }
}


extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        default:
            break
        }
    }
 
}


    
    
    
    
    
    


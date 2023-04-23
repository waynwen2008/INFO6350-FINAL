//
//  UploadImageViewController.swift
//  info6350Final
//
//  Created by Wayne Wen on 4/22/23.
//

import UIKit
import CoreLocation
import RealmSwift

class UploadImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var lblLocation: UILabel!
    
    let locationManager = CLLocationManager()
    let realm = try! Realm()
    
    
    var uploadProtocol: UploadImageProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        
        print(lat)
        print(lng)
        getAddressFromLocation(location: location)
    }
    
    func getAddressFromLocation( location: CLLocation){
            
            let clGeoCoder = CLGeocoder()
            
            clGeoCoder.reverseGeocodeLocation(location) { placeMarks, error in
                
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                var address = ""
                guard let place = placeMarks?.first else { return }
                
                if place.name != nil {
                    address += place.name! +  ", "
                }
                
                if place.locality != nil {
                    address += place.locality! +  ", "
                }
//                if place.subLocality != nil {
//                    address += place.subLocality! +  ", "
//                }
//
//                if place.postalCode != nil {
//                    address += place.postalCode! +  ", "
//                }
//
//                if place.country != nil {
//                    address += place.country!
//                }
                
                print(address)
                
                self.lblLocation.text = address
                
            }
        }
    
    @IBAction func takeAPicAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Take a picture", message: "take a picture", preferredStyle: .alert)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default){ action in
            if
                UIImagePickerController.isSourceTypeAvailable(.camera){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true)
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default){ action in
            if
                UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel){
            action in
            print("Cancel")
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imgView.image = image
                
            }
            
            picker.dismiss(animated: true)
            
        }
    
    @IBAction func uploadAction(_ sender: Any) {

        guard let img = imgView.image else {return}
        guard let location = lblLocation.text else {return}
        guard let title = txtTitle.text else {return}
        
        // upload to DB
        let imgData: InstaImageCelldata = InstaImageCelldata()
        imgData.title = title
        imgData.location = location
        imgData.Image = img.jpegData(compressionQuality: 0.5)
        
        // Add to the Realm
        do {
            try realm.write {
                realm.add(imgData, update: .modified)
            }
        } catch let error as NSError {
            print("Unable to add values to the DB " + error.localizedDescription)
        }

        uploadProtocol?.uploadedImageDelegate(img: img, locationImg: location, titleImg: title)
        
        self.tabBarController?.selectedIndex = 0;
    }
}

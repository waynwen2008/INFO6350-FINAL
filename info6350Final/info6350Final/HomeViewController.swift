//
//  HomeViewController.swift
//  info6350Final
//
//  Created by Wayne Wen on 4/22/23.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UploadImageProtocol  {
    
    
    var images : [UIImage] = [UIImage]()
    var locations = [String]()
    var imageTitles : [String] = [String]()
    let realm = try! Realm()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getValues()
        
        
//        let controller = navigationController?.tabBarController
//        print("controller")
//        print(navigationController)
//
//        uploadImageVC = navigationController?.tabBarController?.viewControllers?[0]
//        print("uploadImageVC")
//        print(uploadImageVC)
//        print(uploadImageVC?.title)
        

        // Do any additional setup after loading the view.
    }
    
    
    func getValues(){
        do{
            let posts = realm.objects(InstaImageCelldata.self)
            
            print(posts)
//            print(type(of: posts[0].Image))
            
            for post in posts {
                guard let image = UIImage(data: post.Image!) else { return }
                images.append(image)
                locations.append(post.location)
                imageTitles.append(post.title)
            }
            
        }
        catch _ as NSError {
            print("Unable to add values to the DB")
        }
        tblView.reloadData()
    }
    
    
    @IBOutlet weak var tblView: UITableView!
    var uploadImageVC : UIViewController?
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imageTitles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  Bundle.main.loadNibNamed("imageTableViewCell", owner: self)?.first as! imageTableViewCell
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        print(images)
//        cell.uploadedImg.image = UIImage(named: "\(indexPath.row)")
        cell.uploadedImg.image = images[indexPath.row]
        cell.titleLbl.text = imageTitles[indexPath.row]
        cell.locationLbl.text = locations[indexPath.row]
        
//        cell.textLabel?.text = imageTitles[indexPath.row]
        return cell
    }
    
    func uploadedImageDelegate(img: UIImage, locationImg: String, titleImg: String) {
        images.append(img)
        locations.append(locationImg)
        imageTitles.append(titleImg)
        
        tblView.reloadData()
    }

}

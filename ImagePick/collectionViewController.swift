//
//  collectionViewController.swift
//  ImagePick
//
//  Created by Cesa Salaam on 4/8/16.
//  Copyright © 2016 CesaSalaam. All rights reserved.
//

import UIKit
import CoreData
private let reuseIdentifier = "Box"

class collectionViewController: UICollectionViewController {
    
    //MARK: - Variables
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var stores = [Store]()
    var currPhoto: UIImage?
    
    override func viewDidAppear(animated: Bool) {
        let request = NSFetchRequest(entityName: "Store")
        
        stores  = (try! self.moContext.executeFetchRequest(request)) as! [Store]
    
        collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: CollectionView Functions

extension collectionViewController{
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "viewImage"{
            let destViewController: showImageViewController = segue.destinationViewController as! showImageViewController
            
            destViewController.photo = currPhoto
        }
    }
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return stores.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! customCollectionCellCollectionViewCell
        let imageData = stores[indexPath.row].picture
        let image = UIImage(data: imageData!)
        cell.imageView.image = image
        return cell
    }

    // MARK: UICollectionViewDelegate
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let imageData = stores[indexPath.row].picture
        currPhoto = UIImage(data: imageData!)
        self.performSegueWithIdentifier("viewImage", sender: nil)
        return true
    }

}

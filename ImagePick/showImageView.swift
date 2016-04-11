//
//  showImageView.swift
//  ImagePick
//
//  Created by Lifoma Salaam on 3/23/16.
//  Copyright © 2016 CesaSalaam. All rights reserved.
//
//View controller to display picture

import Social
import UIKit
class showImageViewController: UIViewController{

    //MARK: Outlets and Actions and Variables
    var photo: UIImage?
    
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func faceBookShare(sender: AnyObject) {
        
        //Action to share image to facebook
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            //facebookSheet.setInitialText(textField.text! as String)
            facebookSheet.addImage(imageView.image);
            self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if ((self.photo) != nil){
            //checks to make sure photo is not empty
            imageView.image = photo
        }
    }
}


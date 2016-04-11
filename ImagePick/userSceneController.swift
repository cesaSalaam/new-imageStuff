//
//  userSceneController.swift
//  ImagePick
//
//  Created by Lifoma Salaam on 3/18/16.
//  Copyright © 2016 CesaSalaam. All rights reserved.
//

import UIKit
class userViewController: UIViewController, UITableViewDelegate{
    
    @IBAction func logOut(sender: AnyObject) {
        KCSUser.activeUser().logout()
        self.performSegueWithIdentifier("backToLogIn", sender: self)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        //sets number of sections in table
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // returns the number of rows in section
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        //loads data into cells
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = "Image Picker"
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("imageViewSegue", sender: self)
    }

//    override func viewWillAppear(animated: Bool) {
//        self.initializeKinvey()
//        KCSPing.pingKinveyWithBlock { (result: KCSPingResult!) -> Void in
//            if result.pingWasSuccessful {
//                NSLog("Kinvey Ping Success")
//                if KCSUser.activeUser() == nil{
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let vc = storyboard.instantiateViewControllerWithIdentifier("User")
//                    self.presentViewController(vc, animated: true, completion: nil)
//                }
//                else{
//                    //User is already logged in----skip to user page.
//                    print("you have a user")
//                }
//            } else {
//                NSLog("Kinvey Ping Failed")
//            }
//        }
//    }
//    
//    func initializeKinvey(){
//        KCSClient.sharedClient().initializeKinveyServiceForAppKey(
//            "kid_-J1AyUJF1Z",
//            withAppSecret: "29d0b4f0f19d4a10ad8f18667edd9ddd",
//            usingOptions: nil
//        )
//    }
    
}

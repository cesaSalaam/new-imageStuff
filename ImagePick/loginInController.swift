//
//  loginInController.swift
//  ImagePick
//
//  Created by Lifoma Salaam on 3/16/16.
//  Copyright © 2016 CesaSalaam. All rights reserved.
//

import UIKit

class logInController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var password: UITextField!
    @IBOutlet var username: UITextField!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        return true;
    }
    @IBAction func logIn(sender: AnyObject) {
        KCSUser.loginWithUsername(
            self.username.text!,
            password: self.password.text!,
            withCompletionBlock: { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
                if errorOrNil == nil {
                    //the log-in was successful and the user is now the active user and credentials saved
                    //hide log-in view and show main app content
                    self.performSegueWithIdentifier("toUser", sender: nil)
                } else {
                    //there was an error with the update save
                    let message = errorOrNil.localizedDescription
                    let alert = UIAlertView(
                        title: NSLocalizedString("Create account failed", comment: "Sign account failed"),
                        message: message,
                        delegate: nil,
                        cancelButtonTitle: NSLocalizedString("OK", comment: "OK")
                    )
                    alert.show()
                }
            }
        )
        //self.createUser(self.username.text!, password: self.password.text!)
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.initializeKinvey()
        KCSPing.pingKinveyWithBlock { (result: KCSPingResult!) -> Void in
            if result.pingWasSuccessful {
                NSLog("Kinvey Ping Success")
                if KCSUser.activeUser() == nil{
                }
                else{
                    //User is already logged in----skip to user page.
                    print("you have a user")
                    self.performSegueWithIdentifier("toUser", sender: nil)
                }
            } else {
                NSLog("Kinvey Ping Failed")
            }
        }
    }
    
    func initializeKinvey(){
        KCSClient.sharedClient().initializeKinveyServiceForAppKey(
            "kid_-J1AyUJF1Z",
            withAppSecret: "29d0b4f0f19d4a10ad8f18667edd9ddd",
            usingOptions: nil
        )
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
}

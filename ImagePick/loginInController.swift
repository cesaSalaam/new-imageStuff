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
    
    @IBAction func logIn(sender: AnyObject) {
        //Action to log users in.
        KCSUser.loginWithUsername(
            self.username.text!,
            password: self.password.text!,
            withCompletionBlock: { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
                if errorOrNil == nil {
                    //the log-in was successful and the user is now the active user and credentials saved
                    //hide log-in view and show main app content
                    self.performSegueWithIdentifier("toMain", sender: nil)
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
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        //resigns keyboard when background is tapped
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func viewWillAppear(animated: Bool) {
        //hides navigation bar back button on login Screen
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
}

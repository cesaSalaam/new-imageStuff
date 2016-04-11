//
//  signUpView.swift
//  ImagePick
//
//  Created by Lifoma Salaam on 3/20/16.
//  Copyright © 2016 CesaSalaam. All rights reserved.
//

import UIKit

class signUpView: UIViewController, UITextFieldDelegate {
    
    //MARK: Outlets, Actions and Variables
    
    @IBOutlet var username: UITextField!
    
    @IBOutlet var dateTextField: UITextField!
    
    @IBOutlet var password: UITextField!
    
    var datePicker = UIDatePicker()
    
    @IBAction func createAccount(sender: AnyObject) {
        //Action for clicking Create Account button
        //Makes sure there are no spaces in username and password
        
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        let userNameText = username.text
        let passwordText = password.text
        var finalUserNameText = ""
        var finalPasswordText = ""
        
        if userNameText!.stringByTrimmingCharactersInSet(whitespaceSet) == "" {
            print("first if")
            // this statement stops user from being able to add white spaces to table
            return
        }
        if userNameText![userNameText!.endIndex.predecessor()] == " "{
            print(userNameText?.characters.count)

            for char in userNameText!.characters{
                if char != " "{
                    finalUserNameText.append(char)
                }
            }
            return
        }
        if passwordText!.stringByTrimmingCharactersInSet(whitespaceSet) == "" {
            // this statement stops user from being able to add white spaces to table
            return
        }
        if passwordText![passwordText!.endIndex.predecessor()] == " "{
            
            print(passwordText?.characters.count)
            
            for char in passwordText!.characters{
                
                if char != " "{
                    
                    finalPasswordText.append(char)
                    
                }
            }
            createUser(finalUserNameText, password: finalPasswordText)
            self.performSegueWithIdentifier("userPage", sender: nil)
            return
        }
        createUser(userNameText!, password: passwordText!)
        self.performSegueWithIdentifier("userPage", sender: nil)
        //Handle space after word
    }
    
    func createUser(name: String, password: String){
        //Function to create new user with given parameters
        KCSUser.userWithUsername(
            name,
            password: password,
            fieldsAndValues: nil,
            withCompletionBlock: { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
                if errorOrNil == nil {
                    print(user)
                } else {
                    //there was an error with the create
                    print(errorOrNil)
                }
            }
        )
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        //Function to dissmiss keyboard when view is clicked
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeDatePicker()
    }
}

// MARK: DatePicker Code

extension signUpView{

    func initializeDatePicker() {
        
        datePicker.datePickerMode = UIDatePickerMode.Date
        
        // this will make the picker appear, when the date
        // needs to be set
        dateTextField.inputView = datePicker
        dateTextField.textAlignment = .Center
        
        // set the tool bar
        let toolBar = UIToolbar(frame: CGRect.init(x:0, y:0, width:320, height:44))
        toolBar.tintColor = UIColor.grayColor()
        
        let doneBtn = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(signUpView.datePickerChanged))
        
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(signUpView.datePickerCancelled))
        
        let spacerBtn = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([doneBtn,spacerBtn,cancelBtn], animated: true)
        dateTextField.inputAccessoryView = toolBar
    }

    @IBAction func editingbegan(sender: AnyObject) {
        dateTextField.becomeFirstResponder()
    }
    
    func datePickerCancelled() {
        dateTextField.resignFirstResponder()
    }
    
    func datePickerChanged() {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        dateTextField.text = strDate
        dateTextField.resignFirstResponder()
    }

}

//
//  ViewController.swift
//  ImagePick
//
//  Created by Lifoma Salaam on 3/14/16.
//  Copyright © 2016 CesaSalaam. All rights reserved.
//

//MARK: Imports

import UIKit
import AVFoundation
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    //MARK: Outlets and Actions
    @IBOutlet var imagePreview: UIButton!
    @IBOutlet var takePhotoBtn: UIButton!
    @IBOutlet var uploadBTN: UIButton!
    
    @IBAction func tappedPreviewImageBtn(sender: AnyObject) {
        self.performSegueWithIdentifier("viewCollection", sender: imagePreview)
    }
    
    @IBAction func logout(sender: AnyObject) {
        if KCSUser.activeUser() == nil{
        
        }else{
        KCSUser.activeUser().logout()
        self.performSegueWithIdentifier("backToLogIn", sender: self)
        }
    }
    
    //MARK: Variables
    
    let imagePicker = UIImagePickerController()
    
    var captureSession: AVCaptureSession?
    
    var stillImageOutput: AVCaptureStillImageOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    //MARK: Functions for View
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        importantImageStuff()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Bringing all elements to the front of the view
        view.bringSubviewToFront(takePhotoBtn)
        view.bringSubviewToFront(uploadBTN)
        view.bringSubviewToFront(imagePreview)
        previewLayer!.frame = self.view.layer.frame // setting the bound the of previewlayer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        KCSPing.pingKinveyWithBlock { (result: KCSPingResult!) -> Void in
            if result.pingWasSuccessful {
                NSLog("Kinvey Ping Success")
                if KCSUser.activeUser() == nil{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewControllerWithIdentifier("Login") as! logInController
                    self.presentViewController(viewController, animated: true, completion: nil)
                }
                else{
                    //User is already logged in----skip to user page.
                    print("you have a user")
                }
            } else {
                NSLog("Kinvey Ping Failed")
            }
        }
    }
    
}

//MARK: SavingData
extension ViewController{

    func saveImageToCoreData(image: UIImage) -> Void {
        //Convert image to JPEG
        let imageData = UIImageJPEGRepresentation(image, 1)
        
        //Get the description of the entiti
        let storeDescription = NSEntityDescription.entityForName("Store", inManagedObjectContext: moContext)
        let store = Store(entity: storeDescription!, insertIntoManagedObjectContext: moContext)
        store.picture = imageData
    }
    
    func saveImageObject(image: UIImage){
        
        self.saveImageToCoreData(image) // Saving image to core Data
        
        let data = UIImageJPEGRepresentation(image, 0.9)
        KCSFileStore.uploadData(data, options: nil, completionBlock: { (uploadInfo: KCSFile!, error: NSError!) -> Void in
            print("Upload finished. File id=\(uploadInfo.fileId), error=\(error)")
            
            }, progressBlock: nil)
        
        //Creating imageStore to save image to
        let imageStore = KCSAppdataStore.storeWithOptions([
            KCSStoreKeyCollectionName : "imageInfo",
            KCSStoreKeyCollectionTemplateClass : imageObject.self
            ])
        //creating new image object and adding data to object
        let newImage = imageObject()
        newImage.name = "test image"
        newImage.place = "newsYork"
        newImage.image = image
        
        imageStore.saveObject(
            newImage,
            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                if errorOrNil != nil {
                    //save failed
                    NSLog("Save failed, with error: %@", errorOrNil.localizedFailureReason!)
                } else {
                    //save was successful
                    NSLog("Successfully saved event (id='%@').", (objectsOrNil[0] as! NSObject).kinveyObjectId())
                }
            },
            withProgressBlock: nil
        )
    }

}

//MARK: ImagePicker and image capture

extension ViewController{

    @IBAction func capturePhoto(sender: AnyObject) {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.imagePreview.setImage(image, forState: .Normal)
                    self.saveImageObject(image) // Saving image captured to kinvey backend
                }
            })
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: nil)
        let backgroundImage = UIImageView(image: image)
        self.view.insertSubview(backgroundImage, atIndex: 0)
        self.view.bringSubviewToFront(backgroundImage)
        self.imagePreview.setImage(image, forState: .Normal)
        self.saveImageObject(image)
        
    }
    
    @IBAction func uploadButtonTapped(sender: AnyObject) {
        //action to allow users to choose a photo to save
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            captureSession?.stopRunning()
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func importantImageStuff() ->Void {
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewLayer?.frame = self.view.layer.frame
                view.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
    }
}
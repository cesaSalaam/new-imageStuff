//
//  ViewController.swift
//  ImagePick
//
//  Created by Lifoma Salaam on 3/14/16.
//  Copyright © 2016 CesaSalaam. All rights reserved.
//
// test

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    //MARK Outlets
    @IBOutlet var imagePreview: UIButton!
    @IBOutlet var takePhotoBtn: UIButton!
    @IBOutlet var uploadBTN: UIButton!
    
    
    let imagePicker = UIImagePickerController()
    
    var captureSession: AVCaptureSession?
    
    var stillImageOutput: AVCaptureStillImageOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    @IBAction func tappedPreviewImageBtn(sender: AnyObject) {
        
        self.performSegueWithIdentifier("showImage", sender: imagePreview)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender:AnyObject?)
    { // sending image to another view
        if segue.identifier == "showImage"{
            let destViewController: showImageViewController = segue.destinationViewController as! showImageViewController
            
            destViewController.photo = imagePreview.imageView?.image
        }
    }
    
    
    func saveImageObject(image: UIImage){
        //function to save images to backend
        
        let data = UIImageJPEGRepresentation(image, 0.9)
        KCSFileStore.uploadData(data, options: nil, completionBlock: { (uploadInfo: KCSFile!, error: NSError!) -> Void in
            print("Upload finished. File id=\(uploadInfo.fileId), error=\(error)")
            
            }, progressBlock: nil)
        //Creating imageStore to save image to
        let imageStore = KCSLinkedAppdataStore.storeWithOptions([
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
    }
    
}
//Mark: ImagePicker stuff and image capture stuff
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

















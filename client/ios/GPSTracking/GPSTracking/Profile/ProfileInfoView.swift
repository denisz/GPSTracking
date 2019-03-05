//
//  ProfileInfoViewController.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/9/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import IDMPhotoBrowser
import FXBlurView
import Kingfisher
import Photos
import TOCropViewController


@objc(ProfileInfoView) class ProfileInfoView: UIView, IDMPhotoBrowserDelegate {
    var model: User?
    
    var parentNavigationController  : UINavigationController?
    var parentViewController        : UIViewController?
    
    @IBOutlet weak var buttonSpeech     : UIButton?
    @IBOutlet weak var buttonSettings   : UIButton?
    @IBOutlet weak var avatar           : UIImageView?
    @IBOutlet weak var avatarBack       : UIImageView?
    @IBOutlet weak var fullname         : UILabel?
    @IBOutlet weak var avatarContainer  : UIView?
    
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)        
        xibSetup()
        setupGesture()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
        setupGesture()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "ProfileInfoView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    func setupGesture() {
       let gestureSettings = UITapGestureRecognizer(target: self, action: "didTapSettings:")
        buttonSettings!.addGestureRecognizer(gestureSettings)
        
        let gestureSpeech = UITapGestureRecognizer(target: self, action: "didTapChangeAvatar:")
        buttonSpeech!.addGestureRecognizer(gestureSpeech)
        
        let gestureAvatar = UITapGestureRecognizer(target: self, action: "didTapAvatar:")
        avatar!.addGestureRecognizer(gestureAvatar)
    }
    
    func setupView() {
        buttonSettings!.hidden      = !model!.isCurrentUser()
        buttonSpeech!.hidden        = !model!.isCurrentUser()
        
        setupButton()
        setupAvatar()
        setupAvatarBack()
        setupFullName()
    }
    
    func setupAvatarBack() {
        avatarBack!.kf_setImageWithURL(
              model!.absolutePathForCover()
            , placeholderImage: nil
            , optionsInfo: nil
            , progressBlock: nil
            , completionHandler: { (image, error, cacheType, imageURL) -> () in
                //в другой поток вынести
                if error == nil {
                    let bluredImage = image!.blurredImageWithRadius(15, iterations: 3, tintColor: UIColor(red:0.18, green:0.24, blue:0.31, alpha:1))
                    self.avatarBack!.image = bluredImage
                }
            })
    }
    
    func setupFullName() {
        let fullname = self.fullname!
        
        fullname.text = model!.fullname()
        fullname.layer.shadowColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:0.5).CGColor
        fullname.layer.shadowOpacity = 0.5
        fullname.layer.shadowRadius = 3
        fullname.layer.shadowOffset = CGSizeMake(1.0, 1.0)
    }
    
    func setupAvatar() {
        let avatar = self.avatar!
        
        avatar.kf_setImageWithURL(model!.absolutePathForAvatar())
        
        avatar.layer.shadowColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1).CGColor
        avatar.layer.shadowOpacity = 0.5
        avatar.layer.shadowRadius = 2
        avatar.layer.shadowOffset = CGSizeMake(3.0,3.0)
    }
    
    func setupButton() {
        let buttonSpeech = self.buttonSpeech!
        buttonSpeech.layer.shadowColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1).CGColor
        buttonSpeech.layer.shadowOpacity = 0.5
        buttonSpeech.layer.shadowRadius = 2
        buttonSpeech.layer.shadowOffset = CGSizeMake(3.0,3.0)
        
        let buttonSettings = self.buttonSettings!
        buttonSettings.layer.shadowColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1).CGColor
        buttonSettings.layer.shadowOpacity = 0.5
        buttonSettings.layer.shadowRadius = 2
        buttonSettings.layer.shadowOffset = CGSizeMake(3.0,3.0)
    }
    
    func updateAvatar() {
        setupAvatar()
        setupAvatarBack()
    }
    
    func didTapSettings(sender:UIButton!) {
        let settingsController: UIViewController! = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("settingsViewController")
        
        self.parentNavigationController!.pushViewController(settingsController, animated: true)
    }
    
    func didTapSpeech(sender: UITapGestureRecognizer) {
        //открыть комментариий
    
    }
    
    func didTapChangeAvatar(sender: UITapGestureRecognizer) {
        presentImagePickerSheet(sender.view!)
    }
    
    func didTapAvatar(sender: UITapGestureRecognizer) {
        let currentPhoto = IDMPhoto(URL: model!.absolutePathForCover(true))
        
        let browser: IDMPhotoBrowser = IDMPhotoBrowser(photos: [currentPhoto])
        
        browser.delegate = self
        browser.displayActionButton = false
        browser.displayArrowButton = false
        browser.displayCounterLabel = false
        browser.displayDoneButton = true
        browser.usePopAnimation = false
        browser.useWhiteBackgroundColor = false
        
        self.parentViewController!.presentViewController(browser, animated: true, completion: nil)
    }
    
    func loadModel(model: User) {
        self.model = model
        setupView()
    }
}

extension ProfileInfoView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentImagePickerSheet(view: UIView) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentImagePickerSheet(view)
                }
            }
            
            return
        }
        
        if authorization == .Authorized {
            let presentImagePickerController: UIImagePickerControllerSourceType -> () = { source in
                let controller = UIImagePickerController()
                controller.delegate = self
                var sourceType = source
                
                if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                    sourceType = .PhotoLibrary
                    print("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
                }
                
                controller.sourceType = sourceType
                
                self.parentNavigationController!.presentViewController(controller, animated: true, completion: nil)
            }
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let cameraAction = UIAlertAction(title: "Сделать фото".localized, style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) in presentImagePickerController(.Camera) })
            
            let libraryAction = UIAlertAction(title: "Открыть библиотеку".localized, style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) in presentImagePickerController(.PhotoLibrary) })
            
            let cancelAction = UIAlertAction(title: "Закрыть".localized, style: UIAlertActionStyle.Cancel, handler: nil)
            
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(libraryAction)
            actionSheet.addAction(cancelAction)
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                actionSheet.popoverPresentationController!.sourceRect = view.bounds;
                actionSheet.popoverPresentationController!.sourceView = view;
            }
            
            self.parentNavigationController!.presentViewController(actionSheet, animated: true, completion: nil)
        }
        else {
            let alertView = UIAlertView(title: NSLocalizedString("An error occurred", comment: "An error occurred"), message: NSLocalizedString("ImagePickerSheet needs access to the camera roll", comment: "ImagePickerSheet needs access to the camera roll"), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "OK"))
            alertView.show()
        }
    }
    
    func performResizeImage(image: UIImage) {
        performUploadImage(RBResizeImage(image, targetSize: CGSizeMake(960, 960)))
    }
    
    func performUploadImage(image: UIImage) {
        let attachment = Attachment.withImage(image, scenario: "avatar")
        UploadHelper.uploadImage(attachment)
            .responseSuccess({ (request, response, JSON, error) in
                self.model!.avatarFromAttachment(attachment);
                self.updateAvatar()
                self.model!.sync().responseSuccess({(req, res, json, err) in
                    print("saving")
                })
            })
    }
    
    func performCropImage(image: UIImage) {
        let cropController: TOCropViewController = TOCropViewController(image: image)
        cropController.delegate = self
        self.parentNavigationController!.presentViewController(cropController, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        self.parentNavigationController!.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
//        performResizeImage(image)
        performCropImage(image)
//        performUploadImage(image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.parentNavigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ProfileInfoView: TOCropViewControllerDelegate  {
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        performResizeImage(image)
        self.parentNavigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cropViewController(cropViewController: TOCropViewController!, didFinishCancelled cancelled: Bool) {
        self.parentNavigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
}

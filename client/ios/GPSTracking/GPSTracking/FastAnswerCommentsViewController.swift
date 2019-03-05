//
//  FastAnswerCommentsViewController.swift
//  GPSTracking
//
//  Created by denis zaytcev on 8/3/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import Photos

let reusableAnswerMessageCell: String = "AnswerMessageViewCell"

class FastAnswerCommentsViewController: MyCollectionTableView {
    
    @IBOutlet weak var containerTextField: UIView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottom2LayoutConstraint: NSLayoutConstraint!

    var attachments: Collection<Attachment>?
    var model: Answer?
    var textField: TextFieldView?

    func loadModel(model: Answer) {
        self.model = model
    }

    override func hasContent() -> Bool {
        return true
    }

    override func nibViewCell() -> String {
        return "AnswerMessageViewCell"
    }

    override func reuseIndetifier() -> String {
        return reusableAnswerMessageCell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationController()
        setupKeyboard()
        setupTextField()
    }
    
    func configureNavigationController() {
        self.title = "Комментарии".localized
        
        if let nc = self.navigationController {
            nc.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            nc.navigationBar.barStyle = UIBarStyle.Default
            nc.navigationBar.tintColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)
        }
    }

    func setupTextField() {
        self.textField = TextFieldView()
        self.textField!.delegate = self
//        self.textField!.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.textField!.translatesAutoresizingMaskIntoConstraints = false
        self.containerTextField.addSubview(self.textField!)
        
        let views = ["view": self.textField!]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: .AlignAllCenterY, metrics: nil, views: views)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: .AlignAllCenterX, metrics: nil, views: views)
        
        self.containerTextField!.addConstraints(hConstraints)
        self.containerTextField!.addConstraints(vConstraints)
    }

    func setupKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShowNotification:"), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHideNotification:"), name: UIKeyboardWillHideNotification, object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard"))
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedIntValue << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        bottomLayoutConstraint.constant = CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame)
        bottom2LayoutConstraint.constant = CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame) + 60
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: [.BeginFromCurrentState,animationCurve], animations: {
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }

    override func tableView(tableView: UITableView, customcellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(self.reuseIndetifier()) as! AnswerMessageViewCell
        
        if self.parentNavigationController != nil {
            cell.parentNavigationController = self.parentNavigationController!
        }
        
        let model = (collection as! Collection<Comment>).valueAtIndex(indexPath.row)
        
        if model != nil {
            cell.prepareView(model!, collection: collection as! Collection<Comment>)
        }
        
        return cell
    }
}

extension FastAnswerCommentsViewController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension FastAnswerCommentsViewController: TextFieldViewDelegate {
    func textField(textField: UITextField, handlerAttach button: UIButton) {
        //прикрепляем аттач
        self.presentImagePickerSheet(button)
    }
    
    func textField(textField: UITextField, handlerSend button: UIButton, text: String) {
        //отправляем сообщение
        self.hideKeyboard()
        let comment = self.model?.createComment(text)
        comment!.events.listenTo("sync", action: {
            if let collection = self.collection as? Collection<Comment> {
                collection.prependModel(comment!)
            }
            
            if !self.model!.isAccept() {
                self.model!.changeStatus(ANSWER_ACCEPTED)
            }
        })
        
        comment!.save()
    }
}

extension FastAnswerCommentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    
    func performUploadImage(image: UIImage) {
        let attachment = Attachment.withImage(image, scenario: "answer")
        attachment.target(self.model!)
        
        UploadHelper.uploadImage(attachment)
            .responseSuccess({ (request, response, JSON, error) in
                self.attachments?.appendModel(attachment)
            })
    }
    
    func performResizeImage(image: UIImage) {
        performUploadImage(RBResizeImage(image, targetSize: CGSizeMake(1500, 1500)))
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        
        self.parentNavigationController!.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.performUploadImage(image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.parentNavigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
}


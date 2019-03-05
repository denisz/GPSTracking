//
//  FastViewController.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/27/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class FastAnswerViewController: UIViewController {
    @IBOutlet weak var attachmentsView: SliderPhotosView!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var locationView: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var wrapperDescription: UIView!
    @IBOutlet weak var wrapperDescriptionH: NSLayoutConstraint!
    
    
    var parentNavigationController: UINavigationController?
    
    var model       : Answer?
    var modelUser   : User?
    var attachments : Collection<Attachment>?
    
    func loadModel(model: Answer) {
        self.model = model
    }
    
    func loadModel(model: User) {
        self.modelUser = model
    }
    
    func loadModel(model: Event) {
        self.model      = model.getLink("answer") as? Answer
        self.modelUser  = model.getLink("user") as? User
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureNavigationController()
    }
    
    func setupViews() {
        setupAttachments()
        setupAnswerView(self.model!)
        setupUserView(self.modelUser!)
    }
    
    func setupAttachments() {
        self.attachments = self.model!.collectionAttachments()
        self.attachmentsView.parentController  = self.parentNavigationController
        self.attachmentsView.allowNewPhoto     = self.model!.isOwnerCurrentUser()
        self.attachmentsView.allowRemovePhoto  = self.model!.isOwnerCurrentUser()
        self.attachmentsView.fetchCollection(self.attachments!)
    }
    
    func setupAnswerView(model: Answer) {
        self.model = model
        self.dateView!.text = AppHelp.formatDate(model.createdAt)
        
        let localizedLocation = self.model!.valueForKey("localized_loc") as? String
        self.locationView!.text = localizedLocation ?? "Местоположение не определено".localized
        
        if let body = model.valueForKey("description") as? String {
            self.descriptionView.hidden = false
            self.descriptionView.text = body
        } else {
            self.wrapperDescriptionH.constant = 0
            self.wrapperDescription.hidden = true
        }
        

    }
    
    @IBAction func didTapAvatar() {
        if self.parentNavigationController != nil {
            let pvc: ProfileViewController! = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
            
            pvc.loadModel(model!.getOwner())
            self.parentNavigationController?.pushViewController(pvc, animated: true)
        }
    }
    
    func setupUserView(user: User) {
        let gestureAvatar = UITapGestureRecognizer(target: self, action: "didTapAvatar")
        self.avatar!.addGestureRecognizer(gestureAvatar)
        
        self.fullname!.text = user.fullname()
        self.avatar!.kf_setImageWithURL(user.absolutePathForAvatar())
    }
    
    func configureNavigationController() {
        self.title = "Ответ".localized
        
        if let nc = self.navigationController {
            nc.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            nc.navigationBar.barStyle = UIBarStyle.Default
            nc.navigationBar.tintColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)
        }
    }
    
    @IBAction func didTapComment() {
        let comments = UIStoryboard(name: "FastAnswerCommentsViewController", bundle: nil).instantiateViewControllerWithIdentifier("FastAnswerCommentsViewController") as! FastAnswerCommentsViewController
        
        comments.loadModel(self.model!)
        comments.collection = self.model!.collectionComments()
        comments.parentNavigationController = self.parentNavigationController
        comments.attachments = self.attachments
        
        self.parentNavigationController?.pushViewController(comments, animated: true)
    }
    
    func didTapBack() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func showBtnBack() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад".localized, style: UIBarButtonItemStyle.Done, target: self, action: "didTapBack")
    }
}
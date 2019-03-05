//
//  RequestInfoViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/11/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit


class RequestInfoViewController: UIViewController {
    var parentNavigationController: UINavigationController?
    var mainViewController: RequestViewController?
    
    
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var contextView: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var locationView: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var mapView: RequestMapView!
    @IBOutlet weak var mapWrapperView: UIView!
    @IBOutlet weak var guestControlPanel: UIView!
    @IBOutlet weak var userControlPanel: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var attachmentsView: SliderPhotosView!
    @IBOutlet weak var descriptionTable: StaticTableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var heightLayoutConstraint: NSLayoutConstraint!
    
    var model: Event?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        print(self.model!.data)
        setupTexts()
        setupPanels()
        setupMap()
        setupUser()
        setupAttachments()
        setupDescription()
        setupFavorite()
        setupContact()
    }
    
    func setupDescription() {
        let data = RequestHelp.parseDescription(model!)
        if data.count > 0 {
            self.descriptionTable.setData(data)
            print(self.descriptionTable.contentSize.height)
            self.heightLayoutConstraint.constant = self.descriptionTable.contentSize.height
        } else {
            self.descriptionLabel.hidden = true
        }
        
    }
    
    func setupContact() {
        self.contactButton.hidden = !self.model!.allow_contact
    }
    
    func setupAttachments() {
        self.attachmentsView.parentController = self.parentNavigationController
        self.attachmentsView.allowNewPhoto = self.model!.isOwnerCurrentUser()
        self.attachmentsView.allowRemovePhoto = self.model!.isOwnerCurrentUser()
        self.attachmentsView.fetchCollection(self.model!.collectionAttachments())
    }
    
    func setupMap() {
    }
    
    func setupUser() {
        if let user = self.model!.getLink("user") as? User {
            self.fullname.text = user.fullname()
            self.avatar.kf_setImageWithURL(user.absolutePathForAvatar())
        }
    }
    
    func setupPanels() {
        if model!.isOwnerCurrentUser() {
            self.userControlPanel.hidden = false;
        } else {
            self.guestControlPanel.hidden = false
        }
    }
    
    func setupTexts() {
        let localizedLocation   = model!.localizedLocation
        let localizedContext    = model!.combineContext
        
        let status: (color: UIColor, text: String) = defineStatus()
        
        self.locationView.text     = localizedLocation
        self.statusLabel.textColor = status.color
        self.contextView.text      = localizedContext
        self.statusLabel.text      = status.text
        self.dateView.text         = AppHelp.formatDate(model!.createdAt)
        
        self.mapView.setModel(model!)
        self.mapView.parentNavigationController = self.parentNavigationController
    }
    
    func defineStatus() -> (UIColor, String) {
        let status  = model!.defineStatus;
        let text    = defineTextStatus(status)
        let color   = defineColorStatus(status)
        
        return (color, text)
    }
    
    func defineTextStatus(status: String) -> String {
        switch status {
        case kEventDefineStatusActive:
            return "Активен".localized
        case kEventDefineStatusCanceled:
            return "Отменен".localized
        case kEventDefineStatusBanned:
            return "Забанен".localized
        default:
            return ""
        }
    }
    
    func defineColorStatus(status: String) -> UIColor {
        switch status {
        case "active":
            return UIColor(red:0.22, green:0.79, blue:0.45, alpha:1)
        case "canceled":
            return UIColor(red:0.9, green:0.3, blue:0.26, alpha:1)
        case "banned":
            return UIColor(red:0.9, green:0.3, blue:0.26, alpha:1)
        default:
            return UIColor.whiteColor()
        }
    }
    
    func performCancel() {
        model!.runAction("cancel")
            .responseSuccess({(req, res, json, err) in
                let alert = UIAlertController(title: "Сообщение".localized, message: "Ваш запрос был отменен.".localized, preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.Default, handler: nil))
                
                NSNotificationCenter.defaultCenter().postNotificationName(kEventUserCanceled, object: self.model!)
                
                self.presentViewController(alert, animated: true, completion: nil)
            })
            .responseFailed({ (req, res, json, err) -> Void in
                
            });
    }
    
    func getUserPhone() -> String? {
        if let user = self.model!.getLink("user") as? User {
            return user.phone
        }
        return nil
    }
    
    func getUserEmail() -> String? {
        if let user = self.model!.getLink("user") as? User {
            return user.email
        }
        return nil
    }
    
    func performCallTelephone() {
        if let phone = self.getUserPhone() {
            AppHelp.callByTelephone(phone)
        }
    }
    
    func performSendEmail() {
        if let email = self.getUserEmail() {
            AppHelp.sendEmail(email)
        }
    }
    
    func setupFavorite() {
        self.favoriteButton.hidden = model!.isOwnerCurrentUser()
        
        if let favorite = self.model!.getLink("favorite") as? Favorite {
            if favorite.isSync() {
                self.favoriteButton.setImage(UIImage(named: "star-check"), forState: UIControlState.Normal)
            } else {
                self.favoriteButton.setImage(UIImage(named: "start-uncheck"), forState: UIControlState.Normal)
            }
        } else {
            self.favoriteButton.hidden = true
        }
    }
    
    @IBAction func didTapFavorite() {
        if let favorite = self.model!.getLink("favorite") as? Favorite {
            if favorite.isSync() {
                favorite.remove()?.responseSuccess ({ (req, res, json, err) in
                    self.setupFavorite()
                })
            } else {
                let newFavorite = Favorite.createFromEvent(self.model!)
                newFavorite.save().responseSuccess ({ (req, res, json, err) in
                    self.model!.link(newFavorite, forKey: "favorite")
                    self.setupFavorite()
                })
            }
        }
    }
    
    @IBAction func didTapLinkAuthor() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if self.model!.allowPhone {
            if let phone = self.getUserPhone() {
                actionSheet.addAction(UIAlertAction(title: "Позвонить: \(phone)", style: .Default, handler: { (action: UIAlertAction!) in
                    self.performCallTelephone()
                }))
            }
        }
        
        if self.model!.allowEmail {
            actionSheet.addAction(UIAlertAction(title: "Отправить письмо".localized, style: .Default, handler: { (action: UIAlertAction!) in
                self.performSendEmail()
            }))
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            actionSheet.popoverPresentationController!.sourceRect = self.contactButton!.bounds;
            actionSheet.popoverPresentationController!.sourceView = self.contactButton!;
        }
        
        actionSheet.addAction(UIAlertAction(title: "Отмена".localized, style: .Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapAnswer() {
        self.mainViewController!.goToAnswer()
    }
    
    @IBAction func didTapCancel () {
        let confirm = UIAlertController(title: "Отмена".localized, message: "Вы уверены,что хотите отменить запрос?".localized, preferredStyle: UIAlertControllerStyle.Alert)
        confirm.addAction(UIAlertAction(title: "Да".localized, style: .Default, handler: { (action: UIAlertAction!) in
                self.performCancel()
        }))
        confirm.addAction(UIAlertAction(title: "Нет".localized, style: .Cancel, handler: nil))
        self.presentViewController(confirm, animated: true, completion: nil)
    }
    
    //отклонить
    @IBAction func didTapDismiss(sender: AnyObject) {
        var data: [String: AnyObject] = ["status": ANSWER_REJECTED]
        let coordinate  = LocationCore.sharedInstance.lastLocation!.coordinate
        let localized   = LocationCore.sharedInstance.lastLocationLocalized!;
        data["loc"] = [
            "type"          : "Point",
            "coordinates"   : [coordinate.longitude, coordinate.latitude]
        ]
        data["localized_loc"] = localized
        
        let answer = Answer.createFromEvent(self.model!, data: data)
        answer.save()
        
        self.parentNavigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //пожаловаться
    @IBAction func didTapAngry(sender: AnyObject) {
        let button = sender as! UIButton
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let handler: Int -> () = {reason in
            let angry = Angry.createFromModel(self.model!, reason: reason)
            angry.save()
            
            self.parentNavigationController!.dismissViewControllerAnimated(true, completion: nil)
        };
        
        let reasons = [
            "Спам",
            "Десткая порнография",
            "Экстремизм",
            "Насилие",
            "Пропаганда наркотиков",
            "Гей пропаганда",
            "Материал для взрослых",
            "Оскорбление"
        ]
        
        for (index, reason) in reasons.enumerate() {
            actionSheet.addAction(UIAlertAction(title: reason.localized, style: .Default, handler: { (action: UIAlertAction!) in
                handler(index)
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Отмена".localized, style: .Cancel, handler: nil))
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            actionSheet.popoverPresentationController!.sourceRect = button.bounds;
            actionSheet.popoverPresentationController!.sourceView = button;
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }

}
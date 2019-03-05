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
    
    
    @IBOutlet var dateView: UILabel?
    @IBOutlet var contextView: UILabel?
    @IBOutlet var descriptionView: UITextView?
    @IBOutlet var locationView: UILabel?
    @IBOutlet var fullname: UILabel?
    @IBOutlet var avatar: UIImageView?
    @IBOutlet var mapView: RequestMapView?
    @IBOutlet var mapWrapperView: UIView?    
    @IBOutlet var guestControlPanel: UIView?
    @IBOutlet var userControlPanel: UIView?
    @IBOutlet var statusLabel: UILabel?
    @IBOutlet var attachmentsView: SliderPhotosView?
    @IBOutlet var descriptionTable: StaticTableView?
    
    var model: Event?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    @IBAction func indexChanged(sender: AnyObject) {
        let segment = sender as! UISegmentedControl
        println(segment.selectedSegmentIndex)
    }
    
    func setupViews() {
        println(self.model!.data)
        setupTexts()
        setupPanels()
        setupMap()
        setupUser()
        setupAttachments()
        setupDescription()
    }
    
    func setupDescription() {
        self.descriptionTable!.setData(RequestHelp.parseDescription(model!))
    }
    
    func setupAttachments() {
        self.attachmentsView!.parentController = self.parentNavigationController
        self.attachmentsView!.allowNewPhoto = self.model!.isOwnerCurrentUser()
        self.attachmentsView!.fetchCollection(self.model!.collectionAttachments())
    }
    
    func setupMap() {
        let gestureTap = UITapGestureRecognizer(target: self, action: Selector("didTapMap:"))
        self.mapWrapperView!.addGestureRecognizer(gestureTap)
        self.mapWrapperView!.userInteractionEnabled = true
    }
    
    func setupUser() {
        let user = self.model!.getLink("user") as? User
        self.fullname!.text = user!.fullname()
        self.avatar!.kf_setImageWithURL(user!.absolutePathForAvatar())
    }
    
    func setupPanels() {
        if model!.isOwnerCurrentUser() {
            self.userControlPanel!.hidden = false;
        } else {
            self.guestControlPanel!.hidden = false
        }
    }
    
    func setupTexts() {
        var desc        = model!.valueForKey("description") as? String
        var rawDate     = model!.valueForKey("created_at") as! String
        
        var criteria            = model!.valueForKey("criteria") as! [String: AnyObject]
        var context             = criteria["context"] as! String
        var subtype             = criteria["subtype"] as? String
        var localizedLocation   = model!.valueForKey("localized_loc") as? String
        var localizedContext    = EventHelper.contextByValue(context)!["title"] as! String
        
        //self.descriptionView!.text = RequestHelp.parseDescription(model!)
        
        if localizedLocation != nil {
            self.locationView!.text = localizedLocation!
        }
        
        if subtype != nil {
            var localizedSubtype = EventHelper.subtypeByValue(subtype!)!["title"] as! String
            localizedContext = "\(localizedContext) : \(localizedSubtype)"
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
        let date = dateFormatter.dateFromString(rawDate)
        
        var status: (color: UIColor, text: String) = defineStatus()
        
        self.dateView!.text         = date!.timeAgo
        self.contextView!.text      = localizedContext
        self.statusLabel!.textColor = status.color
        self.statusLabel!.text      = status.text
        
        self.mapView?.setLocation(model!.location())
    }
    
    func defineStatus() -> (UIColor, String) {
        var status = model!.valueForKey("status") as! String
        var text = defineTextStatus(status)
        var color = defineColorStatus(status)
        
        return (color, text)
    }
    
    func defineTextStatus(status: String) -> String {
        switch status {
        case "active":
            return "Активный"
        case "canceled":
            return "Отмененный"
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
        default:
            return UIColor.whiteColor()
        }
    }
    
    func performCancel() {
        model!.runAction("cancel")
            .responseSuccess({(req, res, json, err) in
                var alert = UIAlertController(title: "Сообщение", message: "Ваш запрос был отменен.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
            .responseFailed({ (req, res, json, err) -> Void in
                
            });
    }
    
    @IBAction func didTapMap(recognizer: UITapGestureRecognizer) {
        let mapViewController: RequestMapViewController = UIStoryboard(name: "RequestMapViewController", bundle: nil).instantiateViewControllerWithIdentifier("requestMapView") as! RequestMapViewController
        
        self.parentNavigationController!.pushViewController(mapViewController, animated: true){
            mapViewController.mapView!.setLocation(self.model!.location())
        }
    }
    
    @IBAction func didTapAnswer() {
        self.mainViewController!.goToAnswer()
    }
    
    @IBAction func didTapCancel () {
        var confirm = UIAlertController(title: "Отмена", message: "Вы уверены,что хотите отменить запрос?", preferredStyle: UIAlertControllerStyle.Alert)
        
        confirm.addAction(UIAlertAction(title: "Да", style: .Default, handler: { (action: UIAlertAction!) in
                self.performCancel()
        }))
        
        confirm.addAction(UIAlertAction(title: "Нет", style: .Cancel, handler: nil))
        
        self.presentViewController(confirm, animated: true, completion: nil)
    }
    
    @IBAction func didTapAngry() {
        println("Angry user")
    }

}
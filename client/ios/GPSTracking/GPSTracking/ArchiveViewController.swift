//
//  File.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/9/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import XLForm

class ArchiveViewController: XLFormViewController {
    var collection  : Collection<Event>?
    var filter      : Filter?
    var formData    : [String: AnyObject]?
    var rowMap      : XLFormRowDescriptor?
    
    struct tag {
        static let context  = "context"
        static let subtype  = "subtype"
        static let button   = "submit"
        static let dateFrom = "from"
        static let dateTo   = "to"
        static let location = "loc"
        static let address  = "address"
    }
    
    func initializeForm() {
        self.formData = [:]
        self.form = XLFormDescriptor()
        
        addMapDescriptor()
        addTimeRange()
        addContextDescriptor()
        addButtonSubmit()
    }
    
    func selectorsByArray(options: [[String: AnyObject]]) -> [XLFormOptionsObject]{
        var result = [XLFormOptionsObject]()
        
        for item in options {
            let obj = XLFormOptionsObject(value: item["value"] as? String, displayText: item["title"] as? String)
            result.append(obj)
        }
        
        return result
    }
    
    func addContextDescriptor() {
        let section = XLFormSectionDescriptor.formSectionWithTitle("Ситуация".localized) as XLFormSectionDescriptor
        self.form.addFormSection(section)
        
        let row = XLFormRowDescriptor(tag: tag.context, rowType: XLFormRowDescriptorTypeSelectorPush, title:"Ситуация".localized)
        self.stylesRow(row)
        row.selectorOptions = self.selectorsByArray(EventHelper.contextByArray(EventInArchive));
        section.addFormRow(row)
    }
    
    func addMapDescriptor() {
        let section = XLFormSectionDescriptor.formSectionWithTitle("Адрес".localized) as XLFormSectionDescriptor
        self.form.addFormSection(section)

        //map
        var row = XLFormRowDescriptor(tag: tag.location, rowType: XLFormRowDescriptorTypeMapView)
        row.action.viewControllerStoryboardId = "ChoicePointInMapViewController"
        row.cellOptions.setObject(true, forKey: "drawCircle")
        section.addFormRow(row)
        rowMap = row
        
        //address
        row = XLFormRowDescriptor(tag: tag.address, rowType: XLFormRowDescriptorTypeButton)
        row.action.viewControllerStoryboardId = "GoogleAutocompleteViewController"
        
        row.cellConfig.setObject(UIFont(name: "Helvetica", size: 13)!, forKey: "textLabel.font")
        row.cellConfig.setObject(2, forKey: "textLabel.numberOfLines")
        
        section.addFormRow(row)
    }
    
    // MARK: - Button submit
    func addButtonSubmit() {
        let section = XLFormSectionDescriptor.formSection()
        self.form.addFormSection(section)
        
        let row = XLFormRowDescriptor(tag: tag.button, rowType: XLFormRowDescriptorTypeButton, title: "Найти".localized)
        row.cellConfig.setObject(UIColor(red:0.28, green:0.31, blue:0.32, alpha:1), forKey: "textLabel.textColor")
        row.action.formSelector = Selector("didTapSearch:")
        section.addFormRow(row)
    }
    
    func addTimeRange() {
        let section = XLFormSectionDescriptor.formSectionWithTitle("Время")
        var row: XLFormRowDescriptor
        
        row = XLFormRowDescriptor(tag: tag.dateFrom, rowType: XLFormRowDescriptorTypeDateTime, title: "С")
        self.stylesRow(row)
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: tag.dateTo, rowType: XLFormRowDescriptorTypeDateTime, title: "По")
        self.stylesRow(row)
        section.addFormRow(row)
        
        self.form.addFormSection(section)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.initializeForm()
        self.initializeFilter()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupViews() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "didTapBack")
    }
    
    func initializeFilter() {
        self.filter = ArchiveFilter();
    }
    
    func didTapBack() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func prepareFilter() {
        var formData = self.formData!
        var data = [String: AnyObject]()
        
        data[tag.context]  = formData[tag.context]
        data[tag.subtype]  = formData[tag.subtype]
        data[tag.dateTo]   = formData[tag.dateTo]
        data[tag.dateFrom] = formData[tag.dateFrom]
        
        if let location = formData[tag.location] as? CLLocation {
            data[tag.location] = [
                "type"          : "Point",
                "coordinates"   : [location.coordinate.longitude, location.coordinate.latitude]
            ]
        }

        self.filter!.setData(data)
    }
    
    func getCollection() -> Collection<Event>{
        let collection = Collection<Event>()
        collection.link(Collection<User>(), forKey: "user")
        collection.use(API.list("event", destination: "filter")) //event/list/filter
        collection.setFilter(self.filter!)
        
        prepareFilter()
        
        return collection
    }
    
    func didTapSearch(sender: XLFormRowDescriptor) {
        let requests: RequestsViewController = UIStoryboard(name: "RequestsViewController", bundle: nil).instantiateViewControllerWithIdentifier("requestsViewController") as! RequestsViewController
        
        requests.title = "Запросы".localized
        requests.collection = getCollection()
        requests.parentNavigationController = self.navigationController
        
        self.navigationController!.pushViewController(requests, animated: true)        
    }
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        
        let formTag = formRow.tag!
        
        if formTag == tag.dateTo {
            formData![tag.dateTo] = "\(newValue)"
        }
        
        if formTag == tag.dateFrom {
            formData![tag.dateFrom] = "\(newValue)"
        }
        
        if formTag == tag.context {
            if newValue is XLFormOptionObject {
                let _v = newValue as! XLFormOptionObject
                formData![tag.context] = _v.formValue()
            } else {
                formData![tag.context] = "\(newValue)"
            }
        }
        
        if formTag == tag.address {
            let annotation = newValue as! GoogleAutocompleteAnnotation
            formRow.title = annotation.desc
            
            let row = self.form.formRowWithTag(tag.location)
            let coord = annotation.location.coordinate
            row!.value = [coord.latitude, coord.longitude]
            
            self.updateFormRow(row)
            
            formData![tag.location] = annotation.location
            //значение присвоить для location
        }
        
        //выбрали место на карте 
        //делаем запрос на получени имени
        if formTag == tag.location {
            if newValue is [CLLocationDegrees] {
                var coord  = newValue as! [CLLocationDegrees]
                let loc    = CLLocation(latitude: coord[0], longitude: coord[1])
                
                LocationCore.sharedInstance.whatIsThisPlace(loc, cb: {(place: String) in
                    let row = self.form.formRowWithTag(tag.address)
                    row!.title = place
                    self.updateFormRow(row)
                })
                
                formData![tag.location] = loc
            } else {
                formData!.removeValueForKey(tag.location)
                let row = self.form.formRowWithTag(tag.address)
                row!.title = ""
                self.updateFormRow(row)
            }
            
            //значение присовить для address
        }
    }
    
    func stylesRow(row: XLFormRowDescriptor) {
        row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
        row.cellConfig.setObject(UIColor(red:0.28, green:0.31, blue:0.32, alpha:1), forKey: "textLabel.color")
        row.cellConfig.setObject(UIFont(name: "Helvetica Neue", size: 16)!, forKey: "textLabel.font")
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle  {
        return .Default
    }
}
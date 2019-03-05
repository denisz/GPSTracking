//
//  NewRequestViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/10/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import XLForm

class NewRequestViewController: XLFormViewController, XLFormDescriptorDelegate {
    var rowType: XLFormRowDescriptor?
    var rowSubtype: XLFormRowDescriptor?
    
    var typeSection         : XLFormSectionDescriptor?
    var subtypeSection      : XLFormSectionDescriptor?
    var descriptionSection  : XLFormSectionDescriptor?
    var submitSection       : XLFormSectionDescriptor?
    var extraSection        : XLFormSectionDescriptor?
    
    var criteriaData: [String: AnyObject]?
    var formData    : [String: AnyObject]?
    var extraData   : [String: AnyObject]?
    
    struct tag {
        static let type     = "context"
        static let subtype  = "subtype"
        static let button   = "submit"
        static let textView = "description"
        static let extra    = "extra"
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.initializeForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initializeForm() {
        var form    : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row     : XLFormRowDescriptor
        
        self.formData       = [:]
        self.criteriaData   = [:]
        self.extraData      = [:]
        
        form = XLFormDescriptor(title: "Запрос") as XLFormDescriptor
        
        self.form = form;
        
        addSelectorTypeOptions();
    }
    
    func selectorsByArray(key: String, options: [[String: String]]) -> [XLFormOptionsObject]{
        var result = [XLFormOptionsObject]()
        var option: [String: String]
        
        for option in options {
            var data = ["key" : key, "value" : option["value"]!]
            var obj = XLFormOptionsObject(value: data, displayText: option["title"])
            
            result.append(obj)
        }
        
        return result
    }
    
    func removeRowByExclude(exclude: XLFormRowDescriptor, section: XLFormSectionDescriptor) {
        var rows = section.formRows
        
        for row in rows {
            if row as! XLFormRowDescriptor != exclude {
                section.removeFormRow(row as! XLFormRowDescriptor)
            }
        }
    }

    // MARK: - Button submit
    func addButtonSubmit() {
        removeButtonSubmit()
        
        var section = XLFormSectionDescriptor.formSectionWithTitle("") as XLFormSectionDescriptor
        self.form.addFormSection(section)
        
        var row = XLFormRowDescriptor(tag: tag.button, rowType: XLFormRowDescriptorTypeButton, title: "SOS")
        row.cellConfig.setObject(UIColor(red:0.09, green:0.34, blue:0.52, alpha:1), forKey: "textLabel.textColor")
        row.action.formSelector = Selector("didTouchButton:")
        section.addFormRow(row)
        
        self.submitSection = section
    }
    
    func removeButtonSubmit() {
        if let section = self.submitSection {
            self.form.removeFormSection(section)
        }
        
        self.submitSection = nil
    }
    
    
    // MARK: - Description
    func addDescription() {
        removeDescription()
        
        var section = XLFormSectionDescriptor.formSectionWithTitle("Комментарий") as XLFormSectionDescriptor
        self.form.addFormSection(section)
        
        var row = XLFormRowDescriptor(tag: tag.textView, rowType: XLFormRowDescriptorTypeTextView)
        row.cellConfigAtConfigure.setObject("Оставьте свой комментарий", forKey: "textView.placeholder")
        section.addFormRow(row)
        
        self.descriptionSection = section
    }
    
    func removeDescription() {
        if let section = self.descriptionSection {
            self.form.removeFormSection(section)
        }
        
        self.descriptionSection = nil
    }
    
    // MARK: - Type
    func addSelectorTypeOptions() {
        removeTypes()
        
        var context   = EventHelper.context()
        var section = XLFormSectionDescriptor.formSectionWithTitle("Ситуация") as XLFormSectionDescriptor
        
        for item in context {
            var row = XLFormRowDescriptor(tag: tag.type, rowType: XLFormRowDescriptorTypeButton, title: item["title"] as? String)
            row.value = item["value"] as? String
            row.action.formSelector = Selector("didTouchType:");
            row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
            row.cellConfig.setObject(10, forKey: "cornerRadius")
            row.cellConfig.setObject(UIColor(red:0.09, green:0.34, blue:0.52, alpha:1), forKey: "backgroundColor")
            row.cellConfig.setObject(UIColor.whiteColor(), forKey: "textLabel.color")
            
            
            
            row.cellConfig.setObject(1, forKey: "borderWidth")
            section.addFormRow(row);
        }
        
        self.typeSection = section
        
        self.form.addFormSection(section, atIndex: 0)
    }
    
    func removeTypes() {
        if let section = self.typeSection {
            self.form.removeFormSection(section)
        }
        
        self.typeSection = nil
    }
    
    //MARK: - Extra
    
    func addSelectorExtra(value: String ) {
        removeExtra()
        
        var extra = EventHelper.extraByType(value)
        
        if extra?.count > 0 {
            var section = XLFormSectionDescriptor.formSectionWithTitle("") as XLFormSectionDescriptor
            
            for item in extra! {
                var row = XLFormRowDescriptor(tag: tag.extra, rowType:             XLFormRowDescriptorTypeSelectorPickerViewInline, title: item["title"] as? String)
                
                row.selectorOptions = selectorsByArray(item["value"] as! String, options: (item["selectors"] as? [[String: String]])!)
                section.addFormRow(row);
            }
            
            self.extraSection = section
            form.addFormSection(section, atIndex: 2)
        }
    }
    
    func removeExtra() {
        if let section = self.extraSection {
            self.form.removeFormSection(section)
        }
        
        self.extraSection = nil
    }
    
    // MARK: - SubType
    func removeSubtypes() {
        if let section = self.subtypeSection {
            self.form.removeFormSection(section)
        }
        
        self.subtypeSection = nil
    }
    
    func addSelectorSubTypeOptions(value: String ) {
        removeSubtypes();
        
        var subtypes = EventHelper.subtypesByType(value)
        
        if subtypes?.count > 0 {
            var section = XLFormSectionDescriptor.formSectionWithTitle("Что случилось?") as XLFormSectionDescriptor
            
            for item in subtypes! {
                var row = XLFormRowDescriptor(tag: tag.subtype, rowType: XLFormRowDescriptorTypeButton, title: item["title"] as? String)
                row.value = item["value"] as? String
                row.action.formSelector = Selector("didTouchSubtype:");
                row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
                section.addFormRow(row);
            }
            
            self.subtypeSection = section
            form.addFormSection(section, atIndex: 1)
        }
    }
    
    // MARK: - Behaviour touch
    func didTouchButton(sender: XLFormRowDescriptor) {
        var coordinate  = LocationCore.sharedInstance.lastLocation!.coordinate
        var localized   = LocationCore.sharedInstance.lastLocationLocalized!;
        var data        = formData!
        var criteria    = criteriaData!

        criteria["extra"]   = extraData!
        data["criteria"]    = criteria
        data["loc"] = [
            "type"          : "Point",
            "coordinates"   : [coordinate.longitude, coordinate.latitude]
        ]
        data["localized_loc"] = localized
        
        var event = Event(raw: data)
        
        event.events.listenTo("sync", action: {
            self.didTapGoBack();
            //отправить статистику
        })
        
        event.save()
        
        //добавить спиннер
    }
    
    func didTouchType(sender: XLFormRowDescriptor) {
        var value = sender.value as? String
        
        if (criteriaData?.indexForKey(tag.type) != nil) {
            formData!.removeAll(keepCapacity: true)
            criteriaData!.removeAll(keepCapacity: true)
            extraData!.removeAll(keepCapacity: true)
            
            removeSubtypes()
            removeDescription()
            removeButtonSubmit()
            removeExtra()
            
            addSelectorTypeOptions()
            return
        }
        
        var context = EventHelper.contextByValue(value!)
        var isDescription = context!["description"] as? Bool
        
        removeRowByExclude(sender, section: sender.sectionDescriptor)

        addSelectorSubTypeOptions(value!)
        
        if (isDescription != nil) {
            addDescription()
        }
        
        if let tag = sender.tag {
            criteriaData![tag] = value!;
        }
    }
    
    func didTouchSubtype(sender: XLFormRowDescriptor) {
        var value = sender.value as? String
        
        if (criteriaData?.indexForKey(tag.subtype) != nil) {
            criteriaData!.removeValueForKey(tag.subtype)
            var typeValue: String = criteriaData![tag.type] as! String
            addSelectorSubTypeOptions(typeValue)
            return
        }
        
        addSelectorExtra(value!)
        addButtonSubmit()
        
        if let tag = sender.tag {
            criteriaData![tag] = value!;
        }
        
        removeRowByExclude(sender, section: sender.sectionDescriptor)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // MARK: - UI Setup
        
        self.title = "Запрос"
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.9, green:0.3, blue:0.26, alpha:1)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: UIBarButtonItemStyle.Done, target: self, action: "didTapGoBack")
    }
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        var formTag = formRow.tag!
        
        if  formTag == tag.extra {
            if newValue is XLFormOptionObject {
                var data = newValue.formValue() as! [String: String]
                extraData![data["key"]!] = data["value"]
            } else {
                return
            }
        } else if  formTag == tag.textView {
            formData![tag.textView] = newValue
        }
    }
    
    func didTapGoBack() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle  {
        return .LightContent
    }
    
}
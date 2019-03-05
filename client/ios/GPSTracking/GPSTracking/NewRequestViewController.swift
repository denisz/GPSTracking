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

class NewRequestViewController: XLFormViewController {
    var rowType     : XLFormRowDescriptor?
    var rowSubtype  : XLFormRowDescriptor?
    
    var typeSection         : XLFormSectionDescriptor?
    var subtypeSection      : XLFormSectionDescriptor?
    var descriptionSection  : XLFormSectionDescriptor?
    var submitSection       : XLFormSectionDescriptor?
    var extraSection        : XLFormSectionDescriptor?
    var attachSection       : XLFormSectionDescriptor?
    var accessSection       : XLFormSectionDescriptor?
    
    var criteriaData: [String: AnyObject]?
    var formData    : [String: AnyObject]?
    var extraData   : [String: AnyObject]?
    
    var changed: Bool = false
    
    var attachments: Collection<Attachment>?
    
    struct tag {
        static let type         = "context"
        static let subtype      = "subtype"
        static let button       = "submit"
        static let textView     = "description"
        static let extra        = "extra"
        static let attachment   = "attachment"
        static let accessPhone  = "allow_phone"
        static let accessEmail  = "allow_email"
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if LocationCore.sharedInstance.lastLocation == nil {
            let pscope = PermissionsHelper.setupPermissionScrope(self)
            pscope.requestLocationAlways()
        } else {
            LocationCore.sharedInstance.whatIsThisPlace()
            self.initializeForm()
        }
        
        self.setupViews()
    }
    
    override func viewDidDisappear(animated: Bool) {
        
    }
    
    func initializeForm() {
        self.formData       = [:]
        self.criteriaData   = [:]
        self.extraData      = [:]
        self.attachments    = Collection<Attachment>()
        
        self.formData![tag.accessEmail] = false
        self.formData![tag.accessPhone] = false
        
        self.form = XLFormDescriptor()
        
        self.addSelectorTypeOptions();
    }
    
    func selectorsByArray(key: String, options: [[String: String]]) -> [XLFormOptionsObject]{
        var result = [XLFormOptionsObject]()
        var _: [String: String]
        
        for option in options {
            let data = ["key" : key, "value" : option["value"]!]
            let obj = XLFormOptionsObject(value: data, displayText: option["title"])
            
            result.append(obj)
        }
        
        return result
    }
    
    func removeRowByExclude(exclude: XLFormRowDescriptor, section: XLFormSectionDescriptor) {
        let rows = section.formRows
        
        for row in rows {
            if row as! XLFormRowDescriptor != exclude {
                section.removeFormRow(row as! XLFormRowDescriptor)
            }
        }
    }

    // MARK: - Description section
    func addDescriptionForm() {
        let section = XLFormSectionDescriptor.formSection()
        self.form.addFormSection(section)
        
        let row = XLFormRowDescriptor(tag: tag.extra, rowType: XLFormRowDescriptorTypeTextView, title: "Описание".localized)
        section.addFormRow(row)
        
        self.descriptionSection = section
    }
    
    func removeDescriptionForm() {
        if let section = self.descriptionSection {
            self.form.removeFormSection(section)
        }
        
        self.descriptionSection = nil
    }
    
    // MARK: - Submit section
    func addButtonSubmit() {
        removeButtonSubmit()
        
        let section = XLFormSectionDescriptor.formSectionWithTitle("") as XLFormSectionDescriptor
        self.form.addFormSection(section)
        
        let row = XLFormRowDescriptor(tag: tag.button, rowType: XLFormRowDescriptorTypeButton, title: "SOS")
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
    
    //MARK: - Extra section
    func addExtraForm(data: [String: AnyObject]) {
        removeExtraForm()
        
        let fields  = EventHelper.extraByValue(data["extraFields"] as! String)
        
        if fields != nil {
            let section = XLFormSectionDescriptor.formSectionWithTitle("Анкета".localized) as XLFormSectionDescriptor
            self.form.addFormSection(section)
            
            let row = XLFormRowDescriptor(tag: tag.extra, rowType: XLFormRowDescriptorTypeButton)
            row.action.viewControllerStoryboardId = "CommonFormViewController"
            
            row.title = "Подробнее".localized
            self.stylesRow(row)
            row.cellOptions.setObject(fields!, forKey: "forms")
            row.cellConfig.setObject(UIColor(red:0.28, green:0.31, blue:0.32, alpha:1), forKey: "textLabel.color")
            section.addFormRow(row)
            
            self.extraSection = section
        }
    }
    
    func removeExtraForm() {
        if let section = self.extraSection {
            self.form.removeFormSection(section)
        }
        
        self.extraSection = nil
    }
    
    //MARK: - Attachment section
    func addAttachmentsForm() {
        let section = XLFormSectionDescriptor.formSectionWithTitle("Прикрепить фото".localized) as XLFormSectionDescriptor
        self.form.addFormSection(section)
        
        let row = XLFormRowDescriptor(tag: tag.attachment, rowType: XLFormRowDescriptorTypeSliderPhotos);
        row.cellOptions.setObject(self.attachments!, forKey: "attachments")
        row.cellOptions.setObject(true, forKey: "allowNewPhoto")
        row.cellOptions.setObject(true, forKey: "allowRemovePhoto")

        section.addFormRow(row)
        
        self.attachSection = section
    }
    
    func removeAttachmentsForm() {
        if let section = self.attachSection {
            self.form.removeFormSection(section)
        }
        
        self.attachSection = nil
    }
    
    // MARK: - Type
    func addSelectorTypeOptions() {
        removeTypes()
        
        let context   = EventHelper.context()
        let section = XLFormSectionDescriptor.formSectionWithTitle("Ситуация".localized) as XLFormSectionDescriptor
        self.form.addFormSection(section, atIndex: 0)
        
        for item in context {
            let row = XLFormRowDescriptor(tag: tag.type, rowType: XLFormRowDescriptorTypeButton, title: item["title"] as? String)
            row.value = item["value"] as? String
            row.action.formSelector = Selector("didTouchType:");
            self.stylesRow(row)
            row.cellConfig.setObject(1, forKey: "borderWidth")
            section.addFormRow(row);
        }
        
        self.typeSection = section        
    }
    
    func removeTypes() {
        if let section = self.typeSection {
            self.form.removeFormSection(section)
        }
        
        self.typeSection = nil
    }
    
    //MARK: - Access
    func addAccessForm() {
        let section = XLFormSectionDescriptor.formSectionWithTitle("Доступ".localized) as XLFormSectionDescriptor
        self.form.addFormSection(section)
        var row: XLFormRowDescriptor
        
        let currentUser = ServerRestApi.sharedInstance.getUser();
        if let _ = currentUser?.phone {
            row = XLFormRowDescriptor(tag: tag.accessPhone, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Телефону".localized)
            self.stylesRow(row)
            section.addFormRow(row)
        }
        
        row = XLFormRowDescriptor(tag: tag.accessEmail, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Эл.почте".localized)
        self.stylesRow(row)
        section.addFormRow(row)
        
        section.footerTitle = "Разрешить доступ к вашему телефонному номеру и другой контактной информации.".localized
        
        self.accessSection = section
    }
    
    func removeAccessForm() {
        if let section = self.accessSection {
            self.form.removeFormSection(section)
        }
        
        self.accessSection = nil
    }
    
    // MARK: - SubType
    func addSelectorSubTypeOptions(value: String ) {
        removeSubtypes();
        
        let subtypes = EventHelper.subtypesByType(value)
        
        if subtypes?.count > 0 {
            let section = XLFormSectionDescriptor.formSectionWithTitle("Что случилось?".localized) as XLFormSectionDescriptor
            form.addFormSection(section, atIndex: 1)
            
            for item in subtypes! {
                let row = XLFormRowDescriptor(tag: tag.subtype, rowType: XLFormRowDescriptorTypeButton, title: item["title"] as? String)
                row.value = item["value"] as? String
                row.action.formSelector = Selector("didTouchSubtype:");
                self.stylesRow(row)
                section.addFormRow(row);
            }
            
            self.subtypeSection = section
            
        }
    }
    
    func removeSubtypes() {
        if let section = self.subtypeSection {
            self.form.removeFormSection(section)
        }
        
        self.subtypeSection = nil
    }
    
    //MARK: - Help
    func showHelp(data: [String: AnyObject], section: XLFormSectionDescriptor) {
        if let help: AnyObject = data["help"] {
            section.footerTitle = help as? String
        } else {
            section.footerTitle = ""
        }
    }
    
    // MARK: - Behaviour touch
    func didTouchButton(sender: XLFormRowDescriptor) {
        let coordinate  = LocationCore.sharedInstance.lastLocation!.coordinate
        let localized   = LocationCore.sharedInstance.lastLocationLocalized!;
        var data        = formData!
        var criteria    = criteriaData!

        if let extra = extraData {
            criteria["extra"]  = extra
        }

        data["criteria"]    = criteria
        data["loc"] = [
            "type"          : "Point", //тут нужно быть осторожнее
            "coordinates"   : [coordinate.longitude, coordinate.latitude]
        ]
        data["localized_loc"] = localized
        let event = Event(raw: data)
        
        //блокировка view
        self.view.userInteractionEnabled = false;
        
        event.events.listenTo("sync", action: {
            let attachments = self.attachments!;
            if (attachments.count > 0) {
                let request = Attachment.scopeToTarget(attachments, target: event);
                request.responseSuccess({ (req, res, JSON, err) -> Void in
                    self.handlerBack();
                })
                .responseFailed({ (req, res, JSON, err) -> Void in
                    //выкинуть ошибку об не возможности создать запрос
                })
            } else {
                self.handlerBack();
            }
        })
        
        event.save()
            .responseFailed( { (req, res, json, err) -> Void in
                print("\(err)")
            })
    }
    
    func didTouchType(sender: XLFormRowDescriptor) {
        let value = sender.value as? String
        
        if (criteriaData?.indexForKey(tag.type) != nil) {
            formData!.removeAll(keepCapacity: true)
            criteriaData!.removeAll(keepCapacity: true)
            extraData!.removeAll(keepCapacity: true)
            
            removeSubtypes()
            clearView()
            addSelectorTypeOptions()
            
            return
        }
        
        self.changed = true;
        
        let context = EventHelper.contextByValue(value!)
        prepareView(context!)
        showHelp(context!, section: sender.sectionDescriptor)
        
        removeRowByExclude(sender, section: sender.sectionDescriptor)

        addSelectorSubTypeOptions(value!)
        
        if let tag = sender.tag {
            criteriaData![tag] = value!;
        }
        
        self.deselectFormRow(sender)
    }
    
    func didTouchSubtype(sender: XLFormRowDescriptor) {
        let value = sender.value as? String
        
        if (criteriaData?.indexForKey(tag.subtype) != nil) {
            criteriaData!.removeValueForKey(tag.subtype)
            let typeValue: String = criteriaData![tag.type] as! String
            
            clearView()
            addSelectorSubTypeOptions(typeValue)
            
            return
        }
        
        self.changed = true;
        
        let subtype = EventHelper.subtypeByValue(value!)
        prepareView(subtype!)
        showHelp(subtype!, section: sender.sectionDescriptor)
        
        if let tag = sender.tag {
            criteriaData![tag] = value!;
        }

        removeRowByExclude(sender, section: sender.sectionDescriptor)
        self.deselectFormRow(sender)
    }
    
    func clearView() {
        removeButtonSubmit()
        removeAttachmentsForm()
        removeDescriptionForm()
        removeExtraForm()
        removeAccessForm()
    }
    
    func prepareView(data: [String: AnyObject]) {
        let isExtra = data["extra"] as? Bool
        if (isExtra != nil) {
            addExtraForm(data)
        }

        let isAttach = data["attach"] as? Bool
        if (isAttach != nil) {
            addAttachmentsForm()
        }
        
        let isAccess = data["access"] as? Bool
        if (isAccess != nil) {
            addAccessForm()
        }
        
        let isDescription = data["description"] as? Bool
        if (isDescription != nil) {
            addDescriptionForm()
        }
        
        let isSubmit = data["submit"] as? Bool
        if (isSubmit != nil) {
            addButtonSubmit()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let section = self.attachSection {
            for row in section.formRows {
                self.updateFormRow(row as! XLFormRowDescriptor)
            }
        }
    }
    
    func setupViews() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor(red:0.28, green:0.31, blue:0.32, alpha:1),
            NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16.0)!
        ]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "didTapGoBack:")
    }
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        
        let formTag = formRow.tag!
        
        self.changed = true
        
        if  formTag == tag.extra {
            self.extraData = newValue as? [String: AnyObject]
        } else if  formTag == tag.textView {
            self.formData![tag.textView] = newValue
        } else if formTag == tag.accessPhone {
            self.formData![tag.accessPhone] = newValue as? Bool
        } else if formTag == tag.accessEmail {
            self.formData![tag.accessEmail] = newValue as? Bool
        }
    }
    
    func stylesRow(row: XLFormRowDescriptor) {
        row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
        row.cellConfig.setObject(UIColor(red:0.28, green:0.31, blue:0.32, alpha:1), forKey: "textLabel.color")
        row.cellConfig.setObject(UIFont(name: "Helvetica Neue", size: 16)!, forKey: "textLabel.font")
    }
    
    func handlerBack() {
        BLOCKING_EVENT_POPUP = false
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func didTapGoBack(sender: AnyObject) {
        let button = sender as! UIBarButtonItem
        let view = button.valueForKey("view") as! UIView
        
        if self.changed {
            self.createExitConfirm(view){
                self.handlerBack()
            }
        } else {
            self.handlerBack()
        }
    }
    
    func createExitConfirm(view: UIView, cb: ()-> Void ) {
        let actionSheet = UIAlertController(title: nil, message: "Вы уверены, что хотите удалить запрос?".localized, preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Удалить".localized, style: .Default, handler: { (action: UIAlertAction!) in
            cb()
        }))
        actionSheet.addAction(UIAlertAction(title: "Продолжить".localized, style: .Cancel, handler: nil))
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            actionSheet.popoverPresentationController!.sourceRect = view.bounds;
            actionSheet.popoverPresentationController!.sourceView = view;
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle  {
        return .LightContent
    }
    
    override func insertRowAnimationForRow(formRow: XLFormRowDescriptor!) -> UITableViewRowAnimation {
        return UITableViewRowAnimation.Fade
    }
    
    override func deleteRowAnimationForRow(formRow: XLFormRowDescriptor!) -> UITableViewRowAnimation {
        return UITableViewRowAnimation.Automatic
    }
    
    override func insertRowAnimationForSection(formSection: XLFormSectionDescriptor!) -> UITableViewRowAnimation {
        return UITableViewRowAnimation.Fade
    }
    
    override func deleteRowAnimationForSection(formSection: XLFormSectionDescriptor!) -> UITableViewRowAnimation {
        return UITableViewRowAnimation.Fade
    }
    
}
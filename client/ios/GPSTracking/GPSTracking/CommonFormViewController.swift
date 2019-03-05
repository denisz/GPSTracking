//
//  CommonFormView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/14/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.

import Foundation
import XLForm


/**
    struct = [
        "format"        : "single|multi",
        "rowType"       : type,
        "selectorType"  : [],
        "" :
        "fields" : [String]

    ]
**/

public enum CommonFormViewControllerFormat: Int {
    case Single     = 1
    case Multi      = 2
    case Seperator  = 3
}

public class CommonFormViewController: XLFormViewController, XLFormRowDescriptorViewController {
    public var rowDescriptor: XLFormRowDescriptor?
    var data: [String: AnyObject]?
    var fields : [String]?
    var currentSection: XLFormSectionDescriptor?
    var initializedForm: Bool = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        initializedForm = true
        
        if let value: AnyObject = rowDescriptor!.value {
            self.data = value as? [String : AnyObject]
        } else {
            self.data = [String : AnyObject]()
        }
        
        self.fields = rowDescriptor?.cellOptions.valueForKey("forms") as? [String]
        self.setupForm()
        self.performFields()
    }
    
    func setupForm() {
        self.form = XLFormDescriptor(title: titleForm())
        self.title = titleForm()
        self.configureNavigationController()
    }
    
    func configureNavigationController() {
        if let nc = self.navigationController {
            nc.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            nc.navigationBar.barStyle   = UIBarStyle.Default
            nc.navigationBar.tintColor  = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)
            nc.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor(red:0.28, green:0.31, blue:0.32, alpha:1),
                NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16.0)!
            ]
        }

    }
    
    func performFields() {
        createSimpleSection(titleFirstSection());
        
        for field in self.fields! {
            self.performField(field)
        }
    }
    
    func titleForm() -> String {
        return "Анкета".localized
    }
    
    func titleFirstSection() -> String {
        return ""
    }
    
    func changeCurrentSection(section: XLFormSectionDescriptor) {
        currentSection = section
    }
    
    func createSimpleSection(title: String, footerTitle: String = "") -> XLFormSectionDescriptor {
        let section = XLFormSectionDescriptor.formSectionWithTitle(title)
        section.footerTitle = footerTitle
        self.form.addFormSection(section)
        
        changeCurrentSection(section)
        return section
    }
    
    func performField(fieldNamed: String) {
        let properties: [String: AnyObject] = propertiesField(fieldNamed)!
        let format = CommonFormViewControllerFormat(rawValue: properties["format"] as! Int)
        
        switch(format!) {
        case .Single:
            self.performFormatSingle(fieldNamed,    options: properties)
            break;
        case .Multi:
            self.performFormatMulti(fieldNamed,     options: properties)
            break;
        case .Seperator:
            self.performFormatSeperator(fieldNamed, options: properties)
            break;
        }
    }
    
    func propertiesField(fieldNamed: String) -> [String: AnyObject]? {
        return EventHelper.setupViewByFields(fieldNamed);
    }
    
    func keepFormData() {
        self.rowDescriptor!.value = self.data!
        print(self.data!)
    }
    
    func findTagNamed(formRow: XLFormRowDescriptor) -> String? {
        if let fieldNamed = formRow.tag {
            return fieldNamed
        } else if let fieldNamedFromOptions = formRow.sectionDescriptor.multivaluedTag {
            return fieldNamedFromOptions
        }
        
        return nil
    }
    
    public override func formRowHasBeenAdded(formRow: XLFormRowDescriptor!, atIndexPath indexPath: NSIndexPath!) {
        if initializedForm == true {
            if let fieldNamed = findTagNamed(formRow) {
                var properties = self.propertiesField(fieldNamed)!
                
                let format = CommonFormViewControllerFormat(rawValue: properties["format"] as! Int)
                
                switch(format!) {
                case .Single:
                    self.singleFormRowHasBeenAdded(formRow, atIndexPath: indexPath)
                    break;
                case .Multi:
                    self.multiFormRowHasBeenAdded(formRow, atIndexPath: indexPath)
                    break;
                case .Seperator:
                    print("huh!?")
                    break;
                }
                
            }
            
            super.formRowHasBeenAdded(formRow, atIndexPath: indexPath)
        }

    }
    
    public override func formRowHasBeenRemoved(formRow: XLFormRowDescriptor!, atIndexPath indexPath: NSIndexPath!) {
        if initializedForm == true {
            if let fieldNamed = findTagNamed(formRow) {
                var properties = self.propertiesField(fieldNamed)!
                
                let format = CommonFormViewControllerFormat(rawValue: properties["format"] as! Int)
                
                switch(format!) {
                case .Single:
                    self.singleFormRowHasBeenRemoved(formRow, atIndexPath: indexPath)
                    break;
                case .Multi:
                    self.multiFormRowHasBeenRemoved(formRow, atIndexPath: indexPath)
                    break;
                case .Seperator:
                    print("huh!?")
                    break;
                }
                
            }
            
            super.formRowHasBeenRemoved(formRow, atIndexPath: indexPath)
        }
    }
    
    public override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        
        if initializedForm == true {
            if let fieldNamed = findTagNamed(formRow) {
                var properties = self.propertiesField(fieldNamed)!
                
                let format = CommonFormViewControllerFormat(rawValue: properties["format"] as! Int)
                
                switch(format!) {
                case .Single:
                    self.singleFormRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
                    break;
                case .Multi:
                    self.multiFormRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
                    break;
                case .Seperator:
                    print("huh!?")
                    break;
                }
                
                keepFormData()
            }
        }
    }
}


extension CommonFormViewController {
    func handlerDependencies(row: XLFormRowDescriptor) {
        let tag = row.tag;
        row.value = nil
        self.data![tag!] = nil
        
        if let options = EventHelper.setupViewByFields(tag!) {
            
            if options["dependenciesSelector"] != nil {
                row.hidden = true
                let field       = options["dependenciesField"] as! String
                let selectors   = options["dependenciesSelector"] as! [String: AnyObject]
                if  let value = self.data![field] as? String {
                    if let choiceSelectors = selectors[value] as? [String]{
                        if choiceSelectors.count > 0 {
                            row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
                            row.selectorOptions = self.selectorsByArray(choiceSelectors)
                            row.hidden = false
                        }
                    }
                }
            }
            
            if options["dependenciesVisible"] != nil {
                row.hidden = true;
                let field = options["dependenciesField"] as! String
                let depValue = options["dependenciesValue"] as! Bool
                
                if  let value = self.data![field] as? Bool {
                    row.hidden = !( depValue == value)
                } else {
                    row.hidden = !( depValue == false)
                }
            }
            
        }
        
    }
    
    func selectorsByArray(options: [String]) -> [XLFormOptionsObject]{
        var result = [XLFormOptionsObject]()
        
        for value in options {
            let optionsObj = XLFormOptionsObject(value: value, displayText: value)
            result.append(optionsObj)
        }
        
        return result
    }
    
    func performFormatSingle(tag: String, options: [String: AnyObject]) -> XLFormRowDescriptor? {
        let rowType = options["rowType"] as! String
        let row = XLFormRowDescriptor(tag: tag, rowType: rowType, title: options["title"] as? String)
        
        if options["selectorOptions"] != nil {
            row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
            row.selectorOptions = self.selectorsByArray(options["selectorOptions"] as! [String])
        }
        
        if options["maximumDate"] != nil {
            row.cellConfig.setObject(options["maximumDate"]!, forKey: "maximumDate")
        }
        
        if options["minimumDate"] != nil {
            row.cellConfig.setObject(options["minimumDate"]!, forKey: "minimumDate")
        }
        
        if options["dependenciesField"] != nil {
            handlerDependencies(row)
        }
        
        if options["action"] != nil {
            let action = options["action"] as! [String: String]
            
            if (action["viewControllerStoryboardId"] != nil) {
                row.action.viewControllerStoryboardId = action["viewControllerStoryboardId"]
            }
            
            if options["fields"] != nil {
                row.cellOptions.setObject(options["fields"]!, forKey: "forms")
            }
        }
        
        if options["sectionTitle"] != nil {
            self.currentSection?.title = options["sectionTitle"] as? String
        }
        
        stylesRow(row)
        
        if let value: AnyObject = self.data![tag] {
            if options["valueTransformer"] != nil {
                let transform = RequestHelp.getTransformFunction(options["valueTransformer"] as! String)!
                row.value = transform(value: value)
            } else {
                row.value = value
            }
        }
        
        currentSection?.addFormRow(row)
        
        return row
    }
    
    func stylesRow(row: XLFormRowDescriptor) {
        row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
        row.cellConfig.setObject(UIColor(red:0.28, green:0.31, blue:0.32, alpha:1), forKey: "textLabel.color")
        row.cellConfig.setObject(UIFont(name: "Helvetica Neue", size: 16)!, forKey: "textLabel.font")
    }
    
    func singleFormRowHasBeenAdded(formRow: XLFormRowDescriptor!, atIndexPath indexPath: NSIndexPath!) {
        
    }
    
    func singleFormRowHasBeenRemoved(formRow: XLFormRowDescriptor!, atIndexPath indexPath: NSIndexPath!){
        
    }
    
    func singleFormRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        
        if let fieldNamed = self.findTagNamed(formRow) {
            if newValue != nil {
                if newValue is XLFormOptionObject {
                    let _v = newValue as! XLFormOptionObject
                    let val = _v.formValue()
                    
                    if !val.isNull() {
                        self.data![fieldNamed] = _v.formValue()
                    } else {
                        self.data!.removeValueForKey(fieldNamed)
                    }
                    
                } else if formRow.rowType == XLFormRowDescriptorTypeTime {
                    self.data![fieldNamed] = "\(newValue)"
                } else if formRow.rowType == XLFormRowDescriptorTypeDate {
                    self.data![fieldNamed] = "\(newValue)"
                } else if formRow.rowType == XLFormRowDescriptorTypeButton {
                    self.data![fieldNamed] = newValue
                } else if formRow.rowType == XLFormRowDescriptorTypeMapView {
                    self.data![fieldNamed] = newValue
                } else if formRow.rowType == XLFormRowDescriptorTypeBooleanSwitch {
                    self.data![fieldNamed] = newValue
                } else {
                    if let parseNewValue = newValue as? String {
                        self.data![fieldNamed] = parseNewValue
                    }
                }
            } else {
                self.data!.removeValueForKey(fieldNamed)
            }
            
            let dependies = EventHelper.findDependencies(fieldNamed);
            for tag in dependies {
                let formRow = self.form.formRowWithTag(tag)
                handlerDependencies(formRow!)
                updateFormRow(formRow)
            }
        }
    }
}


extension CommonFormViewController {
    func multivaluedRowTemplate(fieldNamed: String, options: [String: AnyObject], value: AnyObject? = nil) -> XLFormRowDescriptor {
        let fields = options["fields"] as! [String] //иначе будет ошибка
        let row = XLFormRowDescriptor(tag: fieldNamed, rowType: XLFormRowDescriptorTypeButton, title: self.multivaluedRowTitle(options))
        
        row.value = value;
        row.action.viewControllerStoryboardId = "CommonFormViewController"
        row.cellOptions.setObject(fields, forKey: "forms")
        row.cellConfig.setObject(UIColor(red:0.28, green:0.31, blue:0.32, alpha:1), forKey: "textLabel.color")
        return row
    }
    
    func multivaluedRowTitle(options: [String: AnyObject]) -> String {
        return (options["titleRow"] ?? "Правонарушитель") as! String
    }
    
    func multivaluedAddButton(options: [String: AnyObject]) -> String {
        return (options["titleButton"] ?? "Добавить правонарушителя") as! String
    }
    
    func performFormatMulti(tag: String, options: [String: AnyObject]) -> XLFormRowDescriptor? {
        let title = (options["title"] ?? "") as! String
        let section = XLFormSectionDescriptor.formSectionWithTitle(title, sectionOptions: [.CanInsert, .CanDelete], sectionInsertMode: .Button)

        section.multivaluedAddButton!.title  = self.multivaluedAddButton(options)
        section.multivaluedRowTemplate      = self.multivaluedRowTemplate(tag, options: options)
        section.multivaluedTag              = tag
        self.form.addFormSection(section)
        self.insertMultiValues(tag, options: options, section: section)

        
        if let footer = options["footer"] as? String {
            section.footerTitle = footer
        }
        
        createSimpleSection("")
        
        return nil
    }
    
    func insertMultiValues(tag: String, options: [String: AnyObject], section: XLFormSectionDescriptor) {
        if let items = self.data![tag] as? [String: AnyObject] {
            for (key, value) in items {
                let row = self.multivaluedRowTemplate(tag, options: options, value: value)
                section.addFormRow(row)
                row.cellOptions.setObject(key, forKey: "index")
            }
        }
    }
    
    func allowAddNewItem(fieldNamed: String, formRow: XLFormRowDescriptor) {
        if let fieldValue = self.data![fieldNamed] as? [String: AnyObject] {
            let properties = self.propertiesField(fieldNamed)!
            let maxCount = (properties["maxCount"] ?? 100) as! Int
            let currentCount = fieldValue.count
            let section = formRow.sectionDescriptor
            section.multivaluedAddButton!.disabled = currentCount >= maxCount
        }
    }
    
    func multiFormRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        if let fieldName = self.findTagNamed(formRow) {
            let key = formRow.cellOptions.valueForKey("index") as! String
            self.updateMultiDataForm(fieldName, key: key, value: newValue)
        }
    }
    
    func addMultiFormData(fieldNamed: String, key: String) {
        if self.data![fieldNamed] == nil {
            self.data![fieldNamed] = [String: AnyObject]()
        }
        self.updateMultiDataForm(fieldNamed, key: key, value: [:])
    }
    
    func removeMultiFormData(fieldNamed: String, key: String) {
        if var fieldValue = self.data![fieldNamed] as? [String: AnyObject] {
            fieldValue.removeValueForKey(key)
            self.data![fieldNamed] = fieldValue
        }
    }
    
    func updateMultiDataForm(fieldNamed: String, key: String, value: AnyObject) {
        if var fieldValue = self.data![fieldNamed] as? [String: AnyObject] {
            fieldValue[key] = value as! [String: AnyObject]
            self.data![fieldNamed] = fieldValue
        }
    }
    
    func countItemsInSection(fieldNamed: String) -> Int {
        if let fieldValue = self.data![fieldNamed] as? [String: AnyObject]{
            return fieldValue.count
        }
        
        return 0
    }
    
    func multiFormRowHasBeenRemoved(formRow: XLFormRowDescriptor!, atIndexPath indexPath: NSIndexPath!) {
        if let fieldNamed = self.findTagNamed(formRow) {
            let key = formRow.cellOptions.valueForKey("index") as! String
            removeMultiFormData(fieldNamed, key: key)
            allowAddNewItem(fieldNamed, formRow: formRow)
            self.keepFormData()
        }
    }
    
    func generateKeyForRow(index: Int) -> String {
        return "item_\(index)"
    }
    
    override public func multivaluedInsertButtonTapped(formRow: XLFormRowDescriptor!) {
        super.multivaluedInsertButtonTapped(formRow)
        
        if let fieldNamed = self.findTagNamed(formRow) {
            let key = generateKeyForRow(countItemsInSection(fieldNamed))
            formRow.cellOptions.setObject(key, forKey: "index")
            addMultiFormData(fieldNamed, key: key)
            allowAddNewItem(fieldNamed, formRow: formRow)
            self.keepFormData()
        }
    }
    
    func multiFormRowHasBeenAdded(formRow: XLFormRowDescriptor!, atIndexPath indexPath: NSIndexPath!) {
        if let fieldNamed = self.findTagNamed(formRow) {
            var options = self.propertiesField(fieldNamed)!
            formRow.title = "\(self.multivaluedRowTitle(options)) \(indexPath.row + 1)"
            
            let key = generateKeyForRow(countItemsInSection(fieldNamed))
            formRow.cellOptions.setObject(key, forKey: "index")

            let fields = options["fields"] as! [String]
            formRow.cellOptions.setObject(fields, forKey: "forms")
        }
    }
}


extension CommonFormViewController {
    func performFormatSeperator(tag: String, options: [String: AnyObject]) -> XLFormRowDescriptor? {
        print("seperator")
        let title = (options["title"] ?? "") as! String
        createSimpleSection(title)
        return nil
    }
}

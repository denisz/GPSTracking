//
//  SettingsViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/23/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import XLForm

class SettingsViewController: XLFormViewController {
    var rowType       : XLFormRowDescriptor?
    var rowSubtype    : XLFormRowDescriptor?
    var model         : User?
    
    struct tag {
        static let fullName     = "fullname"
        static let password     = "password"
        static let email        = "email"
        static let notify       = "notify"
        static let checkin       = "checkin"
        static let phone        = "phone"
        static let logout       = "logout"
        static let appstore     = "appstore"
        static let terms        = "terms"
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!;
        self.initializeForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "didTapSave")

    }
    
    func initializeForm() {
        
        form = XLFormDescriptor()
        self.form = form
        self.model = ServerRestApi.sharedInstance.getUser()
        
        addMainSection()
        addButtonLogout()
    }
    
    func addMainSection() {
        let section = XLFormSectionDescriptor.formSectionWithTitle("Основные".localized)
        self.form.addFormSection(section)
        
        let fullName = XLFormRowDescriptor(tag: tag.fullName, rowType: XLFormRowDescriptorTypeText)
        fullName.cellConfigAtConfigure.setObject("Полное имя".localized, forKey:"textField.placeholder")
        fullName.value = self.model!.fullname()
        section.addFormRow(fullName)
        
        let email = XLFormRowDescriptor(tag: tag.email, rowType: XLFormRowDescriptorTypeText)
        email.cellConfigAtConfigure.setObject("E-mail".localized, forKey:"textField.placeholder")
        email.value = self.model!.email
        section.addFormRow(email)
        
        let phone = XLFormRowDescriptor(tag: tag.phone, rowType: XLFormRowDescriptorTypeText)
        phone.cellConfigAtConfigure.setObject("Номер телефона".localized, forKey:"textField.placeholder")
        phone.value = self.model!.phone
        section.addFormRow(phone)
        
        let password = XLFormRowDescriptor(tag: tag.password, rowType: XLFormRowDescriptorTypeText)
        password.cellConfigAtConfigure.setObject("Пароль".localized, forKey:"textField.placeholder")
        section.addFormRow(password)
    }
    
    func addButtonLogout() {
        let section = XLFormSectionDescriptor.formSectionWithTitle("") as XLFormSectionDescriptor
        self.form.addFormSection(section)
        var row: XLFormRowDescriptor;
        
//        row = XLFormRowDescriptor(tag: tag.logout, rowType: XLFormRowDescriptorTypeButton, title: "Помощь".localized)
//        row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
//        row.action.formSelector = Selector("didTapHelp:")
//        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: tag.terms, rowType: XLFormRowDescriptorTypeButton, title: "Правила")
        row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
        row.action.formSelector = Selector("didTapTerms:")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: tag.appstore, rowType: XLFormRowDescriptorTypeButton, title: "Оценить приложение")
        row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
        row.action.formSelector = Selector("didTapLinkAppStore:")
        section.addFormRow(row)
        
        if !PermissionsHelper.isAuthNoitification() {
            row = XLFormRowDescriptor(tag: tag.notify, rowType: XLFormRowDescriptorTypeButton, title: "Оповещения")
            row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
            row.action.formSelector = Selector("didTapNotification:")
            section.addFormRow(row)
        }
        
        if !PermissionsHelper.isAuthLocation() {
            row = XLFormRowDescriptor(tag: tag.notify, rowType: XLFormRowDescriptorTypeButton, title: "Местоположение")
            row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
            row.action.formSelector = Selector("didTapCheckin:")
            section.addFormRow(row)
        }
        
        row = XLFormRowDescriptor(tag: tag.logout, rowType: XLFormRowDescriptorTypeButton, title: "Выход".localized)
        row.cellConfig.setObject(UIColor(red:0.9, green:0.3, blue:0.26, alpha:1), forKey: "textLabel.textColor")
        row.cellConfig.setObject(NSTextAlignment.Left.rawValue, forKey: "textLabel.textAlignment")
        row.action.formSelector = Selector("didTapLogout:")
        section.addFormRow(row)

    }
    
    func stylesRow(row: XLFormRowDescriptor) {
        
    }
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        let formTag = formRow.tag!
        if formTag == tag.notify {
        } else {
            self.model!.updateValue(forKey: formTag, value: newValue)
        }
        
    }
    
    func didTapLogout(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            ServerRestApi.sharedInstance.logout()
        });
    }
    
    func didTapTerms(sender: AnyObject) {
        let termOfservice = TermOfServiceViewController()
        self.navigationController?.pushViewController(termOfservice, animated: true)
    }
    
    func didTapLinkAppStore (sender: AnyObject) {
        let id  = "1031077352"
        let url  = NSURL(string: "itms-apps://itunes.apple.com/app/id\(id)")
        
        if UIApplication.sharedApplication().canOpenURL(url!) == true  {
            UIApplication.sharedApplication().openURL(url!)
        }
        
        
        if let row = self.form.formRowWithTag(tag.appstore) {
            self.deselectFormRow(row)
        }

    }
    
    func didTapHelp(sender: AnyObject) {
//        let termOfservice = TermOfServiceViewController()
//        self.navigationController?.pushViewController(termOfservice, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func didTapNotification(sender: AnyObject) {
        let pscope = PermissionsHelper.setupPermissionScrope(self)
        PermissionsHelper.registerAuthCallback(pscope) {
        }
        pscope.requestNotifications()
        
        if let row = self.form.formRowWithTag(tag.notify) {
            self.deselectFormRow(row)
        }
    }
    
    func didTapCheckin(sender: AnyObject) {
        let pscope = PermissionsHelper.setupPermissionScrope(self)
        PermissionsHelper.registerAuthCallback(pscope) {
        }
        pscope.requestLocationAlways()
        
        if let row = self.form.formRowWithTag(tag.checkin) {
            self.deselectFormRow(row)
        }
    }
    
    func didTapBack() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    func didTapSave() {
        self.model!.sync()
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func showBtnBack() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "didTapBack")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle  {
        return .Default
    }
    
}
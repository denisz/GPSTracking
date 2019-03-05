//
//  NewAnswerView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 8/1/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import XLForm

protocol NewAnswerViewDelegate {
    func newAnswerView(answerView: UIViewController, withAnswer answer: Answer)
}

class NewAnswerView: XLFormViewController  {
    var model: Event?
    var formData: [String: AnyObject]?
    var attachments: Collection<Attachment>?
    var tableViewStyle: UITableViewStyle = UITableViewStyle.Plain
    var parentNavigationController: UINavigationController?
    
    var buttonSend: Bool    = false
    var authorField: Bool   = true
    var contextField: Bool  = true
    var subtypeField: Bool  = true
    
    var delegate: NewAnswerViewDelegate?
    
    struct tag {
        static let author       = "author"
        static let context      = "context"
        static let subtype      = "subtype"
        static let attachment   = "attachment"
        static let button       = "submit"
        static let textView     = "description"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupForm()
        setupSection()
        
        if buttonSend == true {
            setupButtonSend()
        }
    }
    
    func setupForm() {
        self.form           = XLFormDescriptor()
        self.formData       = [:]
        self.attachments    = Collection<Attachment>()
        
        self.view.backgroundColor = UIColor.redColor()
        self.tableView.backgroundColor = UIColor.whiteColor()

        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func setupSection() {
        let section = XLFormSectionDescriptor.formSection()
        self.form.addFormSection(section)
        var row: XLFormRowDescriptor
        
        if authorField {
            row = XLFormRowDescriptor(tag: tag.author, rowType: XLFormRowDescriptorTypeText, title: "Кому:".localized)
            row.value = getNameAuthorEvent()
            stylesRow(row)
            section.addFormRow(row)
        }
        
        if contextField {
            row = XLFormRowDescriptor(tag: tag.context, rowType: XLFormRowDescriptorTypeText, title: "Запрос:".localized)
            row.value = self.model!.localizedContext
            stylesRow(row)
            section.addFormRow(row)
        }
        
        if subtypeField {
            if let _ = self.model!.subtype {
                row = XLFormRowDescriptor(tag: tag.subtype, rowType: XLFormRowDescriptorTypeText, title: "Ситуация:".localized)
                row.value = self.model!.localizedSubtype
                stylesRow(row)
                section.addFormRow(row)
            }
        }

        row = XLFormRowDescriptor(tag: tag.attachment, rowType: XLFormRowDescriptorTypeSliderPhotos);
        row.cellOptions.setObject(self.attachments!, forKey: "attachments")
        row.cellOptions.setObject(true, forKey: "allowNewPhoto")
        row.cellOptions.setObject(true, forKey: "allowRemovePhoto")
        
        if let nc = self.parentNavigationController {
            row.cellOptions.setObject(nc, forKey: "parentController")
        }

        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: tag.textView, rowType: XLFormRowDescriptorTypeArea, title: "")
        row.cellConfigAtConfigure.setObject("Текст сообщения", forKey:"textView.placeholder")
        section.addFormRow(row)
    }
    
    func setupButtonSend() {
        let section = XLFormSectionDescriptor.formSection()
        self.form.addFormSection(section)
        
        let row = XLFormRowDescriptor(tag: tag.button, rowType: XLFormRowDescriptorTypeButton, title: "Отправить".localized)
        row.cellConfig.setObject(UIColor(red:0.28, green:0.31, blue:0.32, alpha:1), forKey: "textLabel.textColor")
        row.action.formSelector = Selector("didTapSend")
        section.addFormRow(row)
    }
    
    func getNameAuthorEvent() -> String{
        if let user = self.model!.getLink("user") as? User {
            return user.fullname()
        }
        
        return "--"
    }
    
    func stylesRow(row: XLFormRowDescriptor) {
        row.disabled = true
        row.cellConfig.setObject(UIColor(red:0.62, green:0.65, blue:0.66, alpha:1), forKey: "textLabel.color")
        row.cellConfig.setObject(UIFont(name: "Helvetica Neue", size: 13)!, forKey: "textLabel.font")
        row.cellConfig.setObject(UIFont(name: "Helvetica Neue", size: 15)!, forKey: "textField.font")
        row.cellConfig.setObject(UIColor(red:0.2, green:0.28, blue:0.37, alpha:1), forKey: "textField.textColor")
    }
    
    func setupViews() {
        self.title = "Ответ".localized
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена".localized, style:
            UIBarButtonItemStyle.Done, target: self, action: "didTapGoBack")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отправить".localized, style:
            UIBarButtonItemStyle.Done, target: self, action: "didTapSend")
    }
    
    func getBodyText() -> String {
        let index = self.formData?.indexForKey(tag.textView)
        if  index != nil {
            return (self.formData![tag.textView] ?? "") as! String
        }
        return ""
    }
    
    func didTapGoBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapSend() {
        let body = self.getBodyText()
        
        if !body.isEmpty {
            var data: [String: AnyObject] = ["status":ANSWER_ACCEPTED, "description": body]
            let coordinate  = LocationCore.sharedInstance.lastLocation!.coordinate
            let localized   = LocationCore.sharedInstance.lastLocationLocalized!;
            data["loc"] = [
                "type"          : "Point",
                "coordinates"   : [coordinate.longitude, coordinate.latitude]
            ]
            data["localized_loc"] = localized
            
            let answer = Answer.createFromEvent(model!, data: data)
            answer.events.listenTo("sync", action:{
                let attachments = self.attachments!;
                if (attachments.count > 0) {
                    let request = Attachment.scopeToTarget(attachments, target: answer);
                    request.responseSuccess({ (req, res, JSON, err) -> Void in
                        self.didTapGoBack();
                        self.delegate?.newAnswerView(self, withAnswer: answer)
                    })
                    .responseFailed({ (req, res, JSON, err) -> Void in
                        //выкинуть ошибку об не возможности создать ответ
                    })
                } else {
                    self.didTapGoBack();
                    self.delegate?.newAnswerView(self, withAnswer: answer)
                }
            })
            answer.save()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle  {
        return .LightContent
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowDescriptor = self.form.formRowAtIndex(indexPath);
        
        if rowDescriptor!.tag == tag.textView {
            return self.tableView.rowHeight
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        let rowDescriptor = self.form.formRowAtIndex(indexPath)
        if rowDescriptor!.tag == tag.textView {
            cell.separatorInset = UIEdgeInsetsZero
        }
        
        return cell
    }
    
    class func create(model: Event) -> EMPartialModalViewController{
        let content = NewAnswerView()
        content.model = model
        
        let bounds = UIScreen.mainScreen().bounds
        let height = bounds.size.height
        let navigationController = UINavigationController(rootViewController: content)
        return EMPartialModalViewController(rootViewController: navigationController, contentHeight: height - 50)
    }
}

extension NewAnswerView {
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        let formTag = formRow.tag!
        self.formData![formTag] = newValue
    }
}
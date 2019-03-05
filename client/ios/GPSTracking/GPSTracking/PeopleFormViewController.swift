//
//  PeopleFormViewController.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/8/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import XLForm
import AddressBookUI

class PeopleFormViewController:  XLFormViewController, XLFormRowDescriptorViewController {
    var rowDescriptor: XLFormRowDescriptor?
    var peoplePicker: ABPeoplePickerNavigationController?
    var phone: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
        self.peoplePicker = ABPeoplePickerNavigationController()
        self.peoplePicker!.peoplePickerDelegate = self
        self.presentViewController(self.peoplePicker!, animated: false, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func didTapBack() {
        self.peoplePicker!.dismissViewControllerAnimated(false, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func didTapKeep() {
        if let phone = self.phone {
            self.rowDescriptor!.value = phone
        } else {
            self.rowDescriptor!.value = nil
        }
        
        didTapBack()
    }
}

extension PeopleFormViewController: ABPeoplePickerNavigationControllerDelegate {
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        
        /* Get all the phone numbers this user has */
        let unmanagedPhones = ABRecordCopyValue(person, kABPersonPhoneProperty)
        let phones: ABMultiValueRef =
        Unmanaged.fromOpaque(unmanagedPhones.toOpaque()).takeUnretainedValue()
            as NSObject as ABMultiValueRef
        
        let countOfPhones = ABMultiValueGetCount(phones)
        
        for index in 0..<countOfPhones{
            let unmanagedPhone = ABMultiValueCopyValueAtIndex(phones, index)
            let phone: String = Unmanaged.fromOpaque(
                unmanagedPhone.toOpaque()).takeUnretainedValue() as NSObject as! String
            
            self.phone = phone
        }
        
        didTapKeep()
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, shouldContinueAfterSelectingPerson person: ABRecordRef) -> Bool {
        
        peoplePickerNavigationController(peoplePicker, didSelectPerson: person)
        return false;
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController){
        self.phone = nil
        self.didTapBack()
    }
}
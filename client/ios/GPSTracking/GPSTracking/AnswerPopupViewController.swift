//
//  AnswerPopupViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/23/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import LGActionSheet
import LGAlertView


let ANSWER_ACCEPTED: String = "accepted"
let ANSWER_REJECTED: String = "rejected"
let ANSWER_DISMISS : String = "dismiss"


class AnswerPopupViewController: NSObject {
    static var model: Event?
    
    class func presentAlertView(model: Event) {
        self.model = model
        let view = AnswerPopupView()
        view.frame = CGRectMake(0, 0, 260, 250)
        
        view.setModel(model)
        
        let alertView = LGAlertView(viewStyleWithTitle: "Запрос".localized, message: nil, view: view, buttonTitles: ["Ответить".localized], cancelButtonTitle: "Отменить".localized, destructiveButtonTitle: nil, delegate: nil)
        
        alertView.showAnimated(true, completionHandler: nil)
    }
    
    class func presentActionSheetView(model: Event) {
        self.model = model

        let view = AnswerPopupView()
        view.frame = CGRectMake(0, 0, 300, 250)
        
        view.setModel(model)
        
        let actionSheet = LGActionSheet(
            title: "Запрос".localized,
            view: view,
            buttonTitles: ["В ленту".localized],
            cancelButtonTitle: nil,//"Закрыть".localized,
            destructiveButtonTitle: "Подробнее".localized,
            actionHandler:handlerDismiss,
            cancelHandler:handlerCancel,
            destructiveHandler:handlerMore
        )
        
        actionSheet.destructiveButtonTitleColor = UIColor(red:0.18, green:0.24, blue:0.31, alpha:1)
        actionSheet.buttonsTitleColor = UIColor(red:0.28, green:0.81, blue:0.54, alpha:1)
        actionSheet.cancelButtonTitleColor = UIColor.redColor()
        actionSheet.cancelOnTouch = false
        actionSheet.colorful = false
        actionSheet.showAnimated(true, completionHandler: nil)
        actionSheet.view.userInteractionEnabled = false
        
        model.events.listenTo("sync", action: { () -> () in
            actionSheet.view.userInteractionEnabled = true
        })
    }
    
    class func handlerMore(_: LGActionSheet!) {
        if let model = self.model {
            _handlerDismiss()
            MapSupport.sharedInstance.removeByModel(model)
            Dispatcher.sharedInstance.events.trigger(KEY_EVENT_EVENT, information: model.copyWithUserAndAnswer())
        }
    }
    
    class func handlerCancel(_: LGActionSheet!, _: Bool) {
    
    }
    
    class func _handlerDismiss() {
        if let model = self.model {
            var data: [String: AnyObject] = ["status": ANSWER_DISMISS]
            let coordinate  = LocationCore.sharedInstance.lastLocation!.coordinate
            let localized   = LocationCore.sharedInstance.lastLocationLocalized!;
            data["loc"] = [
                "type"          : "Point",
                "coordinates"   : [coordinate.longitude, coordinate.latitude]
            ]
            data["localized_loc"] = localized
            
            let answer = Answer.createFromEvent(model, data: data)
            answer.save()
            
            MapSupport.sharedInstance.removeByModel(model)
        }
    }
    
    class func handlerDismiss(_: LGActionSheet!, _: String!, _: UInt) {
       _handlerDismiss()
    }

    class func handlerAnswer(_: LGActionSheet!, _: String!, _: UInt) {
        if let model = self.model {
            if Event.hasAnswer(model) {
                Dispatcher.sharedInstance.events.trigger(KEY_EVENT_EVENT, information: model)
            } else {
                Dispatcher.sharedInstance.events.trigger(KEY_EVENT_ANSWER, information: model)
            }
        }
    }

}

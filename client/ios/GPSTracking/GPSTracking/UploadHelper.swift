//
//  UploadImageHelper.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/24/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import IDMPhotoBrowser
import FXBlurView
import Kingfisher
import Photos
import TOCropViewController
import JGProgressHUD
import Alamofire

class UploadHelper {
    class func uploadImage(image: UIImage, scenario: String) -> Request {
        return uploadImage(Attachment.withImage(image, scenario: scenario))
    }
    
    class func uploadImage(attachment: Attachment) -> Request {
        let HUD = createHudProgress();

        return attachment.uploadImage()
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                
                let percent = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                self.progressHudProgress(HUD, progress: percent)
            }
            .responseSuccess({ (request, response, JSON, error) in
                self.successHudProgress(HUD)
            })
            .responseSuccess({ (req, res, JSON, error) -> Void in
                if error != nil {
                    self.failedHudProgress(HUD)
                }
            })
    }
    
    class func createHudProgress() -> JGProgressHUD {
        let HUD = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        let window = UIApplication.sharedApplication().keyWindow!
       
        HUD.showInView(window)//может сделать показ на window
        self.progressHudProgress(HUD, progress: 0)
        HUD.indicatorView = JGProgressHUDPieIndicatorView(HUDStyle: JGProgressHUDStyle.Dark)
        HUD.textLabel.text = "Загрузка...".localized
        HUD.detailTextLabel.text = nil
        HUD.layoutChangeAnimationDuration = 0.0
        
        return HUD
    }
    
    class func progressHudProgress(HUD: JGProgressHUD, progress: Float) {
        HUD.setProgress(progress, animated: false)
    }
    
    class func successHudProgress(HUD: JGProgressHUD) {
        HUD.textLabel.text = "Загружено".localized
        HUD.detailTextLabel.text = nil
        HUD.layoutChangeAnimationDuration = 0.3
        HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
        
        let delta: Int64 = 1 * Int64(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, delta)
        
        dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
            HUD.dismiss();
        })
    }
    
    class func failedHudProgress(HUD: JGProgressHUD) {
        HUD.textLabel.text = "Ошибка".localized
        HUD.detailTextLabel.text = nil
        HUD.layoutChangeAnimationDuration = 0.3
        HUD.indicatorView = JGProgressHUDErrorIndicatorView()
        
        let delta: Int64 = 1 * Int64(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, delta)
        
        dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
            HUD.dismiss();
        })
    }

}
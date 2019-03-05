//
//  UIImageView+ProgressView.swift
//
//
//  Created by ericfish on 4/30/15.
//  Copyright (c) 2015 Yu Jia Nan. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

public let TAG_PROGRESS_VIEW = 149462

public extension UIImageView {
    
    public func addProgressView(var progressView: UIProgressView?) {
        let existingProgressView: UIProgressView? = self.viewWithTag(TAG_PROGRESS_VIEW) as? UIProgressView
        if existingProgressView == nil {
            if progressView == nil {
                progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
            }
            
            progressView!.tag = TAG_PROGRESS_VIEW
            progressView!.autoresizingMask = [
                UIViewAutoresizing.FlexibleTopMargin,
                UIViewAutoresizing.FlexibleBottomMargin,
                UIViewAutoresizing.FlexibleLeftMargin,
                UIViewAutoresizing.FlexibleRightMargin
            ]
            
            let width:CGFloat = progressView!.frame.size.width
            let height:CGFloat = progressView!.frame.size.height
            let x:CGFloat = (self.frame.size.width / 2.0) - width/2
            let y:CGFloat = (self.frame.size.height / 2.0) - height/2
            progressView!.frame = CGRectMake(x, y, width, height)
            
            self.addSubview(progressView!)
        }
    }
    
    public func updateProgress(progress: Float) {
        if let progressView = self.viewWithTag(TAG_PROGRESS_VIEW) as? UIProgressView {
            progressView.progress = progress
        }
    }
    
    public func removeProgressView() {
        if let progressView = self.viewWithTag(TAG_PROGRESS_VIEW) as? UIProgressView {
            progressView.removeFromSuperview()
        }
    }
    
    public func kf_setImageWithURL(URL: NSURL,
        usingProgressView progressView:UIProgressView?) -> RetrieveImageTask
    {
        return kf_setImageWithURL(URL, placeholderImage: nil, options: KingfisherOptions.None, progressBlock: nil, completionHandler: nil,usingProgressView:progressView)
    }
    
    public func kf_setImageWithURL(URL: NSURL,
        placeholderImage: UIImage?,
        usingProgressView progressView:UIProgressView?) -> RetrieveImageTask
    {
        return kf_setImageWithURL(URL, placeholderImage: placeholderImage, options: KingfisherOptions.None, progressBlock: nil, completionHandler: nil,usingProgressView:progressView)
    }
    
    public func kf_setImageWithURL(URL: NSURL,
        placeholderImage: UIImage?,
        options: KingfisherOptions,
        usingProgressView progressView:UIProgressView?) -> RetrieveImageTask
    {
        return kf_setImageWithURL(URL, placeholderImage: placeholderImage, options: options, progressBlock: nil, completionHandler: nil,usingProgressView:progressView)
    }
    
    public func kf_setImageWithURL(URL: NSURL,
        placeholderImage: UIImage?,
        options: KingfisherOptions,
        completionHandler: CompletionHandler?,
        usingProgressView progressView:UIProgressView?) -> RetrieveImageTask
    {
        return kf_setImageWithURL(URL, placeholderImage: placeholderImage, options: options, progressBlock: nil, completionHandler: completionHandler,usingProgressView:progressView)
    }
    
    public func kf_setImageWithURL(URL: NSURL,
        placeholderImage: UIImage?,
        options: KingfisherOptions,
        progressBlock: DownloadProgressBlock?,
        completionHandler: CompletionHandler?,
        usingProgressView progressView:UIProgressView?) -> RetrieveImageTask
    {
        self.addProgressView(progressView)
        
        weak var weakSelf = self
        
        let task = self.kf_setImageWithURL(URL,
            placeholderImage: placeholderImage,
            optionsInfo: [.Options: options],
            progressBlock: { (receivedSize, totalSize) -> () in
                let progress = Float(receivedSize) / Float(totalSize)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    weakSelf?.updateProgress(progress)
                    return
                })
                
                if progressBlock != nil {
                    progressBlock!(receivedSize: receivedSize, totalSize: totalSize)
                }
            },
            completionHandler: { (image, error, cacheType, imageURL) -> () in
                weakSelf?.removeProgressView()
                if completionHandler != nil {
                    completionHandler!(image: image, error: error, cacheType: cacheType, imageURL: imageURL)
                }
        })
        
        return task
    }
    
}
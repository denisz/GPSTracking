//
//  TermOfService.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/26/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

@objc(TermOfServiceViewController) class TermOfServiceViewController : UIViewController {
    @IBOutlet weak var textView : UITextView?
    @IBOutlet weak var navigationBar: UINavigationBar?
    
    var hiddenBar: Bool = false;
    let filename : String = "termofservice";
    var backControllerView : UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Правила сервиса".localized
        
        if let fileURL = NSBundle.mainBundle().URLForResource(filename, withExtension: "rtf") {
            do {
                let attributedText = try NSAttributedString(fileURL: fileURL, options:
                [
                    NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType
                    ], documentAttributes: nil)
                    
                textView!.attributedText = attributedText
                textView!.scrollsToTop = true
                textView!.setContentOffset(CGPointZero, animated:true)
            } catch {}
        }
        
        if hiddenBar {
            self.hideNavigationBar()
        }
    }
    
    func hideNavigationBar() {
        if self.navigationBar != nil {
            self.navigationBar!.hidden = true
        }
        
        hiddenBar = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default;
    }
    
    @IBAction func didTapExit() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}

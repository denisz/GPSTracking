//
//  SldierPhotosCollectionView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/1/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import Photos
import TOCropViewController
import StatefulViewController

let reusableIdentifierPhoto: String     = "SliderPhotoReusableCell"
let reusableIdentifierNewPhoto: String  = "SlidernewPhotoReusableCell"

//испраивть на наши коллекции
//UICollectionViewController
class SliderPhotosCollectionView: StatefulViewController, StatefulViewControllerDelegate, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDataSource {
    
    var collectionView      : UICollectionView?
    var parentController    : UIViewController?
    var collection          : Collection<Attachment>?
    var allowNewPhoto       : Bool = false
    var allowRemovePhoto    : Bool = false
    
    func viewForStateMachine() -> UIView {
        return self.view.superview!
    }
    
    var offset: Int {
        get {
            return self.allowNewPhoto ? 1 : 0
        }
    };
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hasContent() -> Bool {
        if collection != nil {
            if allowNewPhoto == true {
                return true
            }
            
            return collection!.count > 0
        }
        
        return true
    }
    
    //это при создании нового события
    func loadCollection(collection: Collection<Attachment>) {
        self.collection = collection;
        self.attachCollection()
        self.reloadData()
    }
    
    func reloadData() {
        self.collectionView!.reloadData()
    }
    
    //в остальных view
    func fetchCollection(collection: Collection<Attachment>) {
        self.collection = collection;
        self.attachCollection()
        
        let delta: Int64 = 1 * Int64(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, delta)
        
        dispatch_after(time, dispatch_get_main_queue(), {
            self.configureStateMachine()
            self.refresh()
        })
    }
    
    func attachCollection() {
        self.deattachCollection()
        
        if self.collection != nil {
            self.collection!.events.listenTo("sync", action: {
                let delta: Int64 = 1 * Int64(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, delta)
                
                dispatch_after(time, dispatch_get_main_queue(), {
                    self.collectionView!.reloadData()
                    self.endLoading(true, error: nil)
                })
            })
            
            self.collection!.events.listenTo("add", action: {
                self.collectionView!.reloadData()
            })
            
            self.collection!.events.listenTo("remove", action: {
                self.collectionView!.reloadData()
            })
            
            self.collection!.events.listenTo("error", action: { (err:Any?) in
                print(err)
                self.endLoading(true, error: err as? NSError, completion: nil)
            })
        }
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let kWhateverHeightYouWant: CGFloat  = 120
        let kWhateverWidthYouWant: CGFloat   = 145
        
        if self.collection!.count == 0 {
            return CGSizeMake(collectionView.bounds.size.width - 20, kWhateverHeightYouWant)
        }
            
        return CGSizeMake(kWhateverWidthYouWant, kWhateverHeightYouWant)
    }
    
    func deattachCollection() {
        if self.collection != nil {
            self.collection!.events.removeListeners("sync")
            self.collection!.events.removeListeners("add")
            self.collection!.events.removeListeners("error")
        }
    }
    
    func refresh() {
        if (currentState == .Loading) { return }
        
        self.startLoading(true)
        
        if self.collection != nil {
            self.collection!.fetch()
        }
    }
    
    func configureStateMachine() {
//        var frame = CGRectMake(0, 0, 320, 250)
//        self.loadingView = LoadingView(frame: frame)
//        self.emptyView = EmptyView(frame: frame)
//        let failureView = ErrorView(frame: frame)
//        failureView.tapGestureRecognizer.addTarget(self, action: Selector("refresh"))
//        self.errorView = failureView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.registerNib(UINib(nibName: "SliderPhotosCellView", bundle: nil), forCellWithReuseIdentifier: reusableIdentifierPhoto)

        self.collectionView!.registerNib(UINib(nibName: "SliderNewPhotoViewCell", bundle: nil), forCellWithReuseIdentifier:reusableIdentifierNewPhoto)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.attachCollection()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.deattachCollection()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collection != nil {
            return  collection!.count + offset;
        }
        
        return 0        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (self.allowNewPhoto && indexPath.row == collection!.count) {
            let newCellPhoto = collectionView.cellForItemAtIndexPath(indexPath) as! SliderNewPhotoViewCell
            
            self.presentImagePickerSheet(newCellPhoto.button, sourceRect: newCellPhoto.button.bounds)
        } else {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SliderPhotoCollectionViewCell
            
            cell.didTapViewCell(self, collection: collection!)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (self.allowNewPhoto && indexPath.row == collection!.count) {
            return collectionView.dequeueReusableCellWithReuseIdentifier(reusableIdentifierNewPhoto, forIndexPath: indexPath)
        } else {
            let cell : SliderPhotoCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableIdentifierPhoto, forIndexPath: indexPath) as! SliderPhotoCollectionViewCell

            if let model = collection!.valueAtIndex(indexPath.row) {
                cell.allowRemovePhoto = allowRemovePhoto
                cell.allowNewPhoto = allowNewPhoto
                cell.prepareView(model)
            }
            
            return cell
        }
    }
}

extension SliderPhotosCollectionView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentImagePickerSheet(sourceView: UIView, sourceRect: CGRect) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentImagePickerSheet(sourceView, sourceRect: sourceRect)
                }
            }
            
            return
        }
        
        if authorization == .Authorized {
            let presentImagePickerController: UIImagePickerControllerSourceType -> () = { source in
                let controller = UIImagePickerController()
                controller.delegate = self
                var sourceType = source
                
                if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                    sourceType = .PhotoLibrary
                    print("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
                }
                
                controller.sourceType = sourceType
                
                self.parentController!.presentViewController(controller, animated: true, completion: nil)
            }
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let cameraAction = UIAlertAction(title: "Сделать фото".localized, style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) in presentImagePickerController(.Camera) })
            
            let libraryAction = UIAlertAction(title: "Открыть библиотеку".localized, style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) in presentImagePickerController(.PhotoLibrary) })
            
            let cancelAction = UIAlertAction(title: "Закрыть".localized, style: UIAlertActionStyle.Cancel, handler: nil)
            
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(libraryAction)
            actionSheet.addAction(cancelAction)
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                actionSheet.popoverPresentationController!.sourceRect = sourceRect
                actionSheet.popoverPresentationController!.sourceView = sourceView
            }
            
            self.parentController!.presentViewController(actionSheet, animated: true, completion: nil)
        }
        else {
            let alertView = UIAlertView(title: NSLocalizedString("An error occurred", comment: "An error occurred"), message: NSLocalizedString("ImagePickerSheet needs access to the camera roll", comment: "ImagePickerSheet needs access to the camera roll"), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "OK"))
            alertView.show()
        }
    }
    
    func performUploadImage(image: UIImage) {
        let attachment = Attachment.withImage(image, scenario: "event")

        if let target_id = collection!.valueData("target_id") as? String {
            attachment.updateValue(forKey: "target_id", value: target_id)
        }
        
        UploadHelper.uploadImage(attachment)
            .responseSuccess({ (request, response, JSON, error) in
                self.collection!.appendModel(attachment)
            })
    }
    
    //ресайз
    func performResizeImage(image: UIImage) {
        performUploadImage(RBResizeImage(image, targetSize: CGSizeMake(1500, 1500)))
    }
    
    //добавить кроп
    func performCropImage(image: UIImage) {
        let cropController: TOCropViewController = TOCropViewController(image: image)
        cropController.delegate = self
        self.parentController!.presentViewController(cropController, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        self.parentController!.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        if picker.sourceType == UIImagePickerControllerSourceType.Camera {
                imageWriteToSavedPhotosAlbum(image)
        }

//        performCropImage(image)
//        performUploadImage(image)
        performResizeImage(image)
    }
    
    func imageWriteToSavedPhotosAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<()>) {
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.parentController!.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SliderPhotosCollectionView: TOCropViewControllerDelegate  {
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        performUploadImage(image)
        self.parentController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cropViewController(cropViewController: TOCropViewController!, didFinishCancelled cancelled: Bool) {
        self.parentController!.dismissViewControllerAnimated(true, completion: nil)
    }
}

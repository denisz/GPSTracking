//
//  ColorFormViewController.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/21/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//
import UIKit
import XLForm

class ColorFormViewController: UIViewController, XLFormRowDescriptorViewController {
    var rowDescriptor: XLFormRowDescriptor?    
    private let ColorCellIdentifier = "ColorCell"
    
    private let mainColor = UIColor(hex: 0xc0392b)
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    private var colors: [[String : String]] = [[String : String]]() {
        didSet {
            colorCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Цвет"
        colors = loadColorsFromJson()
    }
    
    func loadColorsFromJson() -> [[String : String]] {
        let path = NSBundle.mainBundle().pathForResource("colorsAuto", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
        
        do {
            return try NSJSONSerialization.JSONObjectWithData(jsonData!,options: NSJSONReadingOptions.MutableContainers) as! [[String : String]]
        }catch {}
        
        return []
    }

    
}
extension ColorFormViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let obj = colors[indexPath.row]
        self.rowDescriptor!.value = obj["color"]!
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension ColorFormViewController: UICollectionViewDataSource {
    // MARK: - UICollectionView DataSource Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ColorCellIdentifier, forIndexPath: indexPath) as! ColorCellView
        
        let obj = colors[indexPath.row]
        cell.titleLabel.text = obj["title"]
        cell.colorView.backgroundColor = ColorHelper.colorWithHexString(obj["color"]!)
        
        return cell
    }
}


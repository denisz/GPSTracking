//
//  GoogleAutocompleteViewController.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/12/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import XLForm

//let apiKeyGoogleAutocomplete: String = "AIzaSyAqKNVSwiKaehPoyAG16HA803uxUHhGne0"
let apiKeyGoogleAutocomplete: String = "AIzaSyBL1lNiRFKHOa5wnn52z2WPzc4MWirZ8AE"
let reuseIdentifierAutocompletePlace: String = "PlaceAutocompleteCell"

public class GoogleAutocompleteAnnotation: NSObject {
    var location: CLLocation
    var desc: String
    
    init(location: CLLocation, desc: String) {
        self.location = location
        self.desc = desc
    }
}

class GoogleAutocompleteViewController: UIViewController, XLFormRowDescriptorViewController {
    var rowDescriptor: XLFormRowDescriptor?
    var countryTable: UITableView!
    var timerUpdateList: NSTimer?
    var countrySearchController = UISearchController(searchResultsController: nil)
    var currentPredictions: [[String]] = [[]]
    let googleApiKey:String = apiKeyGoogleAutocomplete
    let kMinLettersForRequest = 4
    let timeInterval: NSTimeInterval = 1.0//чекаем место положение каждые 10 сек
    var textSearch: String = ""
    
    func returnGooglePredictionUrlString(input:String) -> String {
        let predictionUrlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(input)&types=geocode&language\(NSBundle.mainBundle().preferredLocalizations)&key=\(self.googleApiKey)"
        return predictionUrlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func returnGoogleDetailUrlString(placeId:String) -> String {
        let detailsUrlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&key=\(self.googleApiKey)"
        return detailsUrlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    override func viewWillAppear(animated: Bool ) {
        super.viewWillDisappear(animated)
        print("viewWillAppear")
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.definesPresentationContext = true
        
        _ = UIView(frame: CGRectMake(0.0, 0.0, self.view.bounds.width, 44.0))
        let footerView = UIView(frame: CGRectMake(0.0, 0.0, self.view.bounds.width, 44.0))
//        var footerImageView = UIImageView(image: UIImage(named: "powered-by-google"))
//        footerImageView.center = footerView.center
//        footerView.addSubview(footerImageView)
        
        self.countryTable = UITableView(frame: CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height), style: UITableViewStyle.Plain)
        self.countryTable.rowHeight = 60
        self.countryTable.registerNib(UINib(nibName: "PlaceAutocompleteViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifierAutocompletePlace)
        self.countryTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)

        self.view.addSubview(self.countryTable)

        self.countrySearchController.searchResultsUpdater = self
        self.countrySearchController.hidesNavigationBarDuringPresentation = false
        self.countrySearchController.dimsBackgroundDuringPresentation = false
        self.countrySearchController.searchBar.sizeToFit()
        self.countrySearchController.searchBar.delegate = self
        self.countrySearchController.searchBar.showsCancelButton = false
        self.countrySearchController.searchBar.placeholder = ""
        self.countrySearchController.searchBar.searchBarStyle = .Minimal
        self.countrySearchController.definesPresentationContext = true
        self.countrySearchController.searchBar.barTintColor = UIColor.whiteColor()
        
        self.navigationItem.titleView = self.countrySearchController.searchBar
//        headerView.addSubview(self.countrySearchController.searchBar)
        
//        self.countryTable.tableHeaderView = headerView
        self.countryTable.tableFooterView = footerView
        
        self.countryTable.delegate = self
        self.countryTable.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GoogleAutocompleteViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.currentPredictions.count > indexPath.row {
            var predict = self.currentPredictions[indexPath.row]
            
            self.detailGoogleApi(predict[1])
                .responseSwiftyJSON({ (req, res, json, err) in
                    let loc = json["result"]["geometry"]["location"]
                    let lat = loc["lat"].number as! CLLocationDegrees
                    let lon = loc["lng"].number as! CLLocationDegrees
                    let location = CLLocation(latitude: lat, longitude: lon)
                    let annotation = GoogleAutocompleteAnnotation(location: location, desc: predict[0])
                    self.rowDescriptor!.value = annotation as AnyObject
                    self.navigationController?.popViewControllerAnimated(true)
                })
        }
    }
}

// Data Source
extension GoogleAutocompleteViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.currentPredictions.count == 1 {
            return 0
        } else {
            return self.currentPredictions.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierAutocompletePlace) as! PlaceAutocompleteViewCell
        
        if self.currentPredictions.count > indexPath.row {
            cell.titleLabel?.text! = "\(self.currentPredictions[indexPath.row][0])"
        }
        
        return cell
    }
}

extension GoogleAutocompleteViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let text = searchController.searchBar.text
        let numberOfCharacters = text?.characters.count
        
        if numberOfCharacters >= self.kMinLettersForRequest {
            self.textSearch = searchController.searchBar.text!
            
            stopTimer()
            timerUpdateList = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target:self, selector: "timerDidFire:", userInfo: nil, repeats: false)
        } else if numberOfCharacters < kMinLettersForRequest {
            self.currentPredictions.removeAll(keepCapacity: false)
            self.countryTable.reloadData()
        }
    }
    
    func stopTimer() {
        if (self.timerUpdateList != nil) {
            self.timerUpdateList!.invalidate()
            self.timerUpdateList = nil
        }
    }
    
    func timerDidFire(timer: NSTimer) {
       googleApi(self.textSearch)
    }
    
    func googleApi(inputFromSearchBar:String) {
        let predictionUrlString = self.returnGooglePredictionUrlString(inputFromSearchBar)

        print(predictionUrlString)
        
        Alamofire.request(.GET, predictionUrlString)
            .responseSwiftyJSON({(req, res, jdata, err) in
                self.currentPredictions.removeAll(keepCapacity: true)
                let predictions = jdata["predictions"].arrayValue
                for predIndex in predictions {
                    let predictionPlaceIdArray = [predIndex["description"].stringValue, predIndex["place_id"].stringValue]
                    self.currentPredictions.append(predictionPlaceIdArray)
                    self.countryTable.reloadData()
                }
            })
    }
    
    func detailGoogleApi(placeId: String) -> Request {
        let detailUrlString = self.returnGoogleDetailUrlString(placeId)
        return Alamofire.request(.GET, detailUrlString)
    }
}

extension GoogleAutocompleteViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar){
        self.countrySearchController.searchBar.showsCancelButton = false
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.countrySearchController.searchBar.showsCancelButton = false
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        self.countrySearchController.searchBar.showsCancelButton = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.countrySearchController.searchBar.showsCancelButton = false
    }
}
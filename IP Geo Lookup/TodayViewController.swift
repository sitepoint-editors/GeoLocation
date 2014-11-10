//
//  TodayViewController.swift
//  IP Geo Lookup
//
//  Created by Jordan Morgan on 11/8/14.
//  Copyright (c) 2014 Jordan Morgan. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding
{
    
    //MARK: Properties
    @IBOutlet var btnRefresh: UIButton!
    @IBOutlet var lblGeoData: UILabel!
    var updateResult:NCUpdateResult = NCUpdateResult.NoData
    var geoInfoDictionary:NSDictionary?
    
    //MARK: View Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        self.updateWidget()
    }
    
    //MARK: NCWidget Providing
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!)
    {
        self.updateWidget()
        completionHandler(self.updateResult)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets
    {
        var newMargins = defaultMarginInsets
        newMargins.right = 10
        newMargins.bottom = 5
        return newMargins
    }
    
    //MARK: Update Logic - Data Retrieval
    func updateWidget()
    {
        if self.geoInfoDictionary == nil
        {
            self.lblGeoData.text = "Refreshing..."
            
            let urlPath: String = "http://www.telize.com/geoip?"
            let url: NSURL = NSURL(string: urlPath)!
            let request: NSURLRequest = NSURLRequest(URL: url)
            let queue:NSOperationQueue = NSOperationQueue()
            
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                
                if(error != nil)
                {
                    self.updateResult = NCUpdateResult.Failed
                    self.lblGeoData.text = "An error occurred while retrieving data"
                }
                else
                {
                    let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                    self.geoInfoDictionary = jsonResult
                }
                
                self.setLabelText()
            })
            
        }
        else
        {
            self.setLabelText()
        }
        
    }

    func setLabelText()
    {
        if let geoDictionary = self.geoInfoDictionary
        {
            let randomKeyIndex = Int(arc4random_uniform(UInt32(geoDictionary.count)))
            let randomKey = geoDictionary.allKeys[randomKeyIndex] as String
            let keyValue = geoDictionary[randomKey] as String
            let lblText = "\(randomKey) - \(keyValue)"
            
            if(self.lblGeoData.text != lblText)
            {
                self.updateResult = NCUpdateResult.NewData
                self.lblGeoData.text = lblText
            }
        }
        else
        {
            self.updateResult = NCUpdateResult.NoData
        }
        
    }
    
    @IBAction func btnRefreshData(sender: AnyObject)
    {
        self.geoInfoDictionary == nil ? self.updateWidget() : self.setLabelText()
    }
}

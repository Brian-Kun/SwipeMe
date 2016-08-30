//
//  ContentHolderViewController.swift
//  SwipeMe
//
//  Created by Brian Ramirez  on 8/30/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import UIKit

class ContentHolderViewController: UIViewController {
    
    var imageName:String!
    var pageIndex:Int!

    @IBOutlet weak var screenShotImageView: UIImageView!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(pageIndex == 5){
            continueBtn.hidden = false
            
        }else{
            continueBtn.hidden = true
        }
        screenShotImageView.image = UIImage(named: imageName)
    }

   
    
    @IBAction func continueBtnTapped(sender: UIButton) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(true, forKey: "displayedIntro")
        performSegueWithIdentifier("introDisplayedSegue", sender: self)
    }
    

}

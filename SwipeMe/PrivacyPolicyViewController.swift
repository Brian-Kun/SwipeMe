//
//  PrivacyPolicyViewController.swift
//  SwipeMe
//
//  Created by Tanaya Asnani on 8/30/16.
//  Copyright © 2016 Brian Ramirez. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {

    @IBOutlet weak var privacyPolicyTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 9.0, *) {
            privacyPolicyTextView.scrollEnabled = false
        }
        
        self.privacyPolicyTextView.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 9.0, *) {
            privacyPolicyTextView.scrollEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ViewController.swift
//  ReactYourCocoa
//
//  Created by Tami Wright on 9/15/14.
//  Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI
import Foundation

class LoginViewController: UIViewController {

    var faceBookLogin: FacebookLoginImpl?;
    
    required init(coder aDecoder: NSCoder) {
        faceBookLogin = FacebookLoginImpl();
        super.init(coder: aDecoder)
    }
    
    @IBOutlet var facebookLoginButton: UIButton!
    @IBOutlet var appLogoutButton: UIButton!
    @IBAction func facebookLoginTouch(sender: AnyObject)
    {
        faceBookLogin?.loginAndUpdateFacebookPermissions({ () -> Void in            
            self.checkButtonBindings()
            self.performSegueWithIdentifier("showMessages", sender: nil)
        })
    }
    
    @IBAction func appLogoutButtonTouch(sender: AnyObject) {
        PFFacebookUtils.unlinkUserInBackground(EWUser.currentUser(), {
            (succeeded: Bool!, error: NSError!) -> Void in
            if (succeeded != nil) {
                NSLog("The user is no longer associated with their Facebook account.")
                
                self.appLogoutButton.hidden = true
                self.facebookLoginButton.hidden = false
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        checkButtonBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func checkButtonBindings()
    {
        if (PFFacebookUtils.isLinkedWithUser(EWUser.currentUser()) || PFTwitterUtils.isLinkedWithUser(EWUser.currentUser())) {
            appLogoutButton.hidden = false
            facebookLoginButton.hidden = true
        }
        else
        {
            appLogoutButton.hidden = true
            facebookLoginButton.hidden = false
        }
    }
    
}


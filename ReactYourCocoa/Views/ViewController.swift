//
//  ViewController.swift
//  ReactYourCocoa
//
//  Created by Tami Wright on 9/15/14.
//  Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var loginSuccess: Bool
    var loginTimerTicks: Int
    var loginTimer: NSTimer?
    let LATENCY_BOUND: Int = 30;
    
    required init(coder aDecoder: NSCoder) {
        self.loginSuccess = false;
        self.loginTimerTicks = 0;
        super.init(coder: aDecoder);
    }

    @IBOutlet var facebookLoginButton: UIButton!
    @IBOutlet var appLogoutButton: UIButton!
    @IBAction func facebookLoginTouch(sender: AnyObject)
    {
        self.loginTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("checkLoginPermissionSuccess"), userInfo: nil, repeats: true)
        PFFacebookUtils.logInWithPermissions(EWFacebookPermissions.all(), {
            (user: PFUser!, error: NSError!) -> Void in
            if user == nil {
                NSLog("Uh oh. The user cancelled the Facebook login.")
            } else if user.isNew {
                NSLog("User signed up and logged in through Facebook!")
                self.obtainCompleteFacebookPermissions()
            } else {
                NSLog("User logged in through Facebook!")
                self.obtainCompleteFacebookPermissions()
            }
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

    func checkLoginPermissionSuccess() {
        self.loginTimerTicks++;
        // We were able to login and get necessary perms
        if (self.loginSuccess && self.loginTimer != nil) {
            self.loginTimer?.invalidate()
            self.loginTimer = nil
            self.loginTimerTicks = 0
            self.checkButtonBindings()
            self.performSegueWithIdentifier("showMessages", sender: nil)
        }
        // Something went wrong and we've exceeded our latency bounds
        if (self.loginTimerTicks >= LATENCY_BOUND && self.loginTimer != nil && !self.loginSuccess)
        {
            self.loginTimer?.invalidate()
            self.loginTimer = nil
            self.loginTimerTicks = 0
            self.loginSuccess = false;
        }
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
    
    func obtainCompleteFacebookPermissions()
    {
        if (PFFacebookUtils.isLinkedWithUser(EWUser.currentUser())) {
            var missingReadPermissions = [String]();
            var missingPublishPermissions = [String]();
            let allPermissions = EWFacebookPermissions.all() as [String]
            let publishPermissions = EWFacebookPermissions.publish() as [String]
            for permission in allPermissions {
                if let activePermissions = FBSession.activeSession().permissions as? [String] {
                    if (!contains(activePermissions, permission)) {
                        if (contains(publishPermissions, permission)){
                            missingPublishPermissions.append(permission);
                        }
                        else {
                            missingReadPermissions.append(permission);
                        }
                    }
                }
            }
            
            if (!missingReadPermissions.isEmpty) {
                FBSession.activeSession().requestNewReadPermissions(missingReadPermissions, completionHandler: { (session:FBSession!, error:NSError!) -> Void in
                    if (error != nil) {
                        NSLog("New read permissions granted")
                        self.loginSuccess = true;
                    }
                })
            }
            else if (!missingPublishPermissions.isEmpty) {
                PFFacebookUtils.reauthorizeUser(PFUser.currentUser(), withPublishPermissions:missingPublishPermissions,
                    audience:FBSessionDefaultAudience.Everyone, {
                        (succeeded: Bool!, error: NSError!) -> Void in
                        if (succeeded != nil) {
                            NSLog("User logged in through Facebook!")
                            self.loginSuccess = true;
                        }
                })
            }
            else {
                self.loginSuccess = true;
            }
        }
    }
}


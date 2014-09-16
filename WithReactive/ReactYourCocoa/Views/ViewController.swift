//
//  ViewController.swift
//  ReactYourCocoa
//
//  Created by Tami Wright on 9/15/14.
//  Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var facebookLoginButton: UIButton!
    @IBOutlet var appLogoutButton: UIButton!
    @IBAction func facebookLoginTouch(sender: AnyObject)
    {
        PFFacebookUtils.logInWithPermissions(EWFacebookPermissions.all(), {
            (user: PFUser!, error: NSError!) -> Void in
            if user == nil {
                NSLog("Uh oh. The user cancelled the Facebook login.")
            } else if user.isNew {
                NSLog("User signed up and logged in through Facebook!")
                self.obtainCompleteFacebookPermissions({
                    self.checkButtonBindings()
                    self.performSegueWithIdentifier("showMessages", sender: nil)
                })
            } else {
                NSLog("User logged in through Facebook!")
                self.obtainCompleteFacebookPermissions({
                    self.checkButtonBindings()
                    self.performSegueWithIdentifier("showMessages", sender: nil)
                })
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
    
    func obtainCompleteFacebookPermissions(completion: (() -> Void)? )
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
                        if ((completion) != nil){
                            completion!();
                        }
                    }
                })
            }
            else if (!missingPublishPermissions.isEmpty) {
                PFFacebookUtils.reauthorizeUser(PFUser.currentUser(), withPublishPermissions:missingPublishPermissions,
                    audience:FBSessionDefaultAudience.Everyone, {
                        (succeeded: Bool!, error: NSError!) -> Void in
                        if (succeeded != nil) {
                            NSLog("User logged in through Facebook!")
                            if ((completion) != nil){
                                completion!();
                            }
                        }
                })
            }
            else {
                if ((completion) != nil){
                    completion!();
                }
            }
        }
    }
}


//
//  FacebookLoginImpl.swift
//  ReactYourCocoa
//
//  Created by Tami Wright on 9/16/14.
//  Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

import Foundation

public class FacebookLoginImpl: NSObject
{
    override init() {
        
    }
    
    func loginFacebookInitialStepSignal() -> RACSignal {
        return RACSignal.createSignal({ (subscriber: RACSubscriber!) -> RACDisposable! in
            PFFacebookUtils.logInWithPermissions(EWFacebookPermissions.all(), {
                (user: PFUser!, error: NSError!) -> Void in
                if ((error) != nil) {
                    subscriber.sendError(error)
                }
                else {
                    subscriber.sendNext(user)
                    subscriber.sendCompleted()
                }
            })
            return nil;
        })
    }
    
    func updateFacebookPermissionsNextStepSingal() -> RACSignal {
        return RACSignal.createSignal({ (subscriber: RACSubscriber!) -> RACDisposable! in
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
                            subscriber.sendError(error)
                        }
                        else
                        {
                            NSLog("New read permissions granted")
                            subscriber.sendNext(session)
                            subscriber.sendCompleted()
                        }
                    })
                }
                else if (!missingPublishPermissions.isEmpty) {
                    PFFacebookUtils.reauthorizeUser(PFUser.currentUser(), withPublishPermissions:missingPublishPermissions,
                        audience:FBSessionDefaultAudience.Everyone, {
                            (succeeded: Bool!, error: NSError!) -> Void in
                            if (error != nil) {
                                subscriber.sendError(error)
                            }
                            else
                            {
                                NSLog("New read permissions granted")
                                subscriber.sendNext(succeeded)
                                subscriber.sendCompleted()
                            }
                    })
                }
                else {
                    
                    subscriber.sendNext(true)
                    subscriber.sendCompleted()
                }
            }
            return nil
        })
    }
    
    func loginAndUpdateFacebookPermissions(completion: (() -> Void)?) {
        weak var weakSelf:FacebookLoginImpl? = self;
        self.loginFacebookInitialStepSignal().flattenMap { (x: AnyObject!) -> RACStream! in
            return weakSelf?.updateFacebookPermissionsNextStepSingal()
            }.subscribeNext { (x:AnyObject!) -> Void in
                if ((completion) != nil){
                    completion!();
                }
        }
    }
}
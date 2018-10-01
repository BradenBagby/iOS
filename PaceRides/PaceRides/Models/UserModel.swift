//
//  UserModel.swift
//  PaceRides
//
//  Created by Grant Broadwater on 9/30/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import Foundation
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

extension NSNotification.Name {
    public static let UserPublicProfileDidChange = Notification.Name("UserPublicProfileDidChange")
    public static let UserSchoolProfileDidChange = Notification.Name("UserSchoolProfileDidChange")
}

class UserProfile {
    
    let uid: String
    var providerId: String? = nil
    var displayName: String? = nil
    var photoUrl: URL? = nil
    var emailVerified = false
    
    init(uid: String) {
        self.uid = uid
    }
}

class UserModel: NSObject {
    
    static let sharedInstance = UserModel()
    
    let db = Firestore.firestore()
    let notificationCenter = NotificationCenter.default

    private var _publicProfile: UserProfile? = nil
    var publicProfile: UserProfile? {
        get {
            if let currentAccessToken = FBSDKAccessToken.current() {
                self.userLoggedInWithAccessToken(token: currentAccessToken.tokenString)
            }
            return _publicProfile
        }
        set {
            self._publicProfile = newValue
            self.notificationCenter.post(name: .UserPublicProfileDidChange, object: self)
        }
    }
    
    private var _schoolProfile: UserProfile? = nil
    var schoolProfile: UserProfile? {
        get {
            if let sp = self._schoolProfile {
                return sp
            }
            if let curUser = Auth.auth().currentUser {
                self.updateSchoolProfile(withAuthResult: curUser)
            }
            return self._schoolProfile
        }
        set {
            self._schoolProfile = newValue
            self.notificationCenter.post(name: .UserSchoolProfileDidChange, object: self)
        }
    }
    
    private override init() {
        super.init()
    }
    
    private func createUser(withEmail email: String, andPassword password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let authResult = authResult else {
                print("Invalid auth result")
                return
            }
            
            self.updateSchoolProfile(withAuthResult: authResult)
        }
    }
    
    func signIn(withEmail email: String, andPassword password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            
            guard error == nil else {
                if let err = error as NSError? {
                    if err.code == 17011 {
                        self.createUser(withEmail: email, andPassword: password)
                    }
                } else {
                    print(error!)
                }
                return
            }
            
            guard let authResult = authResult else {
                print("Invalid auth result")
                return
            }
            
            self.updateSchoolProfile(withAuthResult: authResult)
        }
    }
    
    func updateSchoolProfile(withAuthResult authResult: User) {
        let newSchoolProfile = UserProfile(uid: authResult.uid)
        newSchoolProfile.emailVerified = authResult.isEmailVerified
        newSchoolProfile.providerId = authResult.email
        newSchoolProfile.displayName = authResult.displayName
        self.schoolProfile = newSchoolProfile
    }
    
}

extension UserModel: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        guard error == nil else {
            print(error.localizedDescription)
            return
        }
        
        userLoggedInWithAccessToken(token: result.token.tokenString)
    }
    
    
    func userLoggedInWithAccessToken(token: String) {
        let fbCredential = FacebookAuthProvider.credential(withAccessToken: token)
        Auth.auth().signIn(with: fbCredential) { (authResult, error) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let authResult = authResult else {
                print("Auth result invalid")
                return
            }
            
            let newPublicProfile = UserProfile(uid: authResult.uid)
            newPublicProfile.providerId = authResult.providerID
            newPublicProfile.displayName = authResult.displayName
            newPublicProfile.photoUrl = authResult.photoURL
            
            self.publicProfile = newPublicProfile
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        self.publicProfile = nil
    }
}

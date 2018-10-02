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
    public static let UserSchoolEmailVerifiedDidChange = Notification.Name("UserSchoolEmailVerifiedDidChange")
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
            if let pubProf = self._publicProfile {
                return pubProf
            }
            if let curUser = Auth.auth().currentUser {
                for providerData in curUser.providerData {
                    if providerData.providerID.lowercased().contains("facebook") {
                        self.updatePublicProfile(curUser)
                        return self._publicProfile
                    }
                }
            }
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
                
                if curUser.email != nil {
                    self.updateSchoolProfile(curUser)
                    return self._schoolProfile
                }
                
                if curUser.providerData.count <= 0 {
                    do {
                        try Auth.auth().signOut()
                    } catch let error as NSError {
                        print(error)
                    }
                }
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
    
    func updatePublicProfile(_ user: User) {
        let newPublicProfile = UserProfile(uid: user.uid)
        newPublicProfile.providerId = user.providerID
        newPublicProfile.displayName = user.displayName
        for providerData in user.providerData {
            if providerData.providerID.lowercased().contains("facebook") {
                newPublicProfile.photoUrl
                    = URL(string: "https://graph.facebook.com/\(providerData.uid)/picture?width=300&height=300")
                print(providerData.uid)
            }
        }
        
        
        self.publicProfile = newPublicProfile
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
            
            self.updateSchoolProfile(authResult)
        }
    }
    
    func emailCompletionCallback(user: User?, error: Error?, email: String, password: String) {
        
        guard error == nil else {
            if let err = error as NSError? {
                if err.code == 17011 {
                    self.createUser(withEmail: email, andPassword: password)
                } else if err.code == 17014 {
                    
                    if let currentUser = Auth.auth().currentUser {
                        let fbCredential = FacebookAuthProvider.credential(
                            withAccessToken: FBSDKAccessToken.current()!.tokenString
                        )
                        currentUser.reauthenticate(with: fbCredential) { error in
                            
                            guard error == nil else {
                                print("Could not reauthenticate")
                                print(error!.localizedDescription)
                                return
                            }
                            
                            self.signIn(withEmail: email, andPassword: password)
                            return
                        }
                    }
                    
                    return
                }else {
                    print(error!)
                }
            } else {
                print(error!)
            }
            return
        }
        
        guard let user = user else {
            print("Invalid auth result")
            return
        }
        
        if !user.isEmailVerified {
            self.sendVerificationEmail()
        }
        
        self.updateSchoolProfile(user)
        
    }
    
    
    func signIn(withEmail email: String, andPassword password: String) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        if let currentUser = Auth.auth().currentUser {
            currentUser.linkAndRetrieveData(with: credential) { (authResult, error) in
                self.emailCompletionCallback(user: authResult?.user, error: error, email: email, password: password)
            }
            return
        }
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            self.emailCompletionCallback(user: authResult, error: error, email: email, password: password)
        }
    }
    
    func updateSchoolProfile(_ authResult: User) {
        let newSchoolProfile = UserProfile(uid: authResult.uid)
        newSchoolProfile.emailVerified = authResult.isEmailVerified
        newSchoolProfile.providerId = authResult.email
        newSchoolProfile.displayName = authResult.displayName
        
        self.schoolProfile = newSchoolProfile
    }
    
    private func _sendVerificationEmail() {
        if let currentUser = Auth.auth().currentUser {
            if !currentUser.isEmailVerified {
                currentUser.sendEmailVerification() { error in
                    
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                }
            } else {
                self.schoolProfile?.emailVerified = true
                self.notificationCenter.post(
                    name: .UserSchoolEmailVerifiedDidChange,
                    object: self
                )
            }
        }
    }
    
    func reloadFirebaseUser(completion: UserProfileChangeCallback? = nil) {
        if let currentUser = Auth.auth().currentUser {
            if let _ = currentUser.email {
                self.updateSchoolProfile(currentUser)
            }
            for providerData in currentUser.providerData {
                if providerData.providerID.lowercased().contains("facebook") {
                    self.updatePublicProfile(currentUser)
                }
            }
            currentUser.reload(completion: completion)
        }
    }
    
    func sendVerificationEmail(reloadFirst: Bool = false) {
        if reloadFirst {
            self.reloadFirebaseUser() { error in
                self._sendVerificationEmail()
            }
        } else {
            self._sendVerificationEmail()
        }
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
    
    private func fbAuthenticationCallback(user: User?, error: Error?) {
        
        guard error == nil else {
            print(error!)
            return
        }
        
        guard let user = user else {
            print("User invalid")
            return
        }
        
        self.updatePublicProfile(user)
    }
    
    
    private func userLoggedInWithAccessToken(token: String) {
        let fbCredential = FacebookAuthProvider.credential(withAccessToken: token)
        
        if let currentUser = Auth.auth().currentUser {
            currentUser.linkAndRetrieveData(with: fbCredential) { (authResult, error) in
                self.fbAuthenticationCallback(user: authResult?.user, error: error)
            }
            return
        }
        
        Auth.auth().signIn(with: fbCredential) { (authResult, error) in
            self.fbAuthenticationCallback(user: authResult, error: error)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        self.publicProfile = nil
    }
}

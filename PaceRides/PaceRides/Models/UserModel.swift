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

// MARK: External extensions

extension NSNotification.Name {
    public static let NewPaceUserAuthData = Notification.Name("NewPaceUserAuthData")
    public static let NewPaceUserData = Notification.Name("NewPaceUserData")
    public static let PaceUserUniversityDataDidChanged = Notification.Name("PaceUserUniversityDataDidChanged")
    public static let UserDatabaseSynconizationError = Notification.Name("UserDatabaseSynconizationError")
}


// MARK: - Supporting objects

class PaceFbLoginDelegate: NSObject, FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        guard error == nil else {
            print("Error logging into facebook")
            print(error.localizedDescription)
            return
        }
        
        guard let result = result else {
            print("FB login delegate signed in with no result")
            return
        }
        
        UserModel.createUser(fromFacebookTokenString: result.token.tokenString) { user, error in
            
            guard error == nil else {
                
                print("Error")
                print("After logging into facebook, firebase was unable to sign in user.")
                print(error!.localizedDescription)
                
                return
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Facebook Logout")
    }
}

public enum UserDBKeys: String {
    
    case publicProfile = "publicProfile"
    case displayName = "displayName"
    case facebookId = "facebookId"
    case organizations = "organizations"
    case organizationTitle = "title"
    case organizationReference = "reference"
    
    case schoolProfile = "schoolProfile"
    case email = "email"
    case isEmailVerified = "isEmailVerified"
}

public enum PaceUserError: Error {
    case PublicProfileAlreadyExists
    case SchoolProfileAlreadyExists
    case InvalidPhotoURL
}


extension PaceUserError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .PublicProfileAlreadyExists:
            return NSLocalizedString("Public profile already exists for this user.", comment: "")
        case .SchoolProfileAlreadyExists:
            return NSLocalizedString("School profile already exists for this user.", comment: "")
        case .InvalidPhotoURL:
            return NSLocalizedString("Invalid photo url", comment: "")
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .PublicProfileAlreadyExists:
            return NSLocalizedString("There was an attempt to set a public profile when one already exists.", comment: "")
        case .SchoolProfileAlreadyExists:
            return NSLocalizedString("There was an attempt to set a school profile when one already exists.", comment: "")
        case .InvalidPhotoURL:
            return NSLocalizedString("The photo url was not set or is invalid", comment: "")
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .PublicProfileAlreadyExists:
            return NSLocalizedString("Sign out existing user of unlink their existing public profile.", comment: "")
        case .SchoolProfileAlreadyExists:
            return NSLocalizedString("Sign out existing user of unlink their existing school profile.", comment: "")
        case .InvalidPhotoURL:
            return NSLocalizedString("Fix the photo url and then retry", comment: "")
        }
    }
}

extension PaceUserError: CustomNSError {
    
    public static var errorDomain: String {
        return "PaceUserModel"
    }
    
    public var errorCode: Int {
        switch self {
        case .PublicProfileAlreadyExists:
            return 10101
        case .SchoolProfileAlreadyExists:
            return 10102
        case .InvalidPhotoURL:
            return 10103
        }
    }
    
    public var errorUserInfo: [String: Any] {
        switch self {
        case .PublicProfileAlreadyExists:
            return [:]
        case .SchoolProfileAlreadyExists:
            return [:]
        case .InvalidPhotoURL:
            return [:]
        }
    }
}


enum PaceKnownFirebaseErrors: Error {
    case UserEmailDoesNotExist
}

extension PaceKnownFirebaseErrors: CustomNSError {
 
    public static var errorDomain: String {
        return "PaceKnownFirebaseErrors"
    }
    
    public var errorCode: Int {
        switch self {
        case .UserEmailDoesNotExist:
            return 17011
        }
    }
    
    public var errorUserInfo: [String: Any] {
        switch self {
        case .UserEmailDoesNotExist:
            return [:]
        }
    }
    
}


// Mark: - Type alias


typealias PaceAuthResultCallback = (PaceUser?, Error?) -> ()


// MARK: - Protocols


/// Base user for the pace rides application
protocol PaceUser {
    
    /// Firebase unique identifier
    var uid: String { get }
    
    
    /// Returns the public profile information if the user is signed into a public profile, nil otherwise
    func publicProfile() -> PacePublicProfile?
    
    
    /// Returns the public profile information if the user is signed into a public profile, nil otherwise
    func schoolProfile() -> PaceSchoolProfile?
    
    
    /// Reload the firebase user
    func reload(completion: ((Error?) -> Void)?)
    
    
    /// Sign out the current user
    func signOut() -> Error?
    
}


/// All information relating to the Pace Rides user's public facing profile
protocol PacePublicProfile {
    
    
    /// Firebase unique identifier
    var uid: String { get }
    
    
    /// Facebook display name
    var displayName: String? { get }
    
    
    /// Facebook assigned unique identifier
    var facebookId: String? { get }
    
    
    /// URL to facebook profile picture
    var photoUrl: URL? { get }
    
    
    /// Get the picture from this objects photoUrl
    func getProfilePicture(completion: ((UIImage?, Error?) -> Void)?)
    
    
    /// Gets all organizations the user is a part of, if any
    func organizations() -> [OrganizationModel]
}


/// All information relating to the Pace Rides user's school facing profile
protocol PaceSchoolProfile {
    
    
    /// Firebase unique identifier
    var uid: String { get }
    
    
    /// Email display name
    var displayName: String? { get }
    
    
    /// User's Email address
    var email: String? { get }
    
    
    /// Indicates if the user has verified this email address
    var isEmailVerified: Bool { get }
    
    
    /// Sends a verification email to the user provided email
    func sendEmailVerification(completion: ((Error?) -> Void)?)
    
    
    /// Reload the firebase user
    func reload(completion: UserProfileChangeCallback?)
    
    
    /// Get any university related data
    func getUniversityModel(completion: UniversityCompletionHandler?)
}


// MARK: - Base user functionality


/// Pace user implementation
class UserModel: NSObject, PaceUser {
    
    
    // MARK: Static members
    
    
    private static let db = Firestore.firestore()
    
    
    /// The notification center used for all PaceUser functionality
    static let notificationCenter = NotificationCenter.default
    
    
    /// User model if user is signed in, nil otherwise
    private static var _sharedInstance: UserModel?
    
    
    /// The current signed in user, nil if user is not signed in
    static func sharedInstance() -> PaceUser? {
        return _sharedInstance
    }
    
    
    /// The delegate for the facebook login button
    static let fbLoginDelegate: FBSDKLoginButtonDelegate = PaceFbLoginDelegate()
    
    
    /// Creates a user using facebook credentials
    static func createUser(fromFacebookTokenString token: String, completion: PaceAuthResultCallback? = nil) {
        
        // If a user already exits
        if let sharedInstance = UserModel._sharedInstance {
            // Use facebook token to set existing user's public profile
            sharedInstance.setPublicProfile(facebookTokenString: token, completion: completion)
            return
        }
        
        let fbCredentials = FacebookAuthProvider.credential(withAccessToken: token)
        UserModel.createUser(withCredentials: fbCredentials, completion: completion)
    }
    
    
    /// Creates a user using email and password
    static func createUser(fromEmail email: String, andPassword password: String, completion: PaceAuthResultCallback? = nil) {
        
        // If user already exists
        if let sharedInstance = self._sharedInstance {
            // User email and passowrd to set existing user's school profile
            sharedInstance.setSchoolProfile(email: email, password: password, completion: completion)
            return
        }
        
        let emailCredentials = EmailAuthProvider.credential(withEmail: email, password: password)
        UserModel.createUser(withCredentials: emailCredentials) { paceUser, error in
            
            // If there was an error creating the user
            if let error = error as NSError? {
                
                switch error.code {
                    
                // If the error was that the user doesn't exist yet
                case PaceKnownFirebaseErrors.UserEmailDoesNotExist.errorCode:
                    
                    // Create the user with the same completion callback
                    Auth.auth().createUser(withEmail: email, password: password) { user, error in
                        
                        if let completion = completion {
                            
                            var newPaceUser: PaceUser? = nil
                            
                            if let resultingFirebaseUser = user {
                                UserModel._sharedInstance = UserModel(forFirebaseUser: resultingFirebaseUser)
                                newPaceUser = UserModel.sharedInstance()
                            }
                            
                            completion(newPaceUser, error)
                            return
                        }
                    }
                    break
                    
                default:
                    break
                }
            }
            
            // Call completion callback
            if let completion = completion {
                completion(paceUser, error)
            }
        }
    }
    
    
    /// Creates a new user from credentials only if one does not already exists
    private static func createUser(withCredentials credentials: AuthCredential, completion: PaceAuthResultCallback? = nil) {
        
        // Create a new user
        Auth.auth().signIn(with: credentials) { user, error in
            if let completion = completion {
                
                // If user was able to sign in
                var userModelForCallback: UserModel? = nil
                if let user = user {
                    // Set new user as shared instance
                    UserModel._sharedInstance = UserModel(forFirebaseUser: user)
                    userModelForCallback = UserModel._sharedInstance

                    UserModel.notificationCenter.post(
                        name: .NewPaceUserAuthData,
                        object: nil
                    )
                }
                
                completion(userModelForCallback, error)
            }
        }
    }
    
    
    /// Updates User Model's shared instance with the current firebase user
    static func firebaseAuthStateChangeListener(_: Auth, user: User?) {
        if let user = user {
            _sharedInstance = UserModel(forFirebaseUser: user)
        } else {
            _sharedInstance = nil
            
            UserModel.notificationCenter.post(
                name: .PaceUserUniversityDataDidChanged,
                object: nil
            )
        }
        
        UserModel.notificationCenter.post(
            name: .NewPaceUserAuthData,
            object: nil
        )
    }
    
    
    // MARK: Instance members
    
    
    /// Firebase user object
    private let _user: User
    
    /// Convienience to only loop through user provider data once
    private var _facebookId: String? = nil
    
    /// Cached facebook profile picture
    private var _profilePicture: UIImage? = nil
    
    
    // Cached university model
    private var _universityModel: UniversityModel? = nil {
        didSet {
            UserModel.notificationCenter.post(
                name: .PaceUserUniversityDataDidChanged,
                object: nil
            )
        }
    }
    
    var uid: String {
        get {
            return self._user.uid
        }
    }
    
    private var userData: [String: Any]! = nil
    private var userDataListener: ListenerRegistration? = nil
    
    /// Only construct UserModel object from within UserModel class
    private init(forFirebaseUser user: User) {
        
        self._user = user
        
        super.init()
        
        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserAuthData,
            object: nil,
            queue: nil,
            using: self.userAuthDataChanged
        )
    }
    
    
    // Called when new auth data is availible
    private func userAuthDataChanged(_: Notification? = nil) {
        
        if let paceUser = UserModel.sharedInstance(), let userSchoolProfile = paceUser.schoolProfile() {
            userSchoolProfile.getUniversityModel(completion: nil)
        }
     
        // Push base auth data to database
        self.pushAuthDataToDatabase()
        
        if let listener = self.userDataListener {
            listener.remove()
        }
        
        // Listen for updates
        self.userDataListener = UserModel.db.collection("users").document(self.uid).addSnapshotListener(
            self.onUserDocumentUpdate
        )
    }
    
    private func onUserDocumentUpdate(userDocSnap: DocumentSnapshot?, error: Error?) {
     
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        
        guard let userDocSnap = userDocSnap, let userData = userDocSnap.data() else {
            print("Error, no user document")
            return
        }
        
        self.userData = userData
        
        UserModel.notificationCenter.post(
            name: .NewPaceUserData,
            object: nil
        )
    }
    
    
    /// Links the existing user with given credentials
    private func linkCredentials(_ credentials: AuthCredential, completion: PaceAuthResultCallback? = nil) {
        self._user.linkAndRetrieveData(with: credentials) { _, error in
            if let completion = completion {
                
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                
                UserModel.notificationCenter.post(
                    name: .NewPaceUserAuthData,
                    object: nil
                )
                
                completion(self, error)
            }
        }
    }
    
    
    func setPublicProfile(facebookTokenString token: String, completion: PaceAuthResultCallback? = nil) {
        
        // If a public profile already exists
        if self.publicProfile() != nil {
            if let completion = completion {
                
                // Alert callback with existing public profile and error
                completion(
                    self,
                    PaceUserError.PublicProfileAlreadyExists
                )
                return
            }
        }
        
        // Link existing user with facebook credentials
        let fbCrednetials = FacebookAuthProvider.credential(withAccessToken: token)
        self.linkCredentials(fbCrednetials, completion: completion)
    }
    
    
    func publicProfile() -> PacePublicProfile? {
        return self.facebookId == nil ? nil : self
    }
    
    
    func setSchoolProfile(email: String, password: String, completion: PaceAuthResultCallback?) {
        
        // If a school profile already exists
        if self.schoolProfile() != nil {
            if let completion = completion {
                
                // Alert callback with existing school profile and error
                completion(
                    self,
                    PaceUserError.SchoolProfileAlreadyExists
                )
                return
            }
        }
        
        let emailCrendentials = EmailAuthProvider.credential(withEmail: email, password: password)
        self.linkCredentials(emailCrendentials, completion: completion)
    }
    
    
    func schoolProfile() -> PaceSchoolProfile? {
        return self.email == nil ? nil : self
    }
    
    
    func reload(completion: ((Error?) -> Void)? = nil) {
        self._user.reload() { error in
            
            guard error == nil else {
                if let completion = completion {
                    completion(error)
                }
                return
            }
            
            UserModel.notificationCenter.post(
                name: .NewPaceUserAuthData,
                object: nil
            )
            
            if let completion = completion {
                completion(error)
            }
        }
    }
    
    
    func signOut() -> Error? {
        
        do {
            try Auth.auth().signOut()
        } catch let e as NSError {
            return e
        }
        
        FBSDKLoginManager().logOut()
        return nil
    }
    
    
    // MARK: - Database Management
    
    
    private func pushAuthDataToDatabase() {
        
        var dbData: [String: Any] = [:]
        if let userPublicProfile = self.publicProfile() {
            dbData[UserDBKeys.publicProfile.rawValue] = [
                UserDBKeys.facebookId.rawValue: userPublicProfile.facebookId,
                UserDBKeys.displayName.rawValue: userPublicProfile.displayName
            ]
        }
        if let userSchoolProfile = self.schoolProfile() {
            dbData[UserDBKeys.schoolProfile.rawValue] = [
                UserDBKeys.email.rawValue: userSchoolProfile.email as Any,
                UserDBKeys.isEmailVerified.rawValue: userSchoolProfile.isEmailVerified
            ]
        }
        
        UserModel.db.collection("users").document(self._user.uid).setData(dbData, options: SetOptions.merge()) { error in

            guard error == nil else {
                print(error!.localizedDescription)
                return
            }

        }
    }
    
}


// MARK: - Public Profile Functionality

extension UserModel: PacePublicProfile {
    
    /// The facebook given display name
    var displayName: String? {
        get {
            if let displayName = self._user.displayName {
                return displayName
            }
            
            // If email auth was executed first, email display name is defaulted
            for userInfo in self._user.providerData {
                if userInfo.providerID.lowercased().contains("facebook") {
                    return userInfo.displayName
                }
            }
            return nil
        }
    }
    
    /// The user's facebook unique identifier
    var facebookId: String? {
        if let fbId = self._facebookId {
            return fbId
        }
        
        for providerData in self._user.providerData {
            if providerData.providerID.lowercased().contains("facebook") {
                return providerData.uid
            }
        }
        
        return nil
    }
    
    /// The user's profile photo
    var photoUrl: URL? {
        if let fbId = self.facebookId {
            return URL(string: "https://graph.facebook.com/\(fbId)/picture?width=300&height=300")
        }
        return nil
    }
    
    
    func getProfilePicture(completion: ((UIImage?, Error?) -> Void)? = nil) {
        
        // If profile picture is already cached, return the cached image
        if let profilePicture = self._profilePicture {
            if let completion = completion {
                completion(profilePicture, nil)
            }
            return
        }
        
        // If there is a photo url
        if let url = self.photoUrl {
            
            // Fetch the data from the url
            let task = URLSession.shared.dataTask(with: url) { data, urlResponse, error in
                
                // If data was returned
                if let data = data {
                    
                    // Try to create image from the network data
                    self._profilePicture = UIImage(data: data)
                    if let completion = completion {
                        DispatchQueue.main.async() {
                            completion(self._profilePicture, error)
                            UserModel.notificationCenter.post(
                                name: .NewPaceUserAuthData,
                                object: nil
                            )
                        }
                    }
                }
                
                // Return with error if no data was returned
                if let completion = completion {
                    DispatchQueue.main.async() {
                        completion(nil, error)
                    }
                }
            }
            task.resume()
            
        } else {
            
            // Indicate that there is not a photourl to completion handler
            if let completion = completion {
                DispatchQueue.main.async() {
                    completion(nil, PaceUserError.InvalidPhotoURL)
                }
            }
        }
    }
    
    
    func organizations() -> [OrganizationModel] {
        var result = [OrganizationModel]()
        
        guard self.userData != nil else {
            return result
        }
        
        if let publicProfileData = self.userData[UserDBKeys.publicProfile.rawValue] as? [String: Any] {
            if let organizations = publicProfileData[UserDBKeys.organizations.rawValue] as? [[String: Any]] {
                for org in organizations {
                    if let orgTitle = org[UserDBKeys.organizationTitle.rawValue] as? String,
                            let orgRef = org[UserDBKeys.organizationReference.rawValue] as? DocumentReference {
                        result.append(OrganizationModel(withTitle: orgTitle, andReference: orgRef))
                    }
                }
            }
        }
        return result
    }
}


// MARK: - School Profile Functionality


extension UserModel: PaceSchoolProfile {
    
    var email: String? {
        return self._user.email
    }
    
    var isEmailVerified: Bool {
        return self._user.isEmailVerified
    }
    
    func sendEmailVerification(completion: ((Error?) -> Void)? = nil) {
        if !self.isEmailVerified {
            self._user.sendEmailVerification(completion: nil)
            
        }
    }
    
    
    func getUniversityModel(completion: UniversityCompletionHandler? = nil) {
        if let univModel = self._universityModel, let completion = completion {
            completion(univModel, nil)
            return
        }
        
        if let email = self.email {
            UniversityModel.getUniversity(
                withEmailDomain: String(email.split(separator: "@")[1])
            ) { university, error in
                
                if let university = university {
                    self._universityModel = university
                }
                
                if let completion = completion {
                    completion(university, error)
                }
            }
        } else {
            // Email should never be nil, as email would have to be non-nil in order to retrieve a school profile
            if let completion = completion {
                completion(nil, NSError(domain: "PaceUser", code: 1, userInfo: nil))
            }
        }
    }
}

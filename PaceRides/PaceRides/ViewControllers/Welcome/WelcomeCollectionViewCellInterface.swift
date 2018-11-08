//
//  WelcomeCollectionViewCellInterface.swift
//  PaceRides
//
//  Created by Grant Broadwater on 11/6/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit


class WelcomeCollectionViewCellInterface: UICollectionViewCell {
    
    fileprivate static let defaultDelegate = DefaultWelcomeCollectionViewCellInterfaceDelegate()
    
    var page: WelcomePage?
    var delegate: WelcomeCollectionViewCellInterfaceDelegate = WelcomeCollectionViewCellInterface.defaultDelegate
    func reloadDelegateData() {}
    
}


fileprivate class DefaultWelcomeCollectionViewCellInterfaceDelegate: WelcomeCollectionViewCellInterfaceDelegate {
    
    func getButtonText(cell: WelcomeCollectionViewCellInterface, completion: @escaping ((String?) -> Void)) {
        completion(nil)
    }
    
    
    func getButtonText(cell: WelcomeCollectionViewCellInterface) -> String? {
        return nil
    }
    
    func getButtonColor(cell: WelcomeCollectionViewCellInterface) -> UIColor? {
        return nil
    }
    
    func getButtonColor(cell: WelcomeCollectionViewCellInterface, completion: @escaping ((UIColor?) -> Void)) {
        completion(nil)
    }
    
    func handleButtonPress(cell: WelcomeCollectionViewCellInterface) {
    }
    

}

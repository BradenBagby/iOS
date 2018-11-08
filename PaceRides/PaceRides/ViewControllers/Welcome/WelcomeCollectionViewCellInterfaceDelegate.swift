//
//  File.swift
//  PaceRides
//
//  Created by Grant Broadwater on 11/6/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

protocol WelcomeCollectionViewCellInterfaceDelegate {
    
    func getButtonText(cell: WelcomeCollectionViewCellInterface) -> String?
    func getButtonText(cell: WelcomeCollectionViewCellInterface, completion: @escaping ((String?) -> Void))
    func getButtonColor(cell: WelcomeCollectionViewCellInterface) -> UIColor?
    func getButtonColor(cell: WelcomeCollectionViewCellInterface, completion: @escaping ((UIColor?) -> Void))
    func handleButtonPress(cell: WelcomeCollectionViewCellInterface) -> Void
    
}

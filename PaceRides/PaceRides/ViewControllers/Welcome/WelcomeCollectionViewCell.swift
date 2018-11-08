//
//  WelcomeCollectionViewCell.swift
//  PaceRides
//
//  Created by Grant Broadwater on 11/6/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class WelcomeCollectionViewCell: WelcomeCollectionViewCellInterface {
    
    static var reuseIdentifier: String = "WelcomeCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var primaryButton: UIButton!
    
    override var page: WelcomePage? {
        didSet {
            
            guard let model = self.page else {
                self.imageView.image = nil
                self.textView.text = nil
                self.textView.attributedText = nil
                return
            }
            
            // Set image view
            self.imageView.image = model.image
            
            // Set title
            let attributedText = NSMutableAttributedString(
                string: model.title,
                attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(
                        ofSize: 24.0,
                        weight: UIFont.Weight.light
                    )
                ]
            )
            
            // Set message
            attributedText.append(
                NSMutableAttributedString(
                    string: "\n\n\(model.message)",
                    attributes: [
                        NSAttributedString.Key.font: UIFont.systemFont(
                            ofSize: 18.0,
                            weight: UIFont.Weight.light
                        )
                    ]
                )
            )
            
            // Center text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            attributedText.addAttribute(
                NSAttributedString.Key.paragraphStyle,
                value: paragraphStyle,
                range: NSRange(
                    location: 0,
                    length: attributedText.string.count
                )
            )
            
            self.textView.attributedText = attributedText
        }
    }
    
    override var delegate: WelcomeCollectionViewCellInterfaceDelegate {
        didSet {
            self.reloadDelegateData()
        }
    }
    
    
    override func reloadDelegateData() {
        
        guard let model = self.page else {
            self.primaryButton.setTitle(nil, for: .normal)
            return
        }
        
        // Set button text
        if let buttonText = delegate.getButtonText(cell: self) {
            self.primaryButton.setTitle(buttonText, for: .normal)
        } else {
            delegate.getButtonText(cell: self) { buttonText in
                DispatchQueue.main.async {
                    self.primaryButton.setTitle(buttonText, for: .normal)
                }
            }
        }
        
        // Set button color
        if let buttonColor = delegate.getButtonColor(cell: self) {
            self.primaryButton.setTitleColor(buttonColor, for: .normal)
        } else {
            delegate.getButtonColor(cell: self) { buttonColor in
                DispatchQueue.main.async {
                    self.primaryButton.setTitleColor(buttonColor, for: .normal)
                }
            }
        }
    }
    
    @IBAction func primaryButtonWasPressed() {
        
        guard let model = self.page else {
            return
        }
        
        delegate.handleButtonPress(cell: self)
    }
}

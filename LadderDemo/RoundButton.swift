//
//  RoundButton.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/2/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit

@IBDesignable class RoundButton: UIButton {
    
    @IBInspectable var buttonColor = UIColor.blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(ovalIn: rect)
        buttonColor.setFill()
        path.fill()
    }
}

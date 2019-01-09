//
//  FocusView.swift
//  YCBarcodeReader
//
//  Created by Yurii Chudnovets on 1/9/19.
//  Copyright © 2019 Yurii Chudnovets. All rights reserved.
//

import UIKit

class FocusView: UIView {
    
    var lineColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    var lineWidth: CGFloat = 3 {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        
        let lineLength = rect.width/5
        
        let topLeftLinePath = UIBezierPath()
        topLeftLinePath.move(to: CGPoint(x: 0, y: lineLength))
        topLeftLinePath.addLine(to: CGPoint(x: 0, y: 0))
        topLeftLinePath.addLine(to: CGPoint(x: lineLength, y: 0))
        
        let topRightLinePath = UIBezierPath()
        topRightLinePath.move(to: CGPoint(x: rect.width, y: lineLength))
        topRightLinePath.addLine(to: CGPoint(x: rect.width, y: 0))
        topRightLinePath.addLine(to: CGPoint(x: rect.width - lineLength, y: 0))
        
        let bottomLeftLinePath = UIBezierPath()
        bottomLeftLinePath.move(to: CGPoint(x: lineLength, y: rect.height))
        bottomLeftLinePath.addLine(to: CGPoint(x: 0, y: rect.height))
        bottomLeftLinePath.addLine(to: CGPoint(x: 0, y: rect.height - lineLength))
        
        let bottomRightLinePath = UIBezierPath()
        bottomRightLinePath.move(to: CGPoint(x: rect.width, y: rect.height - lineLength))
        bottomRightLinePath.addLine(to: CGPoint(x: rect.width, y: rect.height))
        bottomRightLinePath.addLine(to: CGPoint(x: rect.width - lineLength, y: rect.height))
        
        lineColor.setStroke()
        
        topLeftLinePath.lineWidth = lineWidth
        topRightLinePath.lineWidth = lineWidth
        bottomLeftLinePath.lineWidth = lineWidth
        bottomRightLinePath.lineWidth = lineWidth
        
        topLeftLinePath.stroke()
        topRightLinePath.stroke()
        bottomLeftLinePath.stroke()
        bottomRightLinePath.stroke()
        
    }

}

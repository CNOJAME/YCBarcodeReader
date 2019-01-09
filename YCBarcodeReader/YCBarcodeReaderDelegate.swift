//
//  YCBarcodeReaderDelegate.swift
//  YCBarcodeReader
//
//  Created by Yurii Chudnovets on 1/4/19.
//  Copyright © 2019 Yurii Chudnovets. All rights reserved.
//

import Foundation

@objc public protocol YCBarcodeReaderDelegate: class {
    
    /// Delegate to handle the captured code.
    /// - parameter code: barcode value
    /// - parameter type: type of barcode
    @objc func reader(didReadCode code: String, type: String)
    
    /// Delegate to report errors.
    @objc optional func reader(didReceiveError error: Error)
    
}

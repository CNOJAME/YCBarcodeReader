//
//  YCBarcodeReaderControllerProtocol.swift
//  YCBarcodeReader
//
//  Created by Yurii Chudnovets on 1/4/19.
//  Copyright © 2019 Yurii Chudnovets. All rights reserved.
//

import Foundation

protocol YCBarcodeReaderControllerProtocol: class {
    
    var delegate: YCBarcodeReaderDelegate? { get set }
    
    var torchMode: TorchMode { get set }
    
    init(view: YCBarcodeReaderViewProtocol)
    
    /// Start capturing barcode from camera.
    func startCapturing()
    
    /// Stop capturing barcode from camera.
    func stopCapturing()
    
}

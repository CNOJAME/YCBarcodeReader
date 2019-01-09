//
//  BarcodeReaderViewProtocol.swift
//  BarcodeReader
//
//  Created by Yurii Chudnovets on 1/4/19.
//  Copyright © 2019 Yurii Chudnovets. All rights reserved.
//

import AVFoundation

protocol YCBarcodeReaderViewProtocol: class {
    
    var isTorchButtonHidden: Bool { get set }
    
    func addVideoPreviewLayer(layer: AVCaptureVideoPreviewLayer)
    
    func hideFocusView()
    
}

//
//  TorchMode.swift
//  YCBarcodeReader
//
//  Created by Yurii Chudnovets on 1/4/19.
//  Copyright © 2019 Yurii Chudnovets. All rights reserved.
//

import AVFoundation

public enum TorchMode {
    case on
    case off
    
    /// Returns the next torch mode.
    var next: TorchMode {
        switch self {
        case .on:
            return .off
        case .off:
            return .on
        }
    }
    
    /// Torch mode image.
    var image: UIImage {
        switch self {
        case .on:
            return imageNamed("flashOn")
        case .off:
            return imageNamed("flashOff")
        }
    }
    
    /// Returns `AVCaptureTorchMode` value.
    var captureTorchMode: AVCaptureDevice.TorchMode {
        switch self {
        case .on:
            return .on
        case .off:
            return .off
        }
    }
    
    private func imageNamed(_ name: String) -> UIImage {
        let cls = YCBarcodeReaderView.self
        var bundle = Bundle(for: cls)
        let traitCollection = UITraitCollection(displayScale: 3)
        
        if let resourceBundle = bundle.resourcePath.flatMap({ Bundle(path: $0 + "/YCBarcodeReader.bundle") }) {
            bundle = resourceBundle
        }
        
        guard let image = UIImage(named: name, in: bundle, compatibleWith: traitCollection) else {
            return UIImage()
        }
        
        return image
    }
    
}

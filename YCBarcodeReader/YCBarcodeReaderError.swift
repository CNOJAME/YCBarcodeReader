//
//  YCBarcodeReaderError.swift
//  YCBarcodeReader
//
//  Created by Yurii Chudnovets on 1/4/19.
//  Copyright © 2019 Yurii Chudnovets. All rights reserved.
//

import Foundation

public enum YCBarcodeReaderError: Error {
    case noDeviceError(String)
    case noFlashError(String)
    case noTorchModeError(String)
    case noAuthorizedToUseCamera(String)
}

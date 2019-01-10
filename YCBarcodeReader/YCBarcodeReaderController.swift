//
//  YCBarcodeReaderController.swift
//  YCBarcodeReader
//
//  Created by Yurii Chudnovets on 1/4/19.
//  Copyright © 2019 Yurii Chudnovets. All rights reserved.
//

import AVFoundation

class YCBarcodeReaderController: NSObject, YCBarcodeReaderControllerProtocol {
    
    //MARK: - Properties
    
    private unowned let view: YCBarcodeReaderViewProtocol
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var captureSession = AVCaptureSession()
    private var captureDevice: AVCaptureDevice? = AVCaptureDevice.default(for: .video)
    
    private var locked = false
    
    weak var delegate: YCBarcodeReaderDelegate? {
        didSet {
            lastError.map { (error) in
                delegate?.reader?(didReceiveError: error)
                lastError = nil
            }
        }
    }
    
    private var lastError: Error?
    
    var torchMode: TorchMode = .off {
        didSet {
            guard let captureDevice = captureDevice, captureDevice.hasFlash else {
                delegate?.reader?(didReceiveError: YCBarcodeReaderError.noFlashError("The capture device has not a flash."))
                return
            }
            guard captureDevice.isTorchModeSupported(torchMode.captureTorchMode) else {
                delegate?.reader?(didReceiveError: YCBarcodeReaderError.noTorchModeError("The device does not support the specified torch mode."))
                return
            }
            
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.torchMode = torchMode.captureTorchMode
                captureDevice.unlockForConfiguration()
            } catch {
                delegate?.reader?(didReceiveError: error)
            }
        }
    }
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    required init(view: YCBarcodeReaderViewProtocol) {
        self.view = view
        super.init()
        setupCamera()
    }
    
    deinit {
        stopCapturing()
    }
    
    //MARK: - Camera setup
    
    fileprivate func setupCamera() {
        checkPersmission { [weak self] (error) in
            guard let `self` = self else { return }
            if error != nil {
                self.lastError = error
                return
            }
            
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
            
            guard let captureDevice = deviceDiscoverySession.devices.first else {
                self.lastError = YCBarcodeReaderError.noDeviceError("Failed to get the camera device")
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                self.captureSession.addInput(input)
                
                let captureMetadataOutput = AVCaptureMetadataOutput()
                self.captureSession.addOutput(captureMetadataOutput)
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = self.supportedCodeTypes
            } catch {
                self.lastError = error
                return
            }
            
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.view.addVideoPreviewLayer(layer: self.videoPreviewLayer!)
            
            self.startCapturing()
        }
    }
    
    //MARK: - Actions
    
    func startCapturing() {
        torchMode = .off
        captureSession.startRunning()
        locked = false
        view.isTorchButtonHidden = false
    }
    
    func stopCapturing() {
        torchMode = .off
        captureSession.stopRunning()
        view.isTorchButtonHidden = true
        view.hideFocusView()
    }
    
}

extension YCBarcodeReaderController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !locked else { return }
        guard !metadataObjects.isEmpty else { return }
        
        guard
            let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
            var code = metadataObj.stringValue,
            supportedCodeTypes.contains(metadataObj.type)
            else { return }
        
        locked = true
        
        var rawType = metadataObj.type.rawValue
        if metadataObj.type == AVMetadataObject.ObjectType.ean13 && code.hasPrefix("0") {
            code = String(code.dropFirst())
            rawType = AVMetadataObject.ObjectType.upce.rawValue
        }
        
        stopCapturing()
        delegate?.reader(didReadCode: code, type: rawType)
    }
    
}

extension YCBarcodeReaderController {
    
    /// Checks authorization status of the capture device.
    private func checkPersmission(completion: @escaping (Error?) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(nil)
        case .notDetermined:
            askForPermissions(completion)
        default:
            completion(YCBarcodeReaderError.noAuthorizedToUseCamera("Not Authorized To Use Camera"))
        }
    }
    
    /// Asks for permission to use video.
    private func askForPermissions(_ completion: @escaping (Error?) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                guard granted else {
                    completion(YCBarcodeReaderError.noAuthorizedToUseCamera("Not Authorized To Use Camera"))
                    return
                }
                completion(nil)
            }
        }
    }
    
}

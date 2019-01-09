//
//  YCBarcodeReaderController.swift
//  YCBarcodeReader
//
//  Created by Yurii Chudnovets on 1/4/19.
//  Copyright © 2019 Yurii Chudnovets. All rights reserved.
//

import AVFoundation

class YCBarcodeReaderController: NSObject, YCBarcodeReaderControllerProtocol {
    
    private unowned let view: YCBarcodeReaderViewProtocol
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var captureSession = AVCaptureSession()
    private var captureDevice: AVCaptureDevice? = AVCaptureDevice.default(for: .video)
    
    private var locked = false
    private var isVisible = true
    public var isOneTimeSearch = true
    
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
    
    fileprivate func setupCamera() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            lastError = YCBarcodeReaderError.noDeviceError("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        } catch {
            lastError = error
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.addVideoPreviewLayer(layer: videoPreviewLayer!)
        
        startCapturing()
    }
    
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
        guard !locked && isVisible else { return }
        guard !metadataObjects.isEmpty else { return }
        
        guard
            let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
            var code = metadataObj.stringValue,
            supportedCodeTypes.contains(metadataObj.type)
            else { return }
        
        if isOneTimeSearch {
            locked = true
        }
        
        var rawType = metadataObj.type.rawValue
        if metadataObj.type == AVMetadataObject.ObjectType.ean13 && code.hasPrefix("0") {
            code = String(code.dropFirst())
            rawType = AVMetadataObject.ObjectType.upce.rawValue
        }
        
        stopCapturing()
        delegate?.reader(didReadCode: code, type: rawType)
    }
    
}

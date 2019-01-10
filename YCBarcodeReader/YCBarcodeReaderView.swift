//
//  YCBarcodeReaderView.swift
//  YCBarcodeReader
//
//  Created by Yurii Chudnovets on 1/4/19.
//  Copyright © 2019 Yurii Chudnovets. All rights reserved.
//

import UIKit
import AVFoundation

open class YCBarcodeReaderView: UIView {
    
    //MARK: - Properties
    
    private(set) var controller: YCBarcodeReaderControllerProtocol?
    
    /// Delegate to hadle captured code or get error.
    public weak var delegate: YCBarcodeReaderDelegate? {
        didSet {
            controller?.delegate = delegate
        }
    }
    
    private let torchButton: UIButton = UIButton()
    
    /// Show torch on/off button.
    @IBInspectable public var showTorchButton: Bool = true {
        didSet {
            torchButton.isHidden = !showTorchButton
        }
    }
    
    /// Set position to the torch button.
    public var torchButtonPosition: TorchButtonPosition = .topRight {
        didSet {
            torchButton.removeFromSuperview()
            setupTorchButtonConstraints()
        }
    }
    
    /// Set position to the torch button from storyboard.
    @IBInspectable public var torchButtonPositionSt: String {
        get {
            switch torchButtonPosition {
            case .bottomLeft:
                return "bottomLeft"
            case .bottomRight:
                return "bottomRight"
            case .topLeft:
                return "topLeft"
            case .topRight:
                return "topRight"
            }
        }
        set(position) {
            switch position {
            case "bottomLeft":
                torchButtonPosition = .bottomLeft
            case "bottomRight":
                torchButtonPosition = .bottomRight
            case "topLeft":
                torchButtonPosition = .topLeft
            case "topRight":
                torchButtonPosition = .topRight
            default:
                torchButtonPosition = .topRight
            }
        }
    }
    
    /// Set torch button bottom inset.
    @IBInspectable public var tbBottomInset: CGFloat {
        get { return torchButtonInsets.bottom }
        set { torchButtonInsets.bottom = newValue }
    }
    
    /// Set torch button left inset.
    @IBInspectable public var tbLeftInset: CGFloat {
        get { return torchButtonInsets.left }
        set { torchButtonInsets.left = newValue }
    }
    
    /// Set torch button right inset.
    @IBInspectable public var tbRightInset: CGFloat {
        get { return torchButtonInsets.right }
        set { torchButtonInsets.right = newValue }
    }
    
    /// Set torch button top inset.
    @IBInspectable public var tbTopInset: CGFloat {
        get { return torchButtonInsets.top }
        set { torchButtonInsets.top = newValue }
    }
    
    /// Set torch button insets.
    public var torchButtonInsets: UIEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15) {
        didSet {
            torchButton.removeFromSuperview()
            setupTorchButtonConstraints()
        }
    }
    
    /// Torch button image for on mode.
    @IBInspectable public var torchButtonOnImage: UIImage?
    
    /// Torch button image for off mode.
    @IBInspectable public var torchButtonOffImage: UIImage? {
        didSet {
            torchButton.setImage(torchButtonOffImage, for: .normal)
        }
    }
    
    private var isCustomTouchButtonImages: Bool {
        return torchButtonOffImage != nil && torchButtonOnImage != nil
    }
    
    /// Set on/off landscape orientation.
    @IBInspectable public var landscapeOrientation: Bool = false
    
    private let focusView: FocusView = {
        let v = FocusView()
        v.backgroundColor = .clear
        return v
    }()
    
    private var focusViewWidthConstraint: NSLayoutConstraint!
    private var focusViewHeightConstaint: NSLayoutConstraint!
    
    /// Show focus view.
    @IBInspectable public var focusViewShowed: Bool = true {
        didSet {
            focusView.isHidden = !focusViewShowed
        }
    }
    
    /// Set focus view border line color.
    @IBInspectable public var focusViewBorderColor: UIColor = .white {
        didSet {
            focusView.lineColor = focusViewBorderColor
        }
    }
    
    /// Set focus view border line width.
    @IBInspectable public var focusViewLineWidth: CGFloat = 3 {
        didSet {
            focusView.lineWidth = focusViewLineWidth
        }
    }
    
    /// Focus view size.
    @IBInspectable public var focusViewSize: CGSize = CGSize(width: 218, height: 150) {
        didSet {
            focusViewHeightConstaint.constant = focusViewSize.height
            focusViewWidthConstraint.constant = focusViewSize.width
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initController()
        setupViews()
        setupOrientationChangedObserver()
    }
    
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initController()
        setupViews()
        setupOrientationChangedObserver()
    }
    
    //MARK: - Setup views
    
    fileprivate func setupViews() {
        backgroundColor = .black
        
        setupFocusView()
        setupTorchButton()
    }
    
    fileprivate func setupTorchButton() {
        
        setupTorchButtonConstraints()
        
        torchButton.setImage(controller?.torchMode.image, for: .normal)
        torchButton.addTarget(self, action: #selector(didPressTorchButton(_:)), for: .touchUpInside)
    }
    
    fileprivate func setupTorchButtonConstraints() {
        torchButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(torchButton)
        
        torchButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        torchButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        switch torchButtonPosition {
        case .topLeft:
            torchButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: torchButtonInsets.left).isActive = true
            torchButton.topAnchor.constraint(equalTo: topAnchor, constant: torchButtonInsets.top).isActive = true
        case .topRight:
            torchButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -torchButtonInsets.right).isActive = true
            torchButton.topAnchor.constraint(equalTo: topAnchor, constant: torchButtonInsets.top).isActive = true
        case .bottomLeft:
            torchButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: torchButtonInsets.left).isActive = true
            torchButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -torchButtonInsets.bottom).isActive = true
        case .bottomRight:
            torchButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -torchButtonInsets.right).isActive = true
            torchButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -torchButtonInsets.bottom).isActive = true
        }
    }
    
    fileprivate func setupFocusView() {
        addSubview(focusView)
        focusView.translatesAutoresizingMaskIntoConstraints = false
        
        focusViewWidthConstraint = focusView.widthAnchor.constraint(equalToConstant: focusViewSize.width)
        focusViewHeightConstaint = focusView.heightAnchor.constraint(equalToConstant: focusViewSize.height)
        
        NSLayoutConstraint.activate([focusView.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     focusView.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     focusViewWidthConstraint,
                                     focusViewHeightConstaint])
    }
    
    fileprivate func initController() {
        controller = YCBarcodeReaderController(view: self)
    }
    
    fileprivate func setupOrientationChangedObserver() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(_:)), name: UIDevice.orientationDidChangeNotification, object: UIDevice.current)
    }
    
    //MARK: - Actions
    
    @objc private func didPressTorchButton(_ sender: UIButton) {
        controller?.torchMode = controller?.torchMode.next ?? .off
        if isCustomTouchButtonImages {
            guard let torchMode = controller?.torchMode else { return }
            torchButton.setImage(torchMode == .off ? torchButtonOffImage : torchButtonOnImage, for: .normal)
        } else {
            torchButton.setImage(controller?.torchMode.image, for: .normal)
        }
    }
    
    @objc private func orientationChanged(_ notification: NSNotification) {
        if !landscapeOrientation { return }
        guard let device = notification.object as? UIDevice else { return }
        switch device.orientation {
        case .faceDown, .faceUp, .unknown, .portraitUpsideDown:
            return
        default:
            break
        }
        if let sublayers = layer.sublayers {
            for layer in sublayers {
                if let previewLayer = layer as? AVCaptureVideoPreviewLayer {
                    previewLayer.frame = self.layer.bounds
                    changePreviewLayerOrientation(previewLayer: previewLayer)
                    break
                }
            }
        }
    }
    
    private func changePreviewLayerOrientation(previewLayer: AVCaptureVideoPreviewLayer) {
        if let connection = previewLayer.connection, connection.isVideoOrientationSupported {
            switch UIDevice.current.orientation {
            case .faceDown, .faceUp, .unknown, .portraitUpsideDown:
                break
            case .landscapeLeft:
                connection.videoOrientation = .landscapeRight
            case .landscapeRight:
                connection.videoOrientation = .landscapeLeft
            case .portrait:
                connection.videoOrientation = .portrait
            }
        }
    }
    
    /// Reset barcode view.
    public func reset() {
        focusView.isHidden = false && focusViewShowed
        controller?.startCapturing()
    }
    
}

extension YCBarcodeReaderView: YCBarcodeReaderViewProtocol {

    var isTorchButtonHidden: Bool {
        get {
            if !showTorchButton { return true }
            return torchButton.isHidden
        }
        set {
            if !showTorchButton { return }
            torchButton.isHidden = newValue
        }
    }
    
    func addVideoPreviewLayer(layer: AVCaptureVideoPreviewLayer) {
        layer.frame = self.layer.bounds
        self.layer.addSublayer(layer)
    }
    
    func hideFocusView() {
        focusView.isHidden = true
    }
    
}

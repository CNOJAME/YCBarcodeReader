

Pod::Spec.new do |s|

  s.name         = "YCBarcodeReader"
  s.version      = "1.0.1"
  s.summary      = "The framework for reading barcodes and qrcodes."
  s.description  = "The framework for reading barcodes and qrcodes. Instructions for installation
  are in [the README](https://github.com/YuraChudnick/YCBarcodeReader)."

  s.homepage     = "https://github.com/YuraChudnick/YCBarcodeReader"

  s.license      = { :type => "MIT", :file => "License.md" }

  s.author             = { "Y.Chudnick" => "y.chudnovets@temabit.com" }

  s.platform     = :ios, "10.0"

  s.source       = { :git => "https://github.com/YuraChudnick/YCBarcodeReader.git", :tag => s.version }

  s.source_files  = 'YCBarcodeReader', 'YCBarcodeReader/*.swift'

  s.resources = ['YCBarcodeReader/Resources/*.png']

  s.swift_version = '4.2'

end

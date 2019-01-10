# YCBarcodeReader

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/YCBarcodeReader.svg)](https://img.shields.io/cocoapods/v/YCBarcodeReader.svg)
[![Platform](https://img.shields.io/cocoapods/p/YCBarcodeReader.svg?style=flat)](https://img.shields.io/cocoapods/p/YCBarcodeReader.svg?style=flat)
[![Language](http://img.shields.io/badge/language-Swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)

![](https://raw.githubusercontent.com/YuraChudnick/YCBarcodeReader/master/Screenshots/4.jpg)
![](https://raw.githubusercontent.com/YuraChudnick/YCBarcodeReader/master/Screenshots/5.jpg)

## Installation
For YCBarcodeReader, use the following entry in your Podfile:

```rb

pod 'YCBarcodeReader'

```

Then run `pod install`.

In any file you'd like to use YCBarcodeReader in, don't forget to import the framework with import YCBarcodeReader.

## Usage

### Code-less Storyboard Implementation

1. Added Privacy - Camera Usage Description in Info.plist.
![](https://raw.githubusercontent.com/YuraChudnick/YCBarcodeReader/master/Screenshots/3.png)

2. Create a UIView in interface builder and assign custom class YCBarcodeReaderView.

![](https://raw.githubusercontent.com/YuraChudnick/YCBarcodeReader/master/Screenshots/1.jpg)

3. Setup YCBarcodeReaderView from storyboard.

![](https://raw.githubusercontent.com/YuraChudnick/YCBarcodeReader/master/Screenshots/2.jpg)

In storyboard you can setup:
- Show/hide torch button;
- Set position to torch button:

  | Position | Parameter |
  | --- | --- |
  | Bottom left | bottomLeft |
  | Bottom right | bottomRight |
  | Top left | topLeft |
  | Top Right | topRight |

- Set edge insets;
- Change torch button image for on/off mode;
- Set on/off landscape orientation;
- Show/hide focus view;
- Change border color of focus view;
- Change border line width of focus view;
- Set size of focus view.

4. Then connect delegate in view controller.

```swift
import UIKit
import YCBarcodeReader

class ViewController: UIViewController {

    @IBOutlet weak var barcodeReader: YCBarcodeReaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barcodeReader.delegate = self
    }

}

extension ViewController: YCBarcodeReaderDelegate {
    
    func reader(didReadCode code: String, type: String) {
        print(code)
    }
    
    func reader(didReceiveError error: Error) {
        print(error)
    }
    
}
```

5. Setup programmatically.

```swift
import UIKit
import YCBarcodeReader

class ViewController: UIViewController {

    @IBOutlet weak var barcodeReader: YCBarcodeReaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barcodeReader.delegate = self
        barcodeReader.showTorchButton = true
        barcodeReader.torchButtonPosition = .topLeft
        barcodeReader.torchButtonInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        barcodeReader.landscapeOrientation = true
        barcodeReader.focusViewShowed = true
        barcodeReader.focusViewBorderColor = .yellow
        barcodeReader.focusViewLineWidth = 5
        barcodeReader.focusViewSize = CGSize(width: 250, height: 180)
    }

}
```

## Author

YuraChudnick, y.chudnovets@temabit.com

## License

YCBarcodeReader is available under the MIT license. See the LICENSE file for more info.


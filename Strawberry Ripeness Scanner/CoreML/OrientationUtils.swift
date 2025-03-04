//
//  OrientationUtils.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 2/14/25.
//

import Foundation
import AVFoundation
import UIKit

class OrientationUtils {
    class func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let deviceOrientation = UIDevice.current.orientation
        let returnOrientation: CGImagePropertyOrientation
        
        switch deviceOrientation {
        case .portrait:
            returnOrientation = .right
        case .landscapeLeft:
            returnOrientation = .down
        case .landscapeRight:
            returnOrientation = .up
        case .portraitUpsideDown:
            returnOrientation = .left
        default:
            returnOrientation = .up
        }

        return returnOrientation
    }
    
    // not in use
//    class func getCurrentOrientation() -> UIInterfaceOrientation {
//        var orientation:UIInterfaceOrientation
//        if #available(iOS 13.0, *) {
//            orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .unknown
//        } else {
//            orientation = UIApplication.shared.statusBarOrientation
//        }
//        return orientation
//    }
//    
//    class func videoOrientationForCurrentOrientation() -> AVCaptureVideoOrientation {
//        let orientation = getCurrentOrientation()
//        var videoOrientation: AVCaptureVideoOrientation = .portrait
//        switch orientation {
//        case .portrait:
//            videoOrientation = .portrait
//            break
//        case .portraitUpsideDown:
//            videoOrientation = .portraitUpsideDown
//            break
//        case .landscapeLeft:
//            videoOrientation = .landscapeLeft
//            break
//        case .landscapeRight:
//            videoOrientation = .landscapeRight
//            break
//        default:
//            break
//        }
//        return videoOrientation
//    }
}

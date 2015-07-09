//
//  SPQuadView.swift
//  SPQuadView
//
//  Created by shadowPriest on 15/7/4.
//  Copyright (c) 2015年 hxx. All rights reserved.
//

import UIKit
import AVFoundation

class SPQuadView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    var session = AVCaptureSession()
    var device = AVCaptureDevice.devices().filter { (position) -> Bool in
        if let dev = position as? AVCaptureDevice{
            if (dev.position == .Back){
                 return true
            }
        }
        return false
    }
    lazy var videoInput : AVCaptureDeviceInput? = {
        if let device = self.device.first as? AVCaptureDevice{
            device.activeVideoMinFrameDuration = CMTimeMake(1, 30)
            device.activeVideoMaxFrameDuration = CMTimeMake(1, 30)
            let lazilyVideoInput = AVCaptureDeviceInput(device: device, error: nil)
            return lazilyVideoInput
        }
        return nil
    }()
    lazy var videoOutput: AVCaptureVideoDataOutput? = {
        let output = AVCaptureVideoDataOutput()
        let format = kCVPixelFormatType_32BGRA
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey : format]
        output.alwaysDiscardsLateVideoFrames = true
        return output
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(){
        self.init(frame: CGRectZero)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

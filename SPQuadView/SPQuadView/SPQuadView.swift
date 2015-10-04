//
//  SPQuadView.swift
//  SPQuadView
//
//  Created by shadowPriest on 15/7/4.
//  Copyright (c) 2015年 hxx. All rights reserved.
//

import UIKit
import AVFoundation

class SPQuadView: UIView ,AVCaptureVideoDataOutputSampleBufferDelegate{

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
            let lazilyVideoInput = try? AVCaptureDeviceInput(device: device)
            return lazilyVideoInput
        }
        return nil
    }()
    lazy var videoOutput: AVCaptureVideoDataOutput? = {
        let output = AVCaptureVideoDataOutput()
        let format = kCVPixelFormatType_32BGRA
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey : Int(format)]
        output.alwaysDiscardsLateVideoFrames = true
        let videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL)
        output.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        return output
    }()
    lazy var preview:AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer.init(session: self.session)
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(){
        self.init(frame: CGRectZero)
        self.session.startRunning()
        setupCamera()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    deinit{
        self.session.stopRunning()
    }
    
    override func layoutSubviews() {
        self.preview.frame = self.bounds
    }
    
    func setupCamera(){
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        if session.canAddOutput(videoOutput){
            session.addOutput(videoOutput)
        }
        self.layer.insertSublayer(preview, atIndex: 0)
    }
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
    }
}

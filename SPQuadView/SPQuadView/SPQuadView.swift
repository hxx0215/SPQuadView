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
    var image: UIImage?
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
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        return layer
    }()
    lazy var quadView:QuadShowView = {
        let view = QuadShowView(frame: self.bounds)
        return view
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
        videoOutput?.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = .Portrait
        self.layer.insertSublayer(preview, atIndex: 0)
        self.addSubview(self.quadView)
    }
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let image = fixImageOrientation(imageFromSampleBuffer(sampleBuffer))
        self.image = image
        let points = QuadDetector.quadfromImage(image)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.quadView.drawPath(points, imageSize: image.size, viewSize: self.bounds.size)
        }
    }
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage {
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        guard let imageBuffer = buffer else{
            return UIImage()
        }
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        
        // Get the number of bytes per row for the pixel buffer
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        
        // Get the number of bytes per row for the pixel buffer
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        // Get the pixel buffer width and height
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        // Create a device-dependent RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Create a bitmap graphics context with the sample buffer data
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue)
        let context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        // Create a Quartz image from the pixel data in the bitmap graphics context
        let quartzImage = CGBitmapContextCreateImage(context);
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        // Create an image object from the Quartz image
        let image = UIImage(CGImage: quartzImage!)
        
        return image
    }
    func fixImageOrientation(src:UIImage)->UIImage {
        
        if src.imageOrientation == UIImageOrientation.Up {
            return src
        }
        
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        switch src.imageOrientation {
        case UIImageOrientation.Down, UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, src.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
        case UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, src.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            break
        case UIImageOrientation.Up, UIImageOrientation.UpMirrored:
            break
        }
        
        switch src.imageOrientation {
        case UIImageOrientation.UpMirrored, UIImageOrientation.DownMirrored:
            CGAffineTransformTranslate(transform, src.size.width, 0)
            CGAffineTransformScale(transform, -1, 1)
            break
        case UIImageOrientation.LeftMirrored, UIImageOrientation.RightMirrored:
            CGAffineTransformTranslate(transform, src.size.height, 0)
            CGAffineTransformScale(transform, -1, 1)
        case UIImageOrientation.Up, UIImageOrientation.Down, UIImageOrientation.Left, UIImageOrientation.Right:
            break
        }
        
        let ctx:CGContextRef = CGBitmapContextCreate(nil, Int(src.size.width), Int(src.size.height), CGImageGetBitsPerComponent(src.CGImage), 0, CGImageGetColorSpace(src.CGImage), CGImageAlphaInfo.PremultipliedLast.rawValue)!
        
        CGContextConcatCTM(ctx, transform)
        
        switch src.imageOrientation {
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored, UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, src.size.height, src.size.width), src.CGImage)
            break
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, src.size.width, src.size.height), src.CGImage)
            break
        }
        
        let cgimg:CGImageRef = CGBitmapContextCreateImage(ctx)!
        let img:UIImage = UIImage(CGImage: cgimg)
        
        return img
    }
}

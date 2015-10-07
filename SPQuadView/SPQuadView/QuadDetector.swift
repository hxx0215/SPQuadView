//
//  QuadDetector.swift
//  SPQuadView
//
//  Created by shadowPriest on 15/10/6.
//  Copyright © 2015年 hxx. All rights reserved.
//

import UIKit

class QuadDetector: NSObject {

    static func quadfromImage(image: UIImage) -> [CGPoint]?{
        guard let ref = image.CGImage else{
            return nil
        }
        let ciimage = CIImage(CGImage: ref)
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorTracking: NSNumber(float: 1.0)]
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)
        let res = detector.featuresInImage(ciimage)
        if res.count < 1 {
            return nil
        }
        let h = ciimage.extent.size.height
        let rectangle = res[0] as! CIRectangleFeature
        let topLeft = CGPointMake(rectangle.topLeft.x, h - rectangle.topLeft.y)
        let topRight = CGPointMake(rectangle.topRight.x, h - rectangle.topRight.y)
        let bottomLeft = CGPointMake(rectangle.bottomLeft.x, h - rectangle.bottomLeft.y)
        let bottomRight = CGPointMake(rectangle.bottomRight.x, h - rectangle.bottomRight.y)
        return [topLeft,topRight,bottomLeft,bottomRight]
    }
}

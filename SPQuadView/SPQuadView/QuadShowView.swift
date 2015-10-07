//
//  QuadShowView.swift
//  SPQuadView
//
//  Created by shadowPriest on 15/10/7.
//  Copyright © 2015年 hxx. All rights reserved.
//

import UIKit

class QuadShowView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    lazy var path = UIBezierPath()
    lazy var caShape : CAShapeLayer = {
        let layer = CAShapeLayer()
        self.layer.addSublayer(layer)
        layer.fillColor = UIColor(red: 17.0/255.0, green: 159.0/255.0, blue: 253.0/255.0, alpha: 0.3).CGColor
        layer.strokeColor = UIColor.whiteColor().CGColor
        return layer
    }()
    
    func drawPath(points:[CGPoint]?,imageSize: CGSize,viewSize: CGSize){
        guard let pts = points else{ return }
        if pts.count < 4 {
            return
        }
        let p = pts.map { (pt) -> CGPoint in
            return CGPointMake(pt.x / imageSize.width * viewSize.width, pt.y / imageSize.height * viewSize.height)
        }
        self.path = UIBezierPath()
        self.path.moveToPoint(p[0])
        self.path.addLineToPoint(p[1])
        self.path.addLineToPoint(p[3])
        self.path.addLineToPoint(p[2])
        self.path.closePath()
        animation()
    }
    func clear(){
        self.path = UIBezierPath()
        self.caShape.path = self.path.CGPath
    }
    
    func animation(){
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.duration = 0.3
        pathAnimation.fromValue = self.caShape.path
        pathAnimation.toValue = self.path.CGPath
        self.caShape.addAnimation(pathAnimation, forKey: "path")
        self.caShape.path = self.path.CGPath
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

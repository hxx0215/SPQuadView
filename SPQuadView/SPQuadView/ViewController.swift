//
//  ViewController.swift
//  SPQuadView
//
//  Created by shadowPriest on 15/7/4.
//  Copyright (c) 2015年 hxx. All rights reserved.
//

import UIKit

class ShowController: UIViewController{
    let image = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(image)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.image.frame = self.view.bounds
    }
}

class ViewController: UIViewController {

    var cropView = SPQuadView()
    var checkButton : UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(cropView)
        let btn = UIButton.init(type: .Custom)
        btn.setTitle("checkit", forState: .Normal)
        btn.sizeToFit()
        btn.addTarget(self, action: Selector.init("check"), forControlEvents: .TouchUpInside)
        self.view.addSubview(btn)
        self.checkButton = btn
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        self.cropView.frame = self.view.bounds
    }

    func check(){
        let controller = ShowController()
        controller.image.image = cropView.image
        self.presentViewController(controller, animated: true) { () -> Void in
            
        }
    }

}


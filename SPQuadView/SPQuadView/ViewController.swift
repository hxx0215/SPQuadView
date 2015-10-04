//
//  ViewController.swift
//  SPQuadView
//
//  Created by shadowPriest on 15/7/4.
//  Copyright (c) 2015年 hxx. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    var cropView = SPQuadView()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(cropView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        self.cropView.frame = self.view.bounds
    }


}


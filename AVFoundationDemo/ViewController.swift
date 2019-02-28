//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by linkage on 2019/2/25.
//  Copyright © 2019年 yuanjian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func jump(_ sender: UIButton) {
        navigationController?.pushViewController(CameraViewController(), animated: true)
    }
    
}


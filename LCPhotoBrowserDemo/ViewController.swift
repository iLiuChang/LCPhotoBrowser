//
//  ViewController.swift
//  LCPhotoBrowserDemo
//
//  Created by 刘畅 on 16/5/31.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton()
        button.frame = CGRectMake(100, 70, 100, 50)
        button.setTitle("选择图片", forState: .Normal)
        button.backgroundColor = UIColor.purpleColor()
        button.addTarget(self, action: #selector(self.click(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        
        for i in 0 ..< 9 {
            let imageView = UIImageView()
            imageView.frame = CGRectMake((self.view.frame.width / 4 ) * CGFloat(i % 4), 200 + (CGFloat(i / 4) * self.view.frame.width / 4), self.view.frame.width / 4, self.view.frame.width / 4)
            imageView.tag = i + 100
            imageView.backgroundColor = UIColor.whiteColor()
            imageView.contentMode = .ScaleAspectFill
            imageView.clipsToBounds = true
            self.view.addSubview(imageView)
        }
    }
    
    func click(button: UIButton) {
        let photo = LCPhotoBrowser()
        photo.maxNumber = 5
        photo.lc_showAlert(self) { (images) in
            var index = 0
            for image in  images {
                index += 1
                let imageView = self.view.viewWithTag(index + 99) as! UIImageView
                imageView.image = image
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


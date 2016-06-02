//
//  LCPhotoBigViewController.swift
//  LCPhotoBrowser
//
//  Created by 刘畅 on 16/5/31.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit
import Photos

class LCPhotoBigViewController: UIViewController {

    var indexPath_Row: Int?
    var photoAssets: Array<LCPhotoAsset>?
    var indexPathNow: NSIndexPath!
    var photoBlock: ((photoLists: Array<LCPhotoAsset>) -> Void)?
    var maxNumber: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        initCollectionView()
        initItem()
    }
    
    func initItem() {
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 20, 20)
        button.setBackgroundImage(UIImage(named: "btn_unselected"), forState: .Normal)
        button.setBackgroundImage(UIImage(named: "btn_selected"), forState: .Selected)
        button.addTarget(self, action: #selector(self.click(_:)), forControlEvents: .TouchUpInside)
        let rightItem = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = rightItem
        
        let backItem = UIBarButtonItem.init(title: "返回", style: .Plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backItem
    }
    
    func initCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        
        let kItemMargin: CGFloat = 30
        layout.minimumLineSpacing = kItemMargin
        layout.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2)
        layout.itemSize = self.view.bounds.size
        let collectionView = UICollectionView.init(frame: CGRectMake(-kItemMargin/2, 0, self.view.frame.width+kItemMargin, self.view.frame.height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.blackColor()
        
        self.view.addSubview(collectionView)
        collectionView.registerClass(LCPhotoBigCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.tag = 999
        collectionView.dataSource = self
        collectionView.pagingEnabled = true
        collectionView.contentOffset.x = (self.view.frame.width + 30) * CGFloat(indexPath_Row!)
        collectionView.reloadData()
    }
    func back() {
        photoBlock!(photoLists: self.photoAssets!)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func click(button: UIButton) {
        var count = 0
        for photoList in self.photoAssets! {
            if photoList.selected == true {
                count += 1
            }
        }
        if count > maxNumber! - 1 && self.photoAssets![indexPathNow.row].selected == false {
            let alert = UIAlertController.init(title: "不能超过\(maxNumber!)张", message: "", preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            let action = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(action)
            return
        }
        if !button.selected {
            let animate = CAKeyframeAnimation.init(keyPath: "transform")
            animate.duration = 0.3
            animate.removedOnCompletion = true
            animate.fillMode = kCAFillModeForwards
            animate.values = [NSValue(CATransform3D: CATransform3DMakeScale(0.7, 0.7, 1.0)), NSValue(CATransform3D: CATransform3DMakeScale(1.2, 1.2, 1.0)), NSValue(CATransform3D: CATransform3DMakeScale(0.8, 0.8, 1.0)), NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0))]
            button.layer.addAnimation(animate, forKey: nil)
        }
        button.selected = !button.selected
        self.photoAssets![indexPathNow.row].selected = button.selected
        
    }

}

extension LCPhotoBigViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        indexPathNow = indexPath
        let cell1 = cell as! LCPhotoBigCell
        cell1.scrollView?.zoomScale = 1
        self.title = String(indexPath.row + 1) + "/" + String(self.photoAssets!.count)
        let button = self.navigationItem.rightBarButtonItem?.customView as! UIButton
        button.selected = self.photoAssets![indexPath.row].selected!
        cell1.imgView!.frame = cell1.scrollView!.frame
    }
}

extension LCPhotoBigViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (photoAssets?.count)!
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! LCPhotoBigCell
        cell.backgroundColor = UIColor.blackColor()
        cell.scrollView?.delegate = self
        cell.imgView!.image = nil
        cell.activityIndicatorView?.startAnimating()
        LCPHOTO.requestImageForAsset(photoAssets![indexPath.row].asset!, resizeMode: .None, size:PHImageManagerMaximumSize) { (image) in
            cell.activityIndicatorView?.stopAnimating()
            cell.imgView!.image = image
            let W = image.size.width / 2
            let H = image.size.height / 2
            let SW = cell.scrollView!.frame.width
            let SH = cell.scrollView!.frame.height
            var fitW: CGFloat = SW
            var fitH: CGFloat = SW / W * H
            if fitH > SH {
                fitW = SH / H * W
                fitH = SH
            }
            cell.imgView!.frame.size = CGSizeMake(fitW, fitH)
            cell.imgView!.center = cell.scrollView!.center
            
        }
        // 单击
        cell.oneBlock = { (scrollView: UIScrollView) in
            UIView.animateWithDuration(0.25, animations: {
                self.navigationController?.navigationBarHidden = !(self.navigationController?.navigationBarHidden)!
            })
        }
        // 双击
        cell.twoBlock = { (scrollView: UIScrollView) in
            UIView.animateWithDuration(0.25, animations: {
                if scrollView.zoomScale > 1 {
                    scrollView.zoomScale = 1
                }else {
                    scrollView.zoomScale = LCPHOTO.maxZoomScale
                }
            })
        }
        return cell
    }
    
}

extension LCPhotoBigViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        if scrollView.tag != 999 {
            let view = scrollView.subviews[0]
            // y
            if view.frame.height < scrollView.frame.height {
                view.frame.origin.y = (scrollView.frame.height - view.frame.height) / 2
            }else {
                view.frame.origin.y = 0
            }
            
            // x
            if view.frame.width < scrollView.frame.width {
                view.frame.origin.x = (scrollView.frame.width - view.frame.width) / 2
            }else {
                view.frame.origin.x = 0
            }
            
        }
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if scrollView.tag != 999 {
            if scale == 1 {
                view!.center = scrollView.center
            }
        }
    }
}

class LCPhotoBigCell: UICollectionViewCell {
    weak var imgView: UIImageView?
    weak var scrollView: UIScrollView?
    weak var activityIndicatorView: UIActivityIndicatorView?
    var oneBlock: ((scrollView: UIScrollView) -> Void)?
    var twoBlock: ((scrollView: UIScrollView) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let scrool = UIScrollView()
        scrool.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        scrool.maximumZoomScale = LCPHOTO.maxZoomScale
        scrool.minimumZoomScale = 1
        scrool.showsVerticalScrollIndicator = false
        scrool.showsHorizontalScrollIndicator = false
        scrool.backgroundColor = UIColor.blackColor()
        self.addSubview(scrool)
        self.scrollView = scrool
        let imageView = UIImageView()
        imageView.frame = CGRectMake(0, 0, scrool.frame.width, scrool.frame.height)
        imageView.contentMode = .ScaleAspectFit
        imageView.userInteractionEnabled = true
        
        imageView.backgroundColor = UIColor.blackColor()
        scrool.addSubview(imageView)
        let oneTap = UITapGestureRecognizer.init(target: self, action: #selector(self.one(_:)))
        scrool.addGestureRecognizer(oneTap)
        let twoTap = UITapGestureRecognizer.init(target: self, action: #selector(self.two(_:)))
        twoTap.numberOfTapsRequired = 2
        scrool.addGestureRecognizer(twoTap)
        // 区分单击和双击
        oneTap.requireGestureRecognizerToFail(twoTap)
        
        self.imgView = imageView
        
        let actView =  UIActivityIndicatorView()
        actView.frame = self.bounds
        actView.activityIndicatorViewStyle = .WhiteLarge
        self.addSubview(actView)
        actView.startAnimating()
        self.activityIndicatorView = actView
        
    }
    func one(tap: UITapGestureRecognizer) {
        let scrool = tap.view as! UIScrollView
        oneBlock!(scrollView: scrool)
    }
    func two(tap: UITapGestureRecognizer) {
        let scrool = tap.view as! UIScrollView
        twoBlock!(scrollView: scrool)
    }
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}


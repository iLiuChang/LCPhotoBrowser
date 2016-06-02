//
//  LCPhotoAssetViewController.swift
//  LCPhotoBrowser
//
//  Created by 刘畅 on 16/5/31.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit
import Photos

class LCPhotoAssetViewController: UIViewController {

    var maxNumber: Int?
    var assetCollection: PHAssetCollection?
    var photoAssets: Array<LCPhotoAsset>!
    var finishBlock: ((photos: Array<LCPhotoAsset>) -> Void)?
    let assetCell = "assetCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        photoAssets = []
        super.viewDidLoad()
        let assets = LCPHOTO.getAllAssetsInAssetCollection(assetCollection!, ascending: false)
        self.initCollectionView()
        for i in 0 ..< assets.count {
            let photo = LCPhotoAsset()
            photo.selected = false
            photo.asset = assets[i]
            photoAssets.append(photo)
        }
        
        let right = UIBarButtonItem.init(title: "完成", style: UIBarButtonItemStyle.Plain, target:self , action: #selector(self.finish))
        self.navigationItem.rightBarButtonItem = right
    }

    func initCollectionView() {
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = CGSizeMake((self.view.frame.width-9)/4, (self.view.frame.width-9)/4);
        flow.minimumInteritemSpacing = 1.5;
        flow.minimumLineSpacing = 1.5;
        flow.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
        let collectionView = UICollectionView.init(frame: self.view.bounds ,collectionViewLayout: flow)
        collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(LCPhotoAssetCell.self, forCellWithReuseIdentifier: assetCell)
    }
    
    func finish() {
        finishBlock!(photos: photoAssets)
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LCPhotoAssetViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //        let asset = assets[indexPath.row]
        let vc = LCPhotoBigViewController()
        vc.maxNumber = maxNumber
        //        vc.assets = self.photoAssets
        vc.indexPath_Row = indexPath.row
        vc.photoAssets = self.photoAssets
        vc.photoBlock = { (photoLists: Array<LCPhotoAsset>) in
            self.photoAssets = photoLists
            collectionView.reloadData()
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
}

extension LCPhotoAssetViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoAssets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(assetCell, forIndexPath: indexPath) as! LCPhotoAssetCell
        cell.backgroundColor = UIColor.whiteColor()
        photoAssets[indexPath.row].indexPath = indexPath
        cell.config(photoAssets[indexPath.row])
        LCPHOTO.requestImageForAsset(photoAssets[indexPath.row].asset!, resizeMode: .Exact, size: CGSizeMake(cell.frame.width * 4, cell.frame.height * 4)) { (image) in
            cell.assetImageView?.image = image
        }
        
        cell.actionBlock = { (button: UIButton, result: Bool, indexPath: NSIndexPath) in
            if button.selected == false {
                var count = 0
                for photoList in self.photoAssets! {
                    if photoList.selected == true {
                        count += 1
                    }
                }
                if count > self.maxNumber! - 1 && self.photoAssets![indexPath.row].selected == false {
                    let alert = UIAlertController.init(title: "不能超过\(self.maxNumber!)张", message: "", preferredStyle: .Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                    let action = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    })
                    alert.addAction(action)
                    return
                }
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
            self.photoAssets[indexPath.row].selected = button.selected
            
        }
        
        return cell
    }
}

class LCPhotoAssetCell: UICollectionViewCell {
    weak  var assetImageView: UIImageView?
    weak var assetBtn: UIButton?
    private weak var selectedBtn: UIButton?
    private var photoAsset: LCPhotoAsset!
    var actionBlock: ((button: UIButton, result: Bool, indexPath: NSIndexPath) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let  assetImageView = UIImageView(frame: self.bounds)
        assetImageView.contentMode = .ScaleAspectFill
        assetImageView.clipsToBounds = true
        assetImageView.userInteractionEnabled = true
        self.addSubview(assetImageView)
        assetImageView.backgroundColor = UIColor.purpleColor()
        self.assetImageView = assetImageView
        
        let button = UIButton(type: .Custom)
        let buttonW: CGFloat = 20
        button.frame = CGRectMake(assetImageView.frame.maxX - buttonW, 0, buttonW, buttonW)
        button.setBackgroundImage(UIImage(named: "btn_unselected"), forState: .Normal)
        button.setBackgroundImage(UIImage(named: "btn_selected"), forState: .Selected)
        button.addTarget(self, action: #selector(self.click(_:)), forControlEvents: .TouchUpInside)
        assetImageView.addSubview(button)
        self.assetBtn = button
    }
    
    func click(button: UIButton) {
        if actionBlock != nil {
            actionBlock!(button: button, result: button.selected, indexPath: photoAsset.indexPath!)
        }
    }
    
    func config(photoList: LCPhotoAsset) {
        self.photoAsset = photoList
        self.assetBtn?.selected = photoList.selected!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

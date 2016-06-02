//
//  LCPhotoBrowser.swift
//  LCPhotoBrowser
//
//  Created by 刘畅 on 16/5/31.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit
import Photos
class LCPhotoBrowser: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 选择照片的最大数，默认9张
    var maxNumber: Int = 9
    private var lc_finishBlock: ((images: Array<UIImage>) -> Void)?
    
    /**
     获取图片
     
     - parameter currentController: 当前所在的控制器
     - parameter completionHandler: images 返回相册图片或者拍照图片
     */
    func lc_showAlert(currentController: UIViewController, didSelectedFinished completionHandler: (images: Array<UIImage>) -> Void) {
        lc_finishBlock = completionHandler
        let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .ActionSheet)
        // 拍照
        let actionCamera = UIAlertAction.init(title: "拍照", style: .Default) { (action: UIAlertAction) in
            alertVC.dismissViewControllerAnimated(true, completion: nil)
            if !self.judgeIsHaveCameraAuthority() {
                return
            }
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.videoQuality = .TypeLow
                picker.sourceType = .Camera
                currentController.presentViewController(picker, animated: true, completion: nil)
            }
            
        }
        // 相册
        let actionPhoto = UIAlertAction.init(title: "相册", style: .Default) { (action: UIAlertAction) in
            alertVC.dismissViewControllerAnimated(true, completion: nil)
            if !self.judgeIsHavePhotoAblumAuthority() {
                LCPHOTO.showAlert(currentController, title: "无法访问相册，请在设置中打开访问权限")
                return
            }
            
            let vc = LCPhotoListViewController()
            vc.maxNumber = self.maxNumber
            vc.finishBlock = { (photos: Array<LCPhotoAsset>) in
                var images: Array<UIImage> = []
                for photo in  photos {
                    if photo.selected == true  {
                        LCPHOTO.requestImageForAsset(photo.asset!, resizeMode: .Exact, size: PHImageManagerMaximumSize) { (image) in
                            images.append(image)
                            completionHandler(images: images)
                        }
                    }
                }
            }
            currentController.navigationController?.pushViewController(vc, animated: true)
            
        }
        // 取消
        let actionCancel = UIAlertAction.init(title: "取消", style: .Cancel) { (action: UIAlertAction) in
            alertVC.dismissViewControllerAnimated(true, completion: nil)
        }
        alertVC.addAction(actionCamera)
        alertVC.addAction(actionPhoto)
        alertVC.addAction(actionCancel)
        currentController.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    // 拍照
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { [weak self] in
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            if self!.lc_finishBlock != nil {
                self!.lc_finishBlock!(images: [image])
            }
        }
    }
    
    
    // 相册访问
    private func judgeIsHavePhotoAblumAuthority() -> Bool {
        let  status = PHPhotoLibrary.authorizationStatus()
        
        if (status == .Restricted || status == .Denied) {
            return false
        }
        return true
    }
    
    // 相机是否能使用
    private func judgeIsHaveCameraAuthority() -> Bool {
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if status == .Restricted || status == .Denied  {
            return false
        }
        return true
    }
}

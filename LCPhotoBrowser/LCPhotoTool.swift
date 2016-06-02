//
//  LCPhotoTool.swift
//  LCPhotoBrowser
//
//  Created by 刘畅 on 16/5/31.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit
import Photos

let LCPHOTO = LCPhotoTool.sharePhotoTool as LCPhotoTool
class LCPhotoTool: NSObject {
    
    // 图片缩放的最大倍数
    var maxZoomScale: CGFloat = 3
    private static let instance: LCPhotoTool = LCPhotoTool()
    class var sharePhotoTool: LCPhotoTool {
        return instance
    }
   
    func getPhotoAblumList() -> Array<LCPhotoAblumList> {
        var photoAblumList = Array<LCPhotoAblumList>()
        
        // 获取智能相册
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .AlbumRegular, options: nil)
        smartAlbums.enumerateObjectsUsingBlock { (anyobject: AnyObject, inx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            let collection = anyobject as! PHAssetCollection
            if collection.localizedTitle != "Recently Deleted" && collection.localizedTitle != "Videos" {
                let assets = self.getAllAssetsInAssetCollection(collection, ascending: false)
                if assets.count > 0 {
                    let ablum = LCPhotoAblumList()
                    ablum.count = assets.count
                    //                    ablum.title = self.transformAblumTitle(collection.localizedTitle!)
                    ablum.title = collection.localizedTitle!
                    ablum.headImageAssect = assets.first
                    ablum.assetCollection = collection
                    photoAblumList.append(ablum)
                }
            }
        }
        
        // 获取用户创建的相册
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .SmartAlbumUserLibrary, options: nil)
        userAlbums.enumerateObjectsUsingBlock { (anyobject: AnyObject, inx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            let collection = anyobject as! PHAssetCollection
            let assets = self.getAllAssetsInAssetCollection(collection, ascending: false)
            if assets.count > 0 {
                let ablum = LCPhotoAblumList()
                ablum.count = assets.count
                ablum.title = collection.localizedTitle
                ablum.headImageAssect = assets.first
                ablum.assetCollection = collection
                photoAblumList.append(ablum)
            }
        }
        
        return photoAblumList
    }
    
    // 获取指定相册内的所有图片
    func getAllAssetsInAssetCollection(assetCollection: PHAssetCollection, ascending: Bool) -> Array<PHAsset> {
        var arr = Array<PHAsset>()
        let result = fetchAssetsInAssetCollection(assetCollection, ascending: false)
        result.enumerateObjectsUsingBlock { (anyobject: AnyObject, inx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            let asset = anyobject as! PHAsset
            if asset.mediaType == PHAssetMediaType.Image {
                arr.append(asset)
            }
        }
        return arr
    }
    
    
    /**
     获取asset对应的图片

     - parameter asset:             PHAsset
     - parameter resizeMode:        None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸
     - parameter size:              想要的图片尺寸，原尺寸:PHImageManagerMaximumSize
     - parameter completionHandler: image
     */
    func requestImageForAsset(asset: PHAsset,resizeMode: PHImageRequestOptionsResizeMode,size: CGSize, completionHandler: ((image: UIImage)-> Void)) {
        let option = PHImageRequestOptions()
        option.resizeMode = resizeMode
        option.networkAccessAllowed = true
        /*
         option.deliveryMode
         Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。注意: 这个属性只有在 synchronous 为 true 时有效
         */
        PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: .AspectFit, options: option) { (image: UIImage?, info: [NSObject : AnyObject]?) in
            if image != nil {
                completionHandler(image: image!)
            }
        }
    }
    
    // 排序
    func fetchAssetsInAssetCollection(assetCollection: PHAssetCollection, ascending: Bool) -> PHFetchResult {
        let option = PHFetchOptions()
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
        let result = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: option)
        return result
    }
    
    func showAlert(currentController: UIViewController, title: String) {
        let alertVC = UIAlertController.init(title: title, message: "", preferredStyle: .Alert)
        currentController.presentViewController(alertVC, animated: true, completion: nil)
        let sureAction = UIAlertAction.init(title: "确定", style: .Default) { (action: UIAlertAction) in
            alertVC.dismissViewControllerAnimated(true, completion: nil)
        }
        alertVC.addAction(sureAction)
    }
    
    func showAlert(currentController: UIViewController, title: String, completionHandler: ((result: Bool) -> Void)) {
        let alertVC = UIAlertController.init(title: title, message: "", preferredStyle: .Alert)
        currentController.presentViewController(alertVC, animated: true, completion: nil)
        let sureAction = UIAlertAction.init(title: "确定", style: .Default) { (action: UIAlertAction) in
            alertVC.dismissViewControllerAnimated(true, completion: {
                completionHandler(result: true)
            })
            
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: .Default) { (action: UIAlertAction) in
            alertVC.dismissViewControllerAnimated(true, completion: {
                completionHandler(result: false)
            })
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(sureAction)
    }
}

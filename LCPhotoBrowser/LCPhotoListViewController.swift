//
//  LCPhotoListViewController.swift
//  LCPhotoBrowser
//
//  Created by 刘畅 on 16/5/31.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit
import Photos

class LCPhotoListViewController: UIViewController {
    var photoAblumLists: Array<LCPhotoAblumList>!
    var finishBlock: (( photos: Array<LCPhotoAsset>) -> Void)?
    var maxNumber: Int?
    
    let listCell = "listCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        photoAblumLists = LCPHOTO.getPhotoAblumList()
        initTableView()

    }
    
    func initTableView() {
        let tableView = UITableView()
        tableView.frame = self.view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
       
        tableView.registerClass(LCPhotoListCell.self, forCellReuseIdentifier: listCell)

     
        if PHPhotoLibrary.authorizationStatus() == .NotDetermined {
           
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) in
                if status == .Authorized {
                    self.photoAblumLists = LCPHOTO.getPhotoAblumList()
                    tableView.reloadData()
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LCPhotoListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ablum = photoAblumLists[indexPath.row]
        let vc = LCPhotoAssetViewController()
        vc.maxNumber = maxNumber
        vc.assetCollection = ablum.assetCollection
        vc.finishBlock = self.finishBlock
        self.navigationController?.pushViewController(vc, animated: true)
    }
  
}
extension LCPhotoListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoAblumLists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(listCell) as! LCPhotoListCell
        let ablum = photoAblumLists[indexPath.row]
        cell.ablumList = ablum
        return cell
    }
}

class LCPhotoListCell: UITableViewCell {
    private var headImageView: UIImageView!
    private var titleLabel: UILabel!
    private var countLabel: UILabel!
    var ablumList: LCPhotoAblumList? {
        willSet(ablum) {
            self.titleLabel.text = ablum?.title
            LCPHOTO.requestImageForAsset((ablum?.headImageAssect)!, resizeMode: .Fast, size: headImageView.frame.size) { (image) in
                self.headImageView.image = image
            }
            self.countLabel.text = NSString(format: "(%ld)",(ablum?.count)!) as String
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    func initViews() {
        let H: CGFloat = 60
        headImageView = UIImageView(frame: CGRectMake(10, 3, H - 6, H - 6))
        self.contentView.addSubview(headImageView)
        titleLabel = UILabel(frame: CGRectMake(headImageView.frame.maxX + 10, 3, 100, H - 6))
        self.contentView.addSubview(titleLabel)
        countLabel = UILabel(frame: CGRectMake(titleLabel.frame.maxX + 10, 3, 100, H - 6))
        self.contentView.addSubview(countLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

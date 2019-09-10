//
//  CCAdressPickerZone.swift
//  Adrress
//
//  Created by sunlantao on 2019/9/4.
//  Copyright © 2019 sunlantao. All rights reserved.
//

import UIKit

class CCAddressPickerZone: UIView , UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.collectionView)
    }
    
    deinit {
         self.provider?.removeObserver(self, forKeyPath: "currentLevel")
     }
     
     weak var provider : CCAddressProvider?{
         didSet{
             self.provider?.addObserver(self, forKeyPath: "currentLevel", options: .new, context: nil)
         }
     }
     
    //MARK: Collection
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        var cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.register(CCAddressPickerZoneCell.classForCoder(), forCellWithReuseIdentifier: "zone")
        return cv
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.provider?.numberOfLevels() ?? 0
    }
    
    func reloadFrom(_ index:Int){
        if index >= self.collectionView.numberOfItems(inSection: 0){
            self.collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
        }else{
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "zone", for: indexPath) as! CCAddressPickerZoneCell
        cell.provider = provider
        cell.level = indexPath.row
       
        let obj = (provider?.levelSelected(indexPath.row))!
        weak var wCell = cell
        provider?.fetchAddrresBy(obj, level: cell.level, picker: { (a) in
            wCell?.list = a
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = self.bounds
    }
    func scrollToIndex(_ index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.collectionView .scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
        self.provider?.currentLevel = index
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentLevel"{
            self.scrollToIndex(self.provider?.currentLevel ?? 0)
        }
    }
}

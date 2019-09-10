//
//  CCAddressPickerNavigation.swift
//  Adrress
//
//  Created by sunlantao on 2019/9/4.
//  Copyright © 2019 sunlantao. All rights reserved.
//

import UIKit

class CCAddressPickerNavigationCell: UICollectionViewCell {
    
    var titleLabel:UILabel!
    
    required init?(coder: NSCoder) {
               fatalError("init(coder:) has not been implemented")
        }
         
       override init(frame: CGRect) {
           super.init(frame: frame)
          
          titleLabel = UILabel()
          titleLabel.text = "选择"
          titleLabel.textColor = UIColor.black
          titleLabel.textAlignment = .center
          titleLabel.font = UIFont.systemFont(ofSize: 14)
          
          self.addSubview(titleLabel)
          
       }
    override var isSelected: Bool{
        didSet{
            if (self.isSelected){
                self.titleLabel.textColor = UIColor.red
            }else{
                self.titleLabel.textColor = UIColor.black
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = self.bounds
    }
}

class CCAddressPickerNavigation: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    lazy var indicator:UIView = {
        let indicator = UIView()
        indicator.backgroundColor = .red
        indicator.frame = CGRect(x: 0, y: 0, width: 20, height: 4)
        indicator.layer.cornerRadius = 2
        indicator.layer.zPosition = 10
        return indicator
    }()

   required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.collectionView)
        self.collectionView.addSubview(self.indicator)
    }
    
    deinit {
        self.provider?.removeObserver(self, forKeyPath: "currentLevel")
    }
    
    weak var provider : CCAddressProvider?{
        didSet{
            self.provider?.addObserver(self, forKeyPath: "currentLevel", options: [.new, .old], context: nil)
        }
    }
    
    //MARK: Collection
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .horizontal
        
        var cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.dataSource = self
        cv.delegate = self
        cv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        cv.register(CCAddressPickerNavigationCell.classForCoder(), forCellWithReuseIdentifier: "apNavigation")
        cv.showsHorizontalScrollIndicator = false
        
        return cv
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.provider?.numberOfLevels() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "apNavigation", for: indexPath) as! CCAddressPickerNavigationCell
        let c = self.provider?.levelSelected(indexPath.row)
        cell.titleLabel.text = c?.name
        
        cell.isSelected = indexPath.row == self.provider?.currentLevel
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.provider?.currentLevel{
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.indicator.center = CGPoint(x: cell.frame.midX, y: self.bounds.height - self.indicator.bounds.height/2)
            }) { (c) in
                
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let c = self.provider?.levelSelected(indexPath.row)
        let name : String! = c?.name!
        let size = (name as NSString).boundingRect(with: CGSize(width: 100, height: 999), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14)], context: nil).size

        return CGSize(width: size.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.provider?.currentLevel = indexPath.row
    }
    func changeIndex(_ index : Int) {
        let indexPath = IndexPath(row: index, section: 0)
        for c in collectionView.visibleCells{
            c.isSelected = false
        }
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected = true
        
        guard cell != nil else {return}
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.indicator.center = CGPoint(x: cell?.frame.midX ?? 0, y: self.bounds.height - self.indicator.bounds.height/2)
        }) { (c) in
            
        }
    }
    
    override func layoutSubviews() {
          super.layoutSubviews()
          self.collectionView.frame = self.bounds
      }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentLevel"{
            self.changeIndex(self.provider?.currentLevel ?? 0)
        }
    }
   
  
}

//
//  CCAddressPickerZoneCell.swift
//  Adrress
//
//  Created by sunlantao on 2019/9/4.
//  Copyright © 2019 sunlantao. All rights reserved.
//

import UIKit


class CCAddressCell: UICollectionViewCell {
    
    var titleLabel:UILabel!
    
    required init?(coder: NSCoder) {
               fatalError("init(coder:) has not been implemented")
        }
         
       override init(frame: CGRect) {
           super.init(frame: frame)
          
          titleLabel = UILabel()
          titleLabel.text = "北京"
          titleLabel.textColor = UIColor.black
//          titleLabel.textAlignment = .center
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
        self.titleLabel.frame = CGRect(x: 20, y: 0, width: self.bounds.size.width - 40, height: self.bounds.size.height)
    }
}
class CCAddressPickerZoneCell: UICollectionViewCell , UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    weak var provider : CCAddressProvider?
    
    var __list:[CCAddressObject]?
    var list:[CCAddressObject]?{
        didSet{
            self.collectionView.reloadData()
        }
    }
    var level:Int = 0
  
  required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.collectionView)
    }
    

    //MARK: Collection
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 20
        
        var cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.dataSource = self
        cv.delegate = self
        cv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        cv.register(CCAddressCell.classForCoder(), forCellWithReuseIdentifier: "apNavigation")
        return cv
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "apNavigation", for: indexPath) as! CCAddressCell
        cell.titleLabel.text = list?[indexPath.row].name
        
        let c = self.provider?.levelSelected(self.level)
        
        cell.isSelected = cell.titleLabel.text == c?.name
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        for c in collectionView.visibleCells{
            if (c.isSelected){
                if (c == cell){
                    c.isSelected = true
                }else{
                    c.isSelected = false;
                }
            }
        }
        provider?.updateLevel(self.level, address: list?[indexPath.row] ?? CCAddressObject())
    }
    
    
    override func layoutSubviews() {
          super.layoutSubviews()
          self.collectionView.frame = self.bounds
      }
}

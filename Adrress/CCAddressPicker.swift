//
//  CCAddressPicker.swift
//  Adrress
//
//  Created by sunlantao on 2019/9/4.
//  Copyright © 2019 sunlantao. All rights reserved.
//

import UIKit

class CCAddressPicker: UIView {
    
    static func picker(_ source:UIView) -> CCAddressPicker{
       let picker = CCAddressPicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
       picker.source = source
        return picker
    }

     lazy var navigaton : CCAddressPickerNavigation = {
         let navigation = CCAddressPickerNavigation()
//        navigation.backgroundColor = UIColor.brown
        navigation.provider = self.provider

          return navigation
      }()
     
     lazy var zone : CCAddressPickerZone = {
        let zone = CCAddressPickerZone()
        zone.provider = self.provider
        return zone
    }()
    
    lazy var separator : UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return separator
    }()
    lazy var contentView : UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .white
        return contentView
    }()
    
    lazy var cancelBtn:UIButton = {
        var btn = UIButton();
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        
        btn.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
        
        return btn
    }()
    
    var provider = CCAddressProvider()
    var pickOver:AddressPickOver?{
        didSet{
            self.provider.pickOver = self.pickOver
        }
    }
    
    weak var source:UIView?{
        didSet{
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.zPosition = 999
        self.addSubview(self.contentView)
        
        self.contentView.addSubview(self.navigaton)
        self.contentView.addSubview(self.cancelBtn)
        self.contentView.addSubview(self.zone)
        self.contentView.addSubview(self.separator)
        
        self.provider.addressUpdateBlock = {level in
            self.navigaton.collectionView.reloadData()
        }
        self.provider.addressInsertBlock = {level in
            self.zone.reloadFrom(level)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChanged(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChanged(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    var maskGView : UIView = {
                   let contentView = UIView()
        contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        contentView.alpha = 0;
        contentView.frame = UIScreen.main.bounds
                    return contentView
                }()
    
    
    @objc
    func keyboardWillChanged(_ notification: Notification){
        
  
        let peripheralHostView = UIApplication.shared.windows.last?.subviews.last
        var InputSetHostView:UIView?
        let b = peripheralHostView?.isKind(of: NSClassFromString("UIInputSetContainerView")!) ?? false
        if b && (peripheralHostView != nil){
            for view in peripheralHostView!.subviews{
                if view.isKind(of: NSClassFromString("UIInputSetHostView")!){
                    InputSetHostView = view
                }
            }
        }
        if InputSetHostView != nil{
            if notification.name == UIResponder.keyboardWillHideNotification{
                UIView.animate(withDuration: 0.3, animations: {
                    self.maskGView.alpha = 0
                }) { (b) in
                    self.maskGView.removeFromSuperview()
                }
                
                InputSetHostView?.subviews.first?.alpha = 1
            }else{
                self.source?.superview?.addSubview(self.maskGView)
                UIView.animate(withDuration: 0.3) {
                    self.maskGView.alpha = 1.0
                }
                InputSetHostView?.subviews.first?.alpha = 0
            }
        }
        
    }
    
    override func layoutSubviews() {
        
        self.contentView.frame = self.bounds
        
        self.navigaton.frame = CGRect(x: 0, y: 0, width: self.bounds.width - 60, height: 50)
        self.cancelBtn.frame = CGRect(x: self.navigaton.frame.maxX + 10, y: 0, width: 40, height: 50)
        self.separator.frame = CGRect(x: 0, y: self.navigaton.frame.maxY, width: self.bounds.size.width, height: 0.5)
        self.zone.frame = CGRect(x: 0, y: self.separator.frame.maxY, width: self.contentView.bounds.width, height: self.contentView.bounds.height - self.separator.frame.maxY)
    }

    @objc
    func cancel(_ sender: Any?) {
        self.source?.resignFirstResponder()
    }
  
}

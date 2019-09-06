//
//  CCAddressProvider.swift
//  Adrress
//
//  Created by sunlantao on 2019/9/4.
//  Copyright © 2019 sunlantao. All rights reserved.
//

import UIKit

typealias AddressUpdateBlock = (Int)->Void
typealias AddressPickOver = ([CCAddressObject])->Void

struct CCAddressObject : Equatable {
    var name:String? = "请选择"//名称
    var code:String? = "0"//代码
    var superCode:String? = "0"//上级代码
   
    init(_ name:String? = "请选择", code:String? = "", superCode:String? = "") {
        self.name = name
        self.code = code
        self.superCode = superCode
    }
    static func == (lhs: Self, rhs: Self) -> Bool{
        return lhs.name == rhs.name && lhs.code == rhs.code && lhs.superCode == rhs.superCode
    }
}

class CCAddressProvider: NSObject {
    var maxlevel = 3
    var selectedAddress:[Int:CCAddressObject] = [:]
    var selectedAddressUpdate:AddressUpdateBlock?
    var pickOver:AddressPickOver?

    @objc dynamic var currentLevel:Int = 0

    override init() {
        super.init()
        
        self.push(0)
    }
    
    func push(_ level: Int) {
        if level > 0{
            let p = self.levelSelected(level - 1)
            selectedAddress[level] = CCAddressObject("请选择", code: "0", superCode: p.code)
        }else{
            selectedAddress[level] = CCAddressObject("请选择", code: "0", superCode: "0")
        }
    }
    func updateLevel(_ level:Int, address:CCAddressObject){

        for index in level...selectedAddress.count{
            selectedAddress.removeValue(forKey: index)
        }
        
        selectedAddress[level] = address
        if level + 1 < maxlevel{
            self.push(level+1)
        }
        selectedAddressUpdate?(level)
        
        if (level + 1 < maxlevel){
            self.currentLevel = level + 1
        }else{
            self.currentLevel = level
            
            var arr = [CCAddressObject]()
            for l in 0...level{
                let o = self.selectedAddress[l]
                arr.append(o!)
            }
            pickOver?(arr)
        }
        
    }
    func levelSelected(_ level:Int) -> CCAddressObject {
        return selectedAddress[level] ?? CCAddressObject()
    }
    
    func numberOfLevels() -> Int {
        return selectedAddress.count
    }
    
    func fetchAddrresBy(_ object:CCAddressObject) -> [CCAddressObject] {
        let addresss = [
            CCAddressObject("北京", code: "1", superCode: "0"),
            CCAddressObject("上海", code: "1", superCode: "0"),
            CCAddressObject("天津", code: "1", superCode: "0"),
            CCAddressObject("重庆", code: "1", superCode: "0"),
            CCAddressObject("河北省", code: "1", superCode: "0"),
            CCAddressObject("黑龙江", code: "1", superCode: "0"),
            CCAddressObject("吉林省", code: "1", superCode: "0"),
            CCAddressObject("河南省", code: "1", superCode: "0"),
            CCAddressObject("湖南省", code: "1", superCode: "0"),
            CCAddressObject("湖北省", code: "1", superCode: "0"),
            CCAddressObject("浙江省", code: "1", superCode: "0"),
            CCAddressObject("江苏省", code: "1", superCode: "0"),
            
            CCAddressObject("昌平", code: "2", superCode: "1"),
            CCAddressObject("海淀", code: "2", superCode: "1"),
        
            CCAddressObject("闽兴", code: "3", superCode: "2"),
            CCAddressObject("外滩", code: "3", superCode: "2"),
            CCAddressObject("a", code: "3", superCode: "2"),
            CCAddressObject("b", code: "3", superCode: "2"),
        
            CCAddressObject("c", code: "3", superCode: "2"),
            CCAddressObject("d", code: "3", superCode: "2"),
        
            CCAddressObject("e", code: "3", superCode: "2"),
            CCAddressObject("f", code: "3", superCode: "2"),
        
            CCAddressObject("g", code: "3", superCode: "2"),
            CCAddressObject("h", code: "3", superCode: "2")]
        
        return addresss.filter { (obj) -> Bool in
            return obj.superCode == object.superCode
        }
    }
}

//
//  CCAddressProvider.swift
//  Adrress
//
//  Created by sunlantao on 2019/9/4.
//  Copyright © 2019 sunlantao. All rights reserved.
//

import UIKit

typealias AddressUpdateBlock = (Int)->Void
typealias AddressInsertBlock = (Int)->Void

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
    var maxlevel = 4
    var selectedAddress:[Int:CCAddressObject] = [:]
    
    var addressUpdateBlock:AddressUpdateBlock?
    var addressInsertBlock:AddressInsertBlock?
//    var addressDeleteBlock:AddressInsertBlock?

    var pickOver:AddressPickOver?

    @objc dynamic var currentLevel:Int = 0

    deinit {
        SQManger.shareInstence().close()
    }
    override init() {
        super.init()
        
        if SQManger.shareInstence().openDB(){
            print("开始")
        }
        
        self.push(0)
    }
    
    func push(_ level: Int) {
        if level > 0{
            let p = self.levelSelected(level - 1)
            selectedAddress[level] = CCAddressObject("请选择", code: "0", superCode: p.code)
        }else{
            selectedAddress[level] = CCAddressObject("请选择", code: "0", superCode: "0")
        }
        self.addressInsertBlock?(level)
    }
    func updateLevel(_ level:Int, address:CCAddressObject){

        for index in level...selectedAddress.count{
            selectedAddress.removeValue(forKey: index)
        }
        
        selectedAddress[level] = address
        if level + 1 < maxlevel{
            self.push(level+1)
        }
        addressUpdateBlock?(level)
        
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
    
    func fetchAddrresBy(_ object:CCAddressObject, level:Int, picker:AddressPickOver?){
        picker?(address(object, level:level))
    }
    
}

extension CCAddressProvider{
    func address(_ object:CCAddressObject, level : Int) -> [CCAddressObject] {
        if level == 0{
            let sql = "SELECT PROVINCE_NAME, PROVINCE_CODE,PROVINCE_CODE FROM bs_province"
            let arr = SQManger.shareInstence().querySql(sql: sql)
            return arr as! [CCAddressObject]
        }else if level == 1{
            let sql = "SELECT CITY_NAME, CITY_CODE,PROVINCE_CODE FROM bs_city where PROVINCE_CODE =" + object.superCode!
            let arr = SQManger.shareInstence().querySql(sql: sql)
            return arr as! [CCAddressObject]
        }else if level == 2{
            let sql = "SELECT AREA_NAME, AREA_CODE,CITY_CODE FROM bs_area where CITY_CODE =" + object.superCode!
            let arr = SQManger.shareInstence().querySql(sql: sql)
            return arr as! [CCAddressObject]
        }else if level == 3{
            let sql = "SELECT STREET_NAME,STREET_CODE, AREA_CODE FROM bs_street where AREA_CODE =" + object.superCode!
            let arr = SQManger.shareInstence().querySql(sql: sql)
            return arr as! [CCAddressObject]
        }
        return []
       }
}

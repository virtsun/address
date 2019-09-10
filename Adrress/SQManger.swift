//
//  DBManager.swift
//  Adrress
//
//  Created by sunlantao on 2019/9/10.
//  Copyright © 2019 sunlantao. All rights reserved.
//

import UIKit
import SQLite3

class SQManger: NSObject {
    var db:OpaquePointer? = nil
    static let instance = SQManger()
    
    class func shareInstence() -> SQManger {
        return instance
    }
    func close(){
        sqlite3_close(self.db)
    }
    func openDB() -> Bool {
        let file = Bundle.main.path(forResource: "address", ofType: "db")

        if file == nil {return false}
    
        let cfile = file?.cString(using: String.Encoding.utf8)
        let state = sqlite3_open(cfile,&db)
        if state != SQLITE_OK{
            print("打开数据库失败")
            return false
        }
        return true
    }


    func execSql(sql:String) -> Bool {
        let csql = sql.cString(using: String.Encoding.utf8)
        return sqlite3_exec(db, csql, nil, nil, nil) == SQLITE_OK
    }

    func updataData(sql:String) -> Bool {
        let csql = (sql.cString(using: String.Encoding.utf8))!
        if sqlite3_exec(db,csql, nil, nil, nil) != SQLITE_OK {
            return false
        }
        return true
    }

    
    func querySql(sql:String) -> [Any]? {
        var stmt:OpaquePointer? = nil
        let csql = (sql.cString(using: String.Encoding.utf8))!
   
        let prepare_result = sqlite3_prepare_v2(self.db, csql, -1, &stmt, nil)

        //判断如果失败，获取失败信息
        if prepare_result != SQLITE_OK {
            sqlite3_finalize(stmt)
            if (sqlite3_errmsg(self.db)) != nil {
                let msg = "SQLiteDB - failed to prepare SQL:\(sql)"
                print(msg)
            }
            return nil
        }
    //准备好
        var tempArr = [Any]()
    
        while sqlite3_step(stmt) == SQLITE_ROW {
      
            let name = String.init(cString: sqlite3_column_text(stmt, 0)!)
            let code = String.init(cString: sqlite3_column_text(stmt, 1)!)
            let superCode = String.init(cString: sqlite3_column_text(stmt, 2)!)

            let model = CCAddressObject(name, code: code, superCode: superCode)
            tempArr.append(model)
        }
        return tempArr
    }
}

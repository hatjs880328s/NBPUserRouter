//
//  FMDatabaseQueuePublicUtils
//  FMDatabaseQueuePublicUtils
//
//  Created by Noah_Shan on 2018/3/24.
//  Copyright © 2018年 Inspur. All rights reserved.
//

import UIKit

class FMDatabaseQueuePublicUtils: NSObject {
    
    static var queueDB:FMDatabaseQueue!
    static var dbname = "InspurInterAOPNBPManager.sqlite"
    static var dbIns: FMDatabase!
    
    class func InitTheDb()->Bool{
        if queueDB != nil && dbIns != nil { return true}
        if(queueDB == nil || dbIns == nil){
            do {
                let pathNew = try FileManager.default.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(dbname)
                queueDB = FMDatabaseQueue(url: pathNew)
                dbIns = FMDatabase(url: pathNew)
                dbIns.open()
                return true
            }catch{
                return false
            }
        }
        return true
    }
    
    /// use safety thread QUEUE & progress sql with transcation  :) - if fail rollback
    class func executeUpdate(sql: String){
        if !InitTheDb() { return }
        queueDB.inTransaction { (db, rollback) in
            do {
                for eachItem in sql.components(separatedBy: ";") {
                    if eachItem.isEmpty {continue}
                    try db.executeUpdate(eachItem, values: nil)
                }
            }catch{
                rollback.pointee = true
            }
        }
    }
    
    class func executeSingleSQL(sql: String) {
        if !InitTheDb() { return }
        do {
            try dbIns.executeUpdate(sql, values: nil)
        }catch {
            // donothing...
        }
    }
    
    /// execute query  then return Array result like 'select * from xxx where ?'
    class func getResultWithSql(sql: String)->NSMutableArray {
        let resultLast = NSMutableArray()
        if !InitTheDb() { return resultLast }
        
        queueDB.inDatabase({ (db) in
            do {
                let resultSet = try db.executeQuery(sql, values: nil)
                let count = resultSet.columnCount
                while (resultSet.next()) {
                    let dic  = NSMutableDictionary()
                    for i in 0  ..< Int(count)  {
                        var columnName:NSString!
                        columnName = resultSet.columnName(for: Int32(i))! as NSString
                        let obj: AnyObject! = resultSet.object(forColumn: columnName as String) as AnyObject?
                        dic.setObject(obj, forKey: columnName)
                    }
                    resultLast.add(dic)
                }
            } catch {}
        })
        return resultLast
    }
    
}


//
//  ObjEvent.swift
//
//  Created by Javed Multani 
//  Copyright (c) . All rights reserved.
//

import Foundation

class ObjEvent : NSObject, NSCoding {
    var title: String?
    var disc: String?
    var time: Int64?
    var id: String?

    required init(title: String, disc: String, time: Int64, id: String) {
        self.title = title
        self.disc = disc
        self.time = time
        self.id = id
    }

    required public init(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as? String
        self.disc = aDecoder.decodeObject(forKey: "disc") as? String
        self.time = aDecoder.decodeObject(forKey: "time") as? Int64
        self.id = aDecoder.decodeObject(forKey: "id") as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(disc, forKey: "disc")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(id, forKey: "id")
    }

}

class ArchiveUtil {
    
    private static let EventKey = "EventKey"
    
    private static func archiveEvent(event : [ObjEvent]) -> NSData {
        
        return NSKeyedArchiver.archivedData(withRootObject: event as NSArray) as NSData
    }
    
    static func loadEvent() -> [ObjEvent]? {
        
        if let unarchivedObject = UserDefaults.standard.object(forKey: EventKey) as? Data {
            
            return NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject as Data) as? [ObjEvent]
        }
        
        return nil
    }
    
    static func saveEvent(event : [ObjEvent]?) {
        
        let archivedObject = archiveEvent(event: event!)
        UserDefaults.standard.set(archivedObject, forKey: EventKey)
        UserDefaults.standard.synchronize()
    }
    
}


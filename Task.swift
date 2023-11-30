//
//  Task.swift
//  taskapp
//
//  Created by 丸山万綾 on 2023/11/09.
//

import RealmSwift

class Task: Object{
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var title = ""
    
    @Persisted var contents = ""
    
    @Persisted var category = ""
    
    @Persisted var date = Date()
    
}

import Foundation

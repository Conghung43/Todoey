//
//  Item.swift
//  Todoey
//
//  Created by Admin on 1/30/18.
//  Copyright © 2018 Kai. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}

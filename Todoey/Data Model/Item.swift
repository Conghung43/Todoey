//
//  Item.swift
//  Todoey
//
//  Created by Admin on 1/19/18.
//  Copyright © 2018 Kai. All rights reserved.
//

import Foundation

class Item : Encodable, Decodable {
    var title : String = ""
    var done : Bool = false
}


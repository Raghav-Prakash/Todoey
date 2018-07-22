//
//  Item.swift
//  Todoey
//
//  Created by Raghav Prakash on 7/20/18.
//  Copyright © 2018 Raghav Prakash. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
	
	// Attributes
	@objc dynamic var itemTitle : String = ""
	@objc dynamic var done : Bool = false
	@objc dynamic var dateCreated : Date?
	
	// Relationship (backward -> to-one)
	var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}

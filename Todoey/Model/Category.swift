//
//  Category.swift
//  Todoey
//
//  Created by Raghav Prakash on 7/20/18.
//  Copyright © 2018 Raghav Prakash. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
	
	// Attributes
	@objc dynamic var name : String = ""
	@objc dynamic var backgroundHexColor : String = ""
	
	// Relationship (forward -> to-many)
	var items = List<Item>()
}

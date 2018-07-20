//
//  ViewController.swift
//  Todoey
//
//  Created by Raghav Prakash on 7/18/18.
//  Copyright © 2018 Raghav Prakash. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
	
	var itemArray = [Item]()
	let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// Load the initial items from the items.plist file
		loadItems()
	}
	
	//MARK - Model manipulation functions
	
	func setItem(item: String) {
		let newItem = Item()
		
		newItem.itemTitle = item
		newItem.done = false
		
		itemArray.append(newItem)
	}
	
	func saveItems() {
		let encoder = PropertyListEncoder()
		do {
			let plist = try encoder.encode(itemArray)
			try plist.write(to: filePath!)
		} catch {
			print("Error in ecoding: \(error)")
		}
		
		tableView.reloadData()
	}
	
	func loadItems() {
		do {
			let data = try Data(contentsOf: filePath!)
			
			let decoder = PropertyListDecoder()
			itemArray = try decoder.decode([Item].self, from: data)
		} catch {
			print("Error in decoding: \(error)")
		}
	}
	
	//MARK - TableView DataSource methods
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
		
		let item = itemArray[indexPath.row]
		cell.textLabel?.text = item.itemTitle
		cell.accessoryType = item.done ? .checkmark : .none
		
		return cell
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemArray.count
	}
	
	//MARK - TableView Delegate methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		itemArray[indexPath.row].done = !(itemArray[indexPath.row].done)
		saveItems()
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	//MARK - Add new To-Do item

	@IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
		
		let alert = UIAlertController(title: "Add New To-Do Item", message: "", preferredStyle: .alert)
		
		var textField = UITextField()
		alert.addTextField { (alertTextField) in
			alertTextField.placeholder = "What's the item"
			textField = alertTextField
		}
		let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
			// Add item to array
			if let itemTitle = textField.text {
				self.setItem(item: itemTitle)
				self.saveItems()
			}
		}
		alert.addAction(action)
		
		present(alert, animated: true, completion: nil)
	}
}


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
	
	// For persistant local storage (items should be available even after app termination and relaunch)
	let defaults = UserDefaults.standard

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// Set initial to-do list items
		setItem(item: "Shop for groceries")
		setItem(item: "Mow the lawn")
		setItem(item: "Take out trash")
		
		// When app view gets loaded, load in the saved data in user defaults
		if let data = defaults.array(forKey: "ToDoItemsArray") as? [Item] {
			itemArray = data
		}
	}
	
	func setItem(item: String) {
		let newItem = Item()
		
		newItem.itemTitle = item
		newItem.done = false
		
		itemArray.append(newItem)
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
		tableView.reloadData()
		
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
				self.tableView.reloadData()
				
				self.defaults.set(self.itemArray, forKey: "ToDoItemsArray")
			}
		}
		alert.addAction(action)
		
		present(alert, animated: true, completion: nil)
	}
}


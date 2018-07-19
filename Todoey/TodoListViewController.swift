//
//  ViewController.swift
//  Todoey
//
//  Created by Raghav Prakash on 7/18/18.
//  Copyright © 2018 Raghav Prakash. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
	
	var itemArray = ["Shop for groceries","Take out trash","Cook dinner"]
	
	// For persistant local storage (items should be available even after app termination and relaunch)
	let defaults = UserDefaults()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// When app view gets loaded, load in the saved data in user defaults
		if let items = defaults.value(forKey: "ToDoItemsArray") as? [String] {
			itemArray = items
		}
	}
	
	//MARK - TableView DataSource methods
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
		cell.textLabel?.text = itemArray[indexPath.row]
		
		return cell
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemArray.count
	}
	
	//MARK - TableView Delegate methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if(tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark) {
			tableView.cellForRow(at: indexPath)?.accessoryType = .none
		} else {
			tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
		}
		
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
			if let item = textField.text {
				print("Item \(item) added")
				
				self.itemArray.append(item)
				self.tableView.reloadData()
				
				self.defaults.set(self.itemArray, forKey: "ToDoItemsArray")
			}
		}
		alert.addAction(action)
		
		present(alert, animated: true, completion: nil)
	}
}


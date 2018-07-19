//
//  ViewController.swift
//  Todoey
//
//  Created by Raghav Prakash on 7/18/18.
//  Copyright © 2018 Raghav Prakash. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
	
	var itemArray = ["Do the groceries","Take out trash","Cook dinner"]

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
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
			}
		}
		alert.addAction(action)
		
		present(alert, animated: true, completion: nil)
	}
}


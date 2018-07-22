//
//  ViewController.swift
//  Todoey
//
//  Created by Raghav Prakash on 7/18/18.
//  Copyright © 2018 Raghav Prakash. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
	
	let realm = try! Realm()
	var toDoItems : Results<Item>?
	
	var selectedCategory : Category? {
		didSet {
			loadItems()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	//MARK: - Model manipulation functions
	
	func saveItem(item: String) {
		if let currentCategory = selectedCategory {
			do {
				try realm.write {
					let newItem = Item()
					newItem.itemTitle = item
					newItem.dateCreated = Date()
					
					currentCategory.items.append(newItem)
				}
			} catch {
				print("Error in writing item: \(error)")
			}
		}
		tableView.reloadData()
	}
	
	func loadItems() {
		toDoItems = selectedCategory?.items.sorted(byKeyPath: "itemTitle", ascending: true)
		tableView.reloadData()
	}
	
	//MARK: - TableView DataSource methods
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
		
		if let item = toDoItems?[indexPath.row] {
			cell.textLabel?.text = item.itemTitle
			cell.accessoryType = item.done ? .checkmark : .none
		} else {
			cell.textLabel?.text = ""
		}
		
		return cell
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return toDoItems?.count ?? 0
	}
	
	//MARK: - TableView Delegate methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if let item = toDoItems?[indexPath.row] {
			do {
				try realm.write {
					item.done = !item.done
				}
			} catch {
				print("Error in updating item (done): \(error)")
			}
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
		tableView.reloadData()
	}
	
	//MARK: - Add new To-Do item

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
				self.saveItem(item: itemTitle)
			}
		}
		alert.addAction(action)
		
		present(alert, animated: true, completion: nil)
	}
}

//MARK: - Search Bar Delegate methods

extension TodoListViewController: UISearchBarDelegate {

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		toDoItems = toDoItems?.filter("itemTitle CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
		tableView.reloadData()
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.count == 0 {
			loadItems()

			DispatchQueue.main.async {
				searchBar.resignFirstResponder()
			}
		}
	}
}


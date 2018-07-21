//
//  ViewController.swift
//  Todoey
//
//  Created by Raghav Prakash on 7/18/18.
//  Copyright © 2018 Raghav Prakash. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
	
	var itemArray = [Item]()
	var selectedCategory : Category? {
		didSet {
			loadItems()
		}
	}
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	//MARK: - Model manipulation functions
	
	func setItem(item: String) {
		let newItem = Item(context: context)
		
		newItem.itemTitle = item
		newItem.done = false
		newItem.parentCategory = selectedCategory
		
		itemArray.append(newItem)
	}
	
	func saveItems() {
		do {
			try context.save()
		} catch {
			print("Error in saving Core Data context: \(error)")
		}
		
		tableView.reloadData()
	}
	
	func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
		let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory?.name)!)
		
		if let searchPredicate = predicate {
			request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,searchPredicate])
		} else {
			request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate])
		}
		
		do {
			itemArray = try context.fetch(request)
		} catch {
			print("Error in reading data: \(error)")
		}
		
		tableView.reloadData()
	}
	
	//MARK: - TableView DataSource methods
	
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
	
	//MARK: - TableView Delegate methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		itemArray[indexPath.row].done = !(itemArray[indexPath.row].done)
		
		context.delete(itemArray[indexPath.row])
		itemArray.remove(at: indexPath.row)
		
		saveItems()
		
		tableView.deselectRow(at: indexPath, animated: true)
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
				self.setItem(item: itemTitle)
				self.saveItems()
			}
		}
		alert.addAction(action)
		
		present(alert, animated: true, completion: nil)
	}
}

//MARK: - Search Bar Delegate methods

extension TodoListViewController: UISearchBarDelegate {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		
		let request : NSFetchRequest<Item> = Item.fetchRequest()
		
		if let searchText = searchBar.text {
			let predicate = NSPredicate(format: "itemTitle CONTAINS[cd] %@", searchText)
			request.sortDescriptors = [NSSortDescriptor(key: "itemTitle", ascending: true)]
			
			loadItems(with: request, predicate: predicate)
		}
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

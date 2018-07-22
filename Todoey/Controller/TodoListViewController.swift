//
//  ViewController.swift
//  Todoey
//
//  Created by Raghav Prakash on 7/18/18.
//  Copyright © 2018 Raghav Prakash. All rights reserved.
//

import UIKit

import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	let realm = try! Realm()
	var toDoItems : Results<Item>?
	var categoryBackgroundHexColor : String = ""
	
	var selectedCategory : Category? {
		didSet {
			loadItems()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// Adjust the cell height for easier swiping
		tableView.rowHeight = 80.0
		
		// Remove separator lines in tableView
		tableView.separatorStyle = .none
		
		// Set the barTint color for the searchBar to be the background color of the category
		searchBar.barTintColor = HexColor(categoryBackgroundHexColor)
		
		// Set the placeholder for the searchBar to search for the selected category
		searchBar.placeholder = "Search an item of \(selectedCategory?.name ?? "this category")"
	}
	override func viewWillAppear(_ animated: Bool) {
		title = selectedCategory?.name ?? "Items"
		
		guard let categoryBackgroundHexColor = selectedCategory?.backgroundHexColor else {fatalError("No background hex color set for selected category")}
		setResetNavBarColor(withHexCode: categoryBackgroundHexColor)
	}
	override func viewWillDisappear(_ animated: Bool) {
		setResetNavBarColor(withHexCode: "1D9BF6")
	}
	
	//MARK: - Set and/or reset navBar color properties
	func setResetNavBarColor(withHexCode colorCode: String) {
		
		guard let navBar = navigationController?.navigationBar else {fatalError("Can't access navigation controller")}
		guard let navBarColor = HexColor(colorCode) else {fatalError("Can't get UIColor from category's hexColor")}
		
		navBar.barTintColor = navBarColor
		navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
		navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
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
		categoryBackgroundHexColor = selectedCategory?.backgroundHexColor ?? UIColor.randomFlat.hexValue()
		
		tableView.reloadData()
	}
	
	//MARK: - Delete item
	
	override func deleteCell(at indexPath: IndexPath) {
		let itemDeleted = self.toDoItems?[indexPath.row] ?? nil
		if let item = itemDeleted {
			do {
				try self.realm.write {
					self.realm.delete(item)
				}
			} catch {
				print("Error in deleting item: \(error)")
			}
		}
	}
	
	//MARK: - TableView DataSource methods
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		
		if let item = toDoItems?[indexPath.row] {
			cell.textLabel?.text = item.itemTitle
			cell.accessoryType = item.done ? .checkmark : .none
			
			let categoryColor = HexColor(categoryBackgroundHexColor)
			cell.backgroundColor = categoryColor?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(toDoItems!.count))
			
			cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
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


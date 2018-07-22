//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Raghav Prakash on 7/20/18.
//  Copyright © 2018 Raghav Prakash. All rights reserved.
//

import UIKit

import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
	
	let realm = try! Realm()
	var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Load initial categories from the database
		loadCategories()
		
		// Adjust height of tableViewCell to accomodate SwipeCell image dimension
		tableView.rowHeight = 80.0
		
		// Remove separator lines in tableView
		tableView.separatorStyle = .none
    }
	
	//MARK: - Data manipulation methods
	
	func setCategory(name: String) {
		let category = Category()
		
		category.name = name
		category.backgroundHexColor = UIColor.randomFlat.hexValue()
		
		save(category: category)
		tableView.reloadData()
	}
	
	func loadCategories() {
		categories = realm.objects(Category.self)
		tableView.reloadData()
	}
	func save(category : Category) {
		
		do {
			try realm.write {
				realm.add(category)
			}
		} catch {
			print("Error in saving category to Core Data Database: \(error)")
		}
		
		tableView.reloadData()
	}
	
	//MARK: - Delete category
	
	override func deleteCell(at indexPath: IndexPath) {
		let categoryDeleted = self.categories?[indexPath.row] ?? nil
		if let category = categoryDeleted {
			do {
				try self.realm.write {
					self.realm.delete(category)
				}
			} catch {
				print("Error in deleting category: \(error)")
			}
		}
	}
	
	//MARK: - TableView DataSource methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories?.count ?? 0
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		
		let category = categories?[indexPath.row] ?? nil
		cell.textLabel?.text = category?.name ?? ""
		
		cell.backgroundColor = HexColor((category?.backgroundHexColor)!) ?? UIColor.white
		cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
		
		return cell
	}
	
	//MARK:- TableView Delegate methods
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "goToItems", sender: self)
	}
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationVC = segue.destination as! TodoListViewController
		
		destinationVC.selectedCategory = categories?[(tableView.indexPathForSelectedRow?.row)!]
	}
	
	//MARK:- Add new category
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		
		let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
		
		var textField = UITextField()
		alert.addTextField { (alertTextField) in
			alertTextField.placeholder = "What's the category"
			textField = alertTextField
		}
		
		let action = UIAlertAction(title: "Add category", style: .default) { (addAction) in
			if let categoryText = textField.text {
				self.setCategory(name: categoryText)
			}
		}
		alert.addAction(action)
		
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(cancel)
		
		present(alert, animated: true, completion: nil)
	}
}

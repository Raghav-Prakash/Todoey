//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Raghav Prakash on 7/20/18.
//  Copyright © 2018 Raghav Prakash. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
	
	let realm = try! Realm()
	var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		print(Realm.Configuration.defaultConfiguration.fileURL!)
		
		// Load initial categories from the database
		loadCategories()
    }
	
	//MARK: - Data manipulation methods
	
	func setCategory(name: String) {
		let category = Category()
		
		category.name = name
		
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
	
	//MARK: - TableView DataSource methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories?.count ?? 0
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
		
		let category = categories?[indexPath.row] ?? nil
		cell.textLabel?.text = category?.name ?? ""
		
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
		
		present(alert, animated: true, completion: nil)
	}
	
}

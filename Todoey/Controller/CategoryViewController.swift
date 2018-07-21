//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Raghav Prakash on 7/20/18.
//  Copyright © 2018 Raghav Prakash. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
	
	var categoryArray = [Category]()
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Load initial categories from the database
		loadCategories()
    }
	
	//MARK: - Data manipulation methods
	
	func setCategory(name: String) {
		let category = Category(context: context)
		
		category.name = name
		categoryArray.append(category)
		
		tableView.reloadData()
	}
	
	func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
		do {
			categoryArray = try context.fetch(request)
		} catch {
			print("Error in loading categories from database: \(error)")
		}
		
		tableView.reloadData()
	}
	func saveCategory() {
		
		do {
			try context.save()
		} catch {
			print("Error in saving category to Core Data Database: \(error)")
		}
		
		tableView.reloadData()
	}
	
	//MARK: - TableView DataSource methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categoryArray.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
		
		let category = categoryArray[indexPath.row]
		cell.textLabel?.text = category.name
		
		return cell
	}
	
	//MARK:- TableView Delegate methods
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "goToItems", sender: self)
	}
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationVC = segue.destination as! TodoListViewController
		
		destinationVC.selectedCategory = categoryArray[(tableView.indexPathForSelectedRow?.row)!]
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
				self.saveCategory()
			}
		}
		alert.addAction(action)
		
		present(alert, animated: true, completion: nil)
	}
	
}

//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Admin on 1/27/18.
//  Copyright © 2018 Kai. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeViewController {

    let realm = try! Realm()
    
    var categories : Results<Category>?
    
   // var categoryArray = [Category]()
    
    // let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
   // let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadCategory()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }

    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
//        cell.delegate = self
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
        
        cell.textLabel?.text = category.name // ?? " no category added yet"
        
      //  let color = categories?[indexPath.row].colour
        
        cell.backgroundColor = UIColor(hexString: category.colour )// ?? "1D9BF6" )
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        }
        
       // cell.delegate = self
        
        // cell.accessoryType = category.done ? .checkmark : .none
        
        return cell
    
    }
    
    
    //MARK: - TableView delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "Segue", sender: self)
 
       // tableView.deselectRow(at: indexPath, animated: true)
        print("indexPath la \(indexPath)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodolistViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
            print("indexPath.row o ham prepare for segue \(indexPath.row)")
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // What will happen once the user clicks the Add Item
            
            // let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let newCategory = Category()
            
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat.hexValue()
            
            
      //      self.categories.append(newCategory)
            
            self.save(category: newCategory)
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
            
            
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
        
    }
        
    
    
    
    func save(category : Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("error saving category \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategory()
    {
        categories = realm.objects(Category.self)

        tableView.reloadData()
    }
    //MARK: - Delete data from swipe
    
    override func updateMode(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {

            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("error delete category \(error)")
            }
            //  tableView.reloadData()
        }
    }
    
}

//MARK: - Swipe Cell Delegate Methods


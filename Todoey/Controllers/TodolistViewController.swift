//
//  ViewController.swift
//  Todoey
//
//  Created by Admin on 1/18/18.
//  Copyright © 2018 Kai. All rights reserved.
//

import UIKit
import RealmSwift

class TodolistViewController: UITableViewController {

    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadItem()
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
       loadItem()
    }

    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = todoItems?[indexPath.row].title
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        
        return cell
    }

    //MARK - Tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
        do {
            try realm.write {
                item.done = !item.done
            }
        }
            catch {
                print("Error saving done status , \(error)")
        }
        
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK - Add New Items
    @IBAction func addButtonPress(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
         
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.done = false
                    currentCategory.items.append(newItem)
                }
                } catch {
                 print("error saving category \(error)")
            }
        }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
            
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
        
    }
//    func save(item : Item) {
//
//        do {
//            try realm.write {
//                realm.add(item)
//            }
//        } catch {
//            print("error saving category \(error)")
//        }
//
//        self.tableView.reloadData()
//    }
//
    func loadItem()
    {
         todoItems = realm.objects(Item.self)
        
        tableView.reloadData()
    }

//}
//MARK: - Search bar methods
//extension TodolistViewController : UISearchBarDelegate {
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//        
//        let predicate = NSPredicate(format: "title CONTAINS[CD] %@", searchBar.text!)
//        
//        
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        
//        loadItem(with: request, predicate: predicate)
//        
//    }
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            loadItem()
//            DispatchQueue.main.async {                  // show the keyboard when we click in or dismiss
//                searchBar.resignFirstResponder()
//            }
//            
//        }
//    }
}

//
//  ViewController.swift
//  Todoey
//
//  Created by Admin on 1/18/18.
//  Copyright © 2018 Kai. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodolistViewController: SwipeViewController {

    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadItem()
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        print("vi tri can xem viewdidload")
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
       //loadItem()
        tableView.rowHeight = 80
    }

    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("vi tri can xem numberofrow ")
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("vi tri can xem cellforrow \(indexPath)")
       let cell = super.tableView(tableView, cellForRowAt: indexPath)
       
      //  cell.textLabel?.text = todoItems?[indexPath.row].title
        
        if let item = todoItems?[indexPath.row] {
           // print("vi tri can xem \(item)")
           // print("vi tri can xem \(indexPath.row)")
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat((todoItems?.count)!)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }

        return cell
    }

    //MARK - Tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("vi tri can xem didselecrow \(indexPath)")
        if let item = todoItems?[indexPath.row] {
        do {
            try realm.write {
                item.done = !item.done
               // realm.delete(item)
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
                    newItem.dateCreated = Date()
                    //newItem.colour = UIColor.randomFlat.hexValue()
                    currentCategory.items.append(newItem)
                        print("add xong ")
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

    func loadItem()
    {
         todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)            //realm.objects(Item.self)
        //print("trong loadItem - todolist")
        tableView.reloadData()
        
    }
    override func updateMode(at indexPath: IndexPath) {
        if let todoItemsForDeletion = self.todoItems?[indexPath.row] {
            print("vi tri can xem updatemode \(indexPath)")
            do {
                try self.realm.write {
                    self.realm.delete(todoItemsForDeletion)
                }
            } catch {
                print("error delete todolist \(error)")
            }
            //  tableView.reloadData()
        }
    }
}
//}
//MARK: - Search bar methods
extension TodolistViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItem()
            DispatchQueue.main.async {                  // show the keyboard when we click in or dismiss
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}

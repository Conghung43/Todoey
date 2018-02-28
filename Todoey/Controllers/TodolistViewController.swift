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

    @IBOutlet weak var searchBar: UISearchBar!
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
       //loadItem()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError(" Navigation control does not exist ")
        }
        guard let colourHex = selectedCategory?.colour else { fatalError()}
            
            title = selectedCategory?.name
            
        
        guard let navBarColour = UIColor(hexString: colourHex) else { fatalError() }
            
            navBar.barTintColor = navBarColour
            
            navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true )]
            
            navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
            
            searchBar.barTintColor = UIColor(hexString: colourHex)
        
        
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        guard let originalColour = UIColor(hexString: "1D9BF6") else { fatalError()}
        navigationController?.navigationBar.barTintColor = originalColour
        
        navigationController?.navigationBar.tintColor = FlatWhite()
        
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: FlatWhite()]
        
    }
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
       let cell = super.tableView(tableView, cellForRowAt: indexPath)
       
      //  cell.textLabel?.text = todoItems?[indexPath.row].title
        
        if let item = todoItems?[indexPath.row] {

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

        tableView.reloadData()
        
    }
    override func updateMode(at indexPath: IndexPath) {
        if let todoItemsForDeletion = self.todoItems?[indexPath.row] {

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
            DispatchQueue.main.async {                  // show the keyboard when click or dismiss
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}

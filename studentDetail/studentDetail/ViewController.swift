//
//  ViewController.swift
//  studentDetail
//
//  Created by Droadmin on 6/26/23.

import UIKit
import SQLite3

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,passData,UISearchBarDelegate, UISearchResultsUpdating{
    func updateData() {
        readData()
         tableView.reloadData()
        imageCache.removeAllObjects()
        
    }
    
    func fatchData() {
        
         readData()
        
        tableView.reloadData()
        
        
    }
    
    var sectionDic:[String: [fatchData]] = [:]
    var searching = false
    var searchingName: [fatchData] = []
    var data: [fatchData] = []
    var studentName = [String]()
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    let dbManager = DBManager()
    let searchController = UISearchController()
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "List"
        
        tableView.delegate = self
        tableView.dataSource = self
        readData()

       
        configureSerachController()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         indexing()
    }
    func indexing(){
       // studentName = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        studentName = Array(Set(data.map({String($0.name.prefix(1))})))
        studentName.sort()

        for item1 in studentName {
            sectionDic[item1] = []
        }
        for item2 in data {
            if let firstLetter = item2.name.first {
                let value = String(firstLetter)
                sectionDic[value]?.append(item2)
            }
        }


        tableView.reloadData()
    }
    
   func configureSerachController(){
        //searchController.loadViewIfNeeded() //jab tak aap loadViewIfNeeded() method ko call karte hain, tab tak view load nahi hota. Lekin agar view pehle se hi load ho chuka hai, toh yeh method kuch nahi karta.

        searchController.searchResultsUpdater = self  // Set the delegate for handling search results updates.
        searchController.searchBar.delegate = self  // Set the delegate for handling search bar-related events.
        searchController.obscuresBackgroundDuringPresentation = false//background property ko dark nahi kiya ja sakata
        //searchController.searchBar.enablesReturnKeyAutomatically = false
        //searchController.searchBar.returnKeyType = UIReturnKeyType.done
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        //definesPresentationContext = true
        searchController.searchBar.placeholder = "Search Student Name"
    }
    
    @IBAction func addData(_ sender: Any) {
        let fillData = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController")as! SecondViewController
        fillData.delegate = self
        self.navigationController?.pushViewController(fillData, animated: true)
    }
    
    
    func readData()  {
      
        data.removeAll()
        
        let query = "SELECT * FROM student"
        
        self.dbManager.createDatabase()
        
        var statement: OpaquePointer? // SQLite Query execute karne ke liye istmal hota hai
        
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            // sqlite3_step function ek row ko fetch karne ke liye istemal hota hai.
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let username = String(cString: sqlite3_column_text(statement, 2))
                let mobilNo = String(cString: sqlite3_column_text(statement, 3))
                let email = String(cString: sqlite3_column_text(statement, 4))
                let password = String(cString: sqlite3_column_text(statement, 5))
                let edu = String(cString: sqlite3_column_text(statement, 6))
                let dob = String(cString: sqlite3_column_text(statement, 7))
               
                let gender = String(cString: sqlite3_column_text(statement, 9))
                let hobbies = String(cString: sqlite3_column_text(statement, 10))
                
               
               
                
                if let Pointer = sqlite3_column_blob(statement, 8){
                    let Size = sqlite3_column_bytes(statement, 8)// image data ka size fatch karake size variable me store kar dena
                    let image = Data(bytes: Pointer , count: Int(Size))// mili hui image ko data me convert karne ke liye use hua he
                    if let image = UIImage(data: image){
                        let student = studentDetail.fatchData(name: name, mobileno: mobilNo, image: image, id: id, username: username, dob: dob,edu: edu, password: password,gender: gender,hobbies: hobbies, email: email)
                        data.append(student)
                        
                        print("Fetched data - Name: \(name), Mobile No: \(mobilNo), Image: \(image),gender \(gender), hobbies \(hobbies),\(username),\(password),\(dob),\(edu)")
                    }
                }else{
                    print("not fatch image")
                }
                
            }
            sqlite3_finalize(statement)
            
        } else {
            print("Failed to prepare query")
        }
             
       
    }
    func deleteData(data: fatchData){
        let deleteQuery = "DELETE FROM student WHERE id = ?"
        dbManager.createDatabase()
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, deleteQuery, -1, &statement, nil) == SQLITE_OK{
            sqlite3_bind_int(statement, 1, Int32(data.id))
            if sqlite3_step(statement) == SQLITE_DONE{//SQLITE_DONE returen karse
                print("deleted successfully")
                imageCache.removeObject(forKey: data.id as AnyObject)

                indexing()
                fatchData()
         
                tableView.reloadData()
            }else{
                print("failed to delete")
            }
        }else{
            print("failed")
        }
        sqlite3_finalize(statement)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if searching
        {
            return 1
        }else{
          return studentName.count 
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching
        {
            return searchingName.count
        }else{
           
           return sectionDic[studentName[section]]?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath) as! MyTableViewCell
        let rowData: fatchData
                if searching {
                    rowData = searchingName[indexPath.row]
                } else {
                    rowData = (sectionDic[studentName[indexPath.section]]?[indexPath.row])!
                }

      
                cell.nameLbl.text = rowData.name
                cell.mobilLbl.text = rowData.mobileno
                //cell.selectImage.layer.cornerRadius = 25
                //cell.selectImage.clipsToBounds = true
                cell.selectImage.image = nil

                if let imageFromCache = imageCache.object(forKey: rowData.id as AnyObject) as? UIImage {
                    cell.selectImage.image = imageFromCache
                } else {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        if tableView.indexPath(for: cell) != nil {
                            if let imageToCache = rowData.image {
                                self.imageCache.setObject(imageToCache, forKey: rowData.id as AnyObject)
                                cell.selectImage.image = imageToCache
                                //cell.setNeedsLayout()
                            }
                        }
                    }
                }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let select: fatchData
        if searching{
             select = searchingName[indexPath.row]
        }else{
            select = (sectionDic[self.studentName[indexPath.section]]?[indexPath.row])!
        }
        
        let fillData = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController")as! SecondViewController
        fillData.selectedData = select
        fillData.delegate = self
        self.navigationController?.pushViewController(fillData, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            var selectedData: fatchData
                    if self.searching {
                        selectedData = self.searchingName[indexPath.row]
                    } else {
                        selectedData = (self.sectionDic[self.studentName[indexPath.section]]?[indexPath.row])!
                    }
            self.deleteData(data: selectedData)
            if self.searching {
                       self.searchingName.remove(at: indexPath.row)
                   } else {
                       self.sectionDic[self.studentName[indexPath.section]]?.remove(at: indexPath.row)
                   }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
            
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false // thoda swipe karane ke liye
        return configuration
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
            if let searchText = searchController.searchBar.text {
                if searchText.isEmpty {
                    searching = false
                    
                    
                } else {
                    searching = true
                    searchingName = data.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                }
                tableView.reloadData()
            }
        }
   
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
      
        fatchData()
        indexing()
        
        tableView.reloadData()
    }
    
   
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searching{
            return nil
        }else{
            return studentName
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searching{
            return nil
        }else{
            return studentName[section]
        }
    }
    
    
}




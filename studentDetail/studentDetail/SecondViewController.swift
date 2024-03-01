//
//  SecondViewController.swift
//  studentDetail
//
//  Created by Droadmin on 6/26/23.
//

import UIKit
import SQLite3
protocol passData:NSObjectProtocol{
    
    func fatchData()
    func updateData()
   
}

class SecondViewController: UIViewController {
    let eyeBtn = UIButton()
    //var selectedEdu: String?
    var selectedData: fatchData?// variable 6e pan fatchData ek custom datatype 6e je struct na object ne represent kare 6e.
    var aducation = ["SC", "HSC", "Bachelor", "Master"]
    var datePicker = UIDatePicker()
    var pickerView = UIPickerView()
    var dbManager = DBManager()
    weak var delegate: passData?// weak keyword na use thi property ne optional or mutable decalre karvu pade
    //optinal na karavu hoy to unknown keyword no use thay
    @IBOutlet weak var ImageSelect: UIImageView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var VolleyballBtn: UIButton!
    @IBOutlet weak var swimmingBtn: UIButton!
    @IBOutlet weak var footballBtn: UIButton!
    @IBOutlet weak var chessBtn: UIButton!
    @IBOutlet weak var cricketBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var EmailTxt: UITextField!
    @IBOutlet weak var educationTxt: UITextField!
    @IBOutlet weak var RecetPwd: UITextField!
    @IBOutlet weak var dobTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var MobileTxt: UITextField!
    @IBOutlet weak var userNameTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        dbManager.createDatabase()
        dbManager.createTable()
       
        createDatePicker()
        pickerView.delegate = self
        pickerView.dataSource = self
        MyPickerView()
        hidePsw()
        self.title = "Add"
        nameTxt.text = selectedData?.name
        MobileTxt.text = selectedData?.mobileno
        userNameTxt.text = selectedData?.username
        EmailTxt.text = selectedData?.email
        dobTxt.text = selectedData?.dob
        passwordTxt.text = selectedData?.password
        RecetPwd.text = selectedData?.password
        educationTxt.text = selectedData?.edu
        if let imageData = selectedData?.image{
            if let convertedImage = imageData.jpegData(compressionQuality: 1.0){
                ImageSelect.image = UIImage(data: convertedImage)
            }
        }
        if let gender = selectedData?.gender{
            if gender == "Male"{
                maleBtn.isSelected = true
                femaleBtn.isSelected = false
            }else if gender == "Female"{
                maleBtn.isSelected = false
                femaleBtn.isSelected = true
            }else{
                print("not select any gender")
            }
        }
        if let hobbies = selectedData?.hobbies {
            //let hobbiesArray = hobbies.components(separatedBy: ",")
            cricketBtn.isSelected = hobbies.contains("Cricket")
            chessBtn.isSelected = hobbies.contains("Chess")
            footballBtn.isSelected = hobbies.contains("Football")
            VolleyballBtn.isSelected = hobbies.contains("Volleyball")
            swimmingBtn.isSelected = hobbies.contains("Swimming")
        }

      }
    func hidePsw(){
        eyeBtn.setImage(UIImage(named: "hide"), for: .normal)
        eyeBtn.setImage(UIImage(named: "view"), for: .selected)
        eyeBtn.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        passwordTxt.rightView = eyeBtn
        passwordTxt.rightViewMode = .always//(jo ki ek UITextField hai) ke right side mein jo bhi view hai (yaani koi button, icon, ya kuch aur) wo hamesha (always) dikhaya jaega, chahe usme koi text ho ya na ho.
        eyeBtn.alpha = 0.4 // 0 thi 1 ni vachare hoy
       
    }
    @objc func togglePasswordView(){
        passwordTxt.isSecureTextEntry.toggle() // true hoy to false kare ane false hoy to true kare
        eyeBtn.isSelected = !passwordTxt.isSecureTextEntry
    }
    
    @IBAction func checkBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
    }
    
    
    @IBAction func radioBtn(_ sender: UIButton) {
        if sender == maleBtn{
            maleBtn.isSelected = true
            femaleBtn.isSelected = false
        }else{
            maleBtn.isSelected = false
            femaleBtn.isSelected = true
        }
    }
    
    
    func MyPickerView(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()// contents ke size ke hisab se apne frame ko adjust karle
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        self.educationTxt.inputAccessoryView = toolbar //  jab bhi educationTxt text field focus ho jata hai (user usme tap karta hai ya kuch aur), toh toolbar view automatic tarike se uske neeche show ho jaega.
        self.educationTxt.inputView = pickerView//educationTxt (jo ek UITextField hai) ke input view (yani ki keyboard) ki jagah par pickerView show kiya jayega.
        
        
    }
//    @objc func donAction(){
//
//        self.view.endEditing(true)//uiview ma game tya keybord par tap karso to keybord hide thay jase
//        let selectedRow = pickerView.selectedRow(inComponent: 0)
//           educationTxt.text = aducation[selectedRow]
//
//    }
    
    
    
    func createDatePicker() {
    
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
    toolbar.setItems([doneBtn], animated: true)
    dobTxt.inputAccessoryView = toolbar
    dobTxt.inputView = datePicker
    datePicker.datePickerMode = .date
   
    if #available(iOS 13.2, *) {
        datePicker.preferredDatePickerStyle = .inline // Wheels,Compact
        }

}
    @objc func donePressed()
    {
        if dobTxt.isFirstResponder{
            let formater = DateFormatter()
            // formater.dateFormat = "MM/dd/yyyy"
            formater.dateStyle = .medium
            //formater.timeStyle = .none
            dobTxt.text = formater.string(from: datePicker.date)
            self.view.endEditing(true)
        }else if educationTxt.isFirstResponder{
            self.view.endEditing(true)//uiview ma game tya keybord par tap karso to keybord hide thay jase
            let selectedRow = pickerView.selectedRow(inComponent: 0)
               educationTxt.text = aducation[selectedRow]
        }
    }
    func dobValidatiobn() -> Bool {
        let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "MM/dd/yyyy"
        if dateFormatter.date(from: dobTxt.text ?? "") != nil {
               return true
           } else {
               return false
           }
        
    }
    
    func validateEmail() -> Bool {
        
        let emailCondition = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailCondition)
        return emailPredicate.evaluate(with: EmailTxt.text)
    }
    
    func showAlert(with title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    

    @IBAction func SubmitBtn(_ sender: Any) {
        let strMessage = self.nameTxt.text?.count == 0 ? "Please enter name" : userNameTxt.text?.count == 0 ? "Please enter username" : MobileTxt.text?.count != 10 ? "Please enter valid Mobile number" : !self.validateEmail() ? "Please enter valid email id" : self.passwordTxt.text?.count == 0 ? "please enter valid password": self.RecetPwd.text?.count == 0 ? "please enter valid password": !self.dobValidatiobn() ? "please enter valid date" : self.educationTxt.text?.count == 0 ? "please enter education" : self.passwordTxt.text != self.RecetPwd.text ? "Passwords do not match" : ""
        
        if strMessage.count > 0 {
            self.showAlert(with: "", message: strMessage)
        }
        else{
            let gender = maleBtn.isSelected ? "Male" : "Female"
            var hobbies: String = ""
            if cricketBtn.isSelected {
                hobbies.append("Cricket")
            }
            if chessBtn.isSelected {
                hobbies.append("Chess")
            }
            if footballBtn.isSelected {
                hobbies.append("Football")
            }
            if VolleyballBtn.isSelected {
                hobbies.append("Volleyball")
            }
            if swimmingBtn.isSelected {
                hobbies.append("Swimming")
            }
            if let name = nameTxt.text?.capitalized, let mobileNO = MobileTxt.text, let image = ImageSelect.image {
                let imageData = image.jpegData(compressionQuality: 1.0)
                let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                if selectedData != nil{
                    let updateQuery = "UPDATE student SET name = ?, mobileno = ?, image = ?  WHERE id = ?"
                    var statement: OpaquePointer?
                    
                    if sqlite3_prepare_v2(dbManager.db, updateQuery, -1, &statement, nil) == SQLITE_OK {
                        sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
                        sqlite3_bind_text(statement, 2, (mobileNO as NSString).utf8String, -1, nil)
                        sqlite3_bind_blob(statement, 3, (imageData as NSData?)?.bytes, Int32(imageData?.count ?? 0), SQLITE_TRANSIENT)
                        sqlite3_bind_int(statement, 4, Int32(selectedData?.id ?? 0))
                        
                        if sqlite3_step(statement) == SQLITE_DONE {
                            self.showAlert(with: "Success", message: "Record updated success fully" , completion: {
                               
                                self.delegate?.updateData()
                                self.navigationController?.popViewController(animated: true)
                            })

                        } else {
                            print("Failed to update data in the database.")
                        }
                        
                        let status = sqlite3_finalize(statement)
                        print("Status: \(status)")
                    } else {
                        print("Error preparing statement for update: \(String(cString: sqlite3_errmsg(dbManager.db)))")
                    }
                
              }else{
                        dbManager.insert(name:nameTxt.text?.capitalized ?? "", username: userNameTxt.text ?? "", mobileno: MobileTxt.text ?? "", email:EmailTxt.text ?? "", password: passwordTxt.text ?? "", education: educationTxt.text ?? "", Dob: dobTxt.text ?? "", image: ImageSelect.image, gender:gender, hobbies:hobbies)
                        self.showAlert(with: "Success", message: "Record inserted success fully" , completion: {
                            self.delegate?.fatchData()
                            
                            self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }
//    deinit{
//        print("deinit call")
//    }
}

extension SecondViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == userNameTxt {
            let allowedCharacters = CharacterSet.urlQueryAllowed//characters hote hain, jaise alphanumerics, hyphen, underscore, etc.
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)

        }else if textField == MobileTxt {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
      
        }else if textField == nameTxt{
            let allowedCharacter = CharacterSet.letters
            let allowedCharacter1 = CharacterSet.whitespaces
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacter.isSuperset(of: characterSet) || allowedCharacter1.isSuperset(of: characterSet)
      
        }else if textField == passwordTxt{

            let allowedCharacters = CharacterSet.letters
            let allowedCharacters1 = CharacterSet.symbols
            let allowedCharacters2 = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet) || allowedCharacters1.isSuperset(of: characterSet) ||
            allowedCharacters2.isSuperset(of: characterSet)
       
        }
            
            
        return true
    }
}
extension SecondViewController: UIPickerViewDelegate,UIPickerViewDataSource{
   
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.aducation.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.aducation[row]
    }
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //self.selectedEdu = self.aducation[row]
        self.educationTxt.text = self.aducation[row]
    }
       
}
extension SecondViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBAction func SelectImgBtn(_ sender: Any) {
        let ac = UIAlertController(title: "Select Image", message: "Select Image From", preferredStyle: .actionSheet)
        let camaraBtn = UIAlertAction(title: "Camera", style: .default){(_)in
            self.showImagePicker(selectedSource: .camera)
        }
        let gallaryBtn = UIAlertAction(title: "Gallary", style: .default){(_)in
            self.showImagePicker(selectedSource: .photoLibrary)
        }
        let canselBtn = UIAlertAction(title: "Cancle", style: .cancel,handler:  nil)
        ac.addAction(camaraBtn)
        ac.addAction(gallaryBtn)
        ac.addAction(canselBtn)
        ac.popoverPresentationController?.sourceView = self.view
//
        ac.popoverPresentationController?.permittedArrowDirections = []
        self.present(ac,animated: true)
        }
    func showImagePicker(selectedSource: UIImagePickerController.SourceType){
        guard UIImagePickerController.isSourceTypeAvailable(selectedSource)else{
            print("Selected Source not availabel")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = selectedSource
        imagePicker.allowsEditing = false
        self.present(imagePicker,animated: true)
        }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage]as? UIImage{
            ImageSelect.image = selectedImage
        }else{
            print("Image not found")
        }
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
class DBManager
{
    
    
   /* func openDatabase()
    {
        guard let bundlePath = Bundle.main.path(forResource: "AddData", ofType: "db")else{
            print("Database file not found in the main bundle")
            return
            
        }
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default
        let fullDestPath = URL(fileURLWithPath: destPath).appendingPathComponent("AddData.db")
        if fileManager.fileExists(atPath: fullDestPath.path){
            print("Database file is exist")
            print(fileManager.fileExists(atPath: bundlePath))
        }else{
            do{
                try fileManager.copyItem(atPath: bundlePath, toPath: fullDestPath.path)
                print("Databse file copied successfully")
            }catch{
                print("Failed to open database connection")
            }
        }
        if sqlite3_open(fullDestPath.path, &db) == SQLITE_OK {
            print("Database connection opened successfully\(fullDestPath)")
        } else {
            print("Failed to open database connection")
        }
    }*/
    
    
    var db:OpaquePointer?
    func createDatabase() -> OpaquePointer?{
       
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Database.db")
            
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
               print("Database connection opened successfully \(fileURL)")
               return db
           } else {
               print("Failed to open database connection")
               return nil
           }
    }
    func createTable(){
        let tableQuery = "CREATE TABLE IF NOT EXISTS student(Id INTEGER PRIMARY KEY,name TEXT,username TEXT,mobileno TEXT,email TEXT,password TEXT,education TEXT,Dob TEXT,image BLOB,gender TEXT,hobbies TEXT);"
        var statement: OpaquePointer? = nil
        //let database = createDatabase()
        if sqlite3_prepare_v2(db, tableQuery, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE{
                print("student table created")
            }else{
                print("student table not created")
            }
            sqlite3_finalize(statement)
        } else{
            print("could not prepared")
        }
   
    }
    
    func insert (name:String,username:String,mobileno:String,email:String,password:String,education:String,Dob:String,image:UIImage?,gender:String,hobbies:String){
        // image ni binary data store karava mate
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let imageData = image?.jpegData(compressionQuality: 1.0)
        let insertData = "INSERT INTO student (name,username,mobileno,email,password,education,Dob,image,gender,hobbies)VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        var statement: OpaquePointer?
        //-1 length indicate kare 6e jethi query ni length automatic tarike se calulate ho
        if sqlite3_prepare_v2(db, insertData, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (mobileno as NSString).utf8String,-1,nil)
            sqlite3_bind_text(statement, 4, (email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (password as NSString).utf8String, -1, nil)
            //sqlite3_bind_text(statement, 6, (repassword as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 6, (education as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 7, (Dob as NSString).utf8String, -1, nil)
            sqlite3_bind_blob(statement, 8, (imageData as NSData?)?.bytes, Int32(imageData?.count ?? 0), SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 9, (gender as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 10, (hobbies as NSString).utf8String, -1, nil)
            
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Data inserted successfully.")
            } else {
                print("Failed to insert data into the database.")
            }
            
            let status = sqlite3_finalize(statement)
            print("Staus: \(status)")
        } else {
            print("Error preparing statement for insertion: \(String(cString: sqlite3_errmsg(db)))")
        }
    }
}


//extension Data {
//    var bytes: [UInt8] {
//        return [UInt8](self)
//    }
//}


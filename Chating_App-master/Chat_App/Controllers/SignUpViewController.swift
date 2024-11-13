//
//  SignUpViewController.swift
//  Chat_App
//
//  Created by MACPC on 19/01/24.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet var confoirmPassword: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var create: UIButton!
    @IBOutlet var name: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        create.layer.cornerRadius = 20

    }
    
    @IBAction func createbtnTapped(_ sender: Any) {
        
        let fullName = name.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().createUser(withEmail: email, password: password) { (result , error) in
//            Checking for the Errors
            if error != nil {
                print("Error Creating user", error?.localizedDescription)
            }
            else{
//                user was created , now store the FullName
                let db = Firestore.firestore()
                
                db.collection("users").addDocument(data: ["fullName" : fullName , "uid" : result!.user.uid]) { (error) in
                    
                    if error != nil {
                        print("error saving user Data")
                    }
                }
//                Transition to the screen
                self.transition()
                
            }
        }
    }
    
    func transition(){
        
        
        let ListViewController = UIStoryboard(name: "Main", bundle: nil)
        if  let ListVc = storyboard?.instantiateViewController(withIdentifier: "list") as? ListViewController{
        navigationController?.pushViewController(ListVc, animated: true)
        }
    }
    
}

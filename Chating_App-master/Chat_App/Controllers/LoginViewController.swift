//
//  LoginViewController.swift
//  Chat_App
//
//  Created by MACPC on 19/01/24.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet var password: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        login.layer.cornerRadius = 20
       

       
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            // Check if a user is already logged in by checking the UID in UserDefaults
            if let uid = UserDefaults.standard.string(forKey: "userUID"), Auth.auth().currentUser?.uid == uid {
                // User is already logged in, transition to the main screen
                transition()
            }
        }
    
   
    @IBAction func loginBtnTapped(_ sender: Any) {
        
        let email = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
           let password = password.text!.trimmingCharacters(in: .whitespaces)

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }

            // Check if the current user is nil after successful sign-in
            if let currentUser = Auth.auth().currentUser {
                print("User is signed in with Firebase. UID: \(currentUser.uid)")
                
                
                // Set the UID in UserDefaults for this user
                UserDefaults.standard.set(currentUser.uid, forKey: "userUID")

                // Check if displayName is nil and update it
                if currentUser.displayName == nil {
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = "DefaultDisplayName" // Set your desired default display name
                    changeRequest?.commitChanges { (error) in
                        if let error = error {
                            print("Error updating displayName: \(error.localizedDescription)")
                        } else {
                            print("displayName updated successfully")
                        }
                    }
                }

                self.transition()
            } else {
                print("Unexpectedly found nil for currentUser after sign-in.")
                // Handle the unexpected nil case, e.g., show an alert to the user
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

//
//  ListViewController.swift
//  Chat_App
//
//  Created by MACPC on 23/01/24.
//

import UIKit
import Firebase

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    var firebaseUser: FirebaseAuth.User?

    @IBOutlet var five: UIImageView!
    @IBOutlet var four: UIImageView!
    @IBOutlet var three: UIImageView!
    @IBOutlet var two: UIImageView!
    @IBOutlet var one: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var secondview: UIView!
    @IBOutlet weak var listTableContainer: UIView!
    
    var users: [User] = [] // Populate this array with user data
    var currentUserUID: String?
    
    override func viewDidLoad() {
            super.viewDidLoad()
            secondview.clipsToBounds = true
            secondview.layer.cornerRadius = 30

            // Load your users into the `users` array
            fetchUsers()

            // Set the data source and delegate for the table view
            tableView.dataSource = self
            tableView.delegate = self
        
//                setCircularBorder(for: one)
//                setCircularBorder(for: two)
//                setCircularBorder(for: three)
//                setCircularBorder(for: four)
//                setCircularBorder(for: five)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setCircularBorder(for imageView: UIImageView) {
          imageView.layer.borderWidth = 2.0
          imageView.layer.borderColor = UIColor.white.cgColor
          imageView.layer.cornerRadius = imageView.frame.size.height / 2
          imageView.clipsToBounds = true
      }
    
    



        func fetchUsers() {
            // Add code to fetch users from your database
            // For example, you might have a Firestore collection "users"
            // and you can fetch users like this:
            Firestore.firestore().collection("users").getDocuments { [weak self] (snapshot, error) in
                guard let self = self, let documents = snapshot?.documents else { return }

                self.users = documents.compactMap { document in
                    let user = User(dictionary: document.data())
                    return user
                }

                self.tableView.reloadData()
            }
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return users.count
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Usercell", for: indexPath) as! TableViewCell
        let user = users[indexPath.row]

        // Check if the user is the current user, and hide the cell if true
        cell.isHidden = user.uid == currentUserUID

        // Display user data only if it's not the current user
        if !cell.isHidden {
            cell.username.text = user.displayName
            cell.uid.text = user.uid // Set the uid label
        }

        return cell
    }



        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedUser = users[indexPath.row]
            // Perform an action when a user is selected (e.g., open a chat)
            startChat(with: selectedUser)
        }

        func startChat(with user: User) {
            // You can implement your chat initiation logic here
            // Pass user information to the chat view controller
            let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chat") as! ChatViewController
            chatViewController.user2Name = user.displayName
            chatViewController.user2UID = user.uid
            navigationController?.pushViewController(chatViewController, animated: true)
        }
}

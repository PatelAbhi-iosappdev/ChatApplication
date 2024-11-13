//
//  ViewController.swift
//  Chat_App
//
//  Created by MACPC on 19/01/24.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices

class ViewController: UIViewController {

    @IBOutlet var signUp: UIButton!
    @IBOutlet var google: UIButton!
    @IBOutlet var apple: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUp.layer.cornerRadius = 20
        
        configureButton(google)
        configureButton(apple)
        
        let gradientColor = createHorizontalGradientColor()
        view.backgroundColor = gradientColor
    }
    
    @IBAction func appleSigninTapped(_ sender: Any) {
        
        let appleIDDetails = ASAuthorizationAppleIDProvider()
        let request = appleIDDetails.createRequest()
        request.requestedScopes = [.email , .fullName]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    @IBAction func googleSignInTapped(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
            // ...
              return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            return
          }
            
          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                            if let error = error {
                                print("Firebase authentication error: \(error.localizedDescription)")
                                return
                            }
                else{
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: [ "uid" : result!.user.uid]) { (error) in
                        
                        if error != nil {
                            print("error saving user Data")
                        }
                    }
                }
                            
                            print("User is signed in with Firebase")
                // Fetch user 2 details here
                           self.fetchUser2Details()
                self.transition()
        }
    }
    
}
    
    @IBAction func signupTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your actual storyboard name
                if let SignupViewController = storyboard.instantiateViewController(withIdentifier: "signup") as? SignUpViewController{
                  navigationController?.pushViewController(SignupViewController, animated: true)
                }
              }

    
    
    @IBAction func loginTapped(_ sender: Any) {
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your actual storyboard name
                if let LoginViewController = storyboard?.instantiateViewController(withIdentifier: "login") as? LoginViewController{
                  navigationController?.pushViewController(LoginViewController, animated: true)
                }
              }
    
    func fetchUser2Details() {
        if let user2 = Auth.auth().currentUser {
            let user2DisplayName = user2.displayName
            let user2PhotoURL = user2.photoURL
            let user2UID = user2.uid

            // Now you have the details of user 2
            print("User 2 Display Name: \(user2DisplayName ?? "N/A")")
            print("User 2 Photo URL: \(user2PhotoURL?.absoluteString ?? "N/A")")
            print("User 2 UID: \(user2UID)")

            // Pass these details to the ChatViewController or wherever needed
            // Example:
            let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chat") as! ChatViewController
            chatViewController.user2Name = user2DisplayName
            chatViewController.user2UID = user2UID
            navigationController?.pushViewController(chatViewController, animated: true)
        } else {
            print("User 2 is not signed in.")
        }
    }
    
    
    
    func transition(){
        
        
        let ListViewController = UIStoryboard(name: "Main", bundle: nil)
        if  let ListVc = storyboard?.instantiateViewController(withIdentifier: "list") as? ListViewController{
        navigationController?.pushViewController(ListVc, animated: true)
        }
    }
    
    func configureButton(_ button: UIButton) {
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    func createHorizontalGradientColor() -> UIColor {
        let startColor = UIColor(red: 39/255, green: 22/255, blue: 60/255, alpha: 1.0)
        let endColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1.0)

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return UIColor(patternImage: image!)
    }

}
extension ViewController : ASAuthorizationControllerDelegate{
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let details = authorization.credential as? ASAuthorizationAppleIDCredential{
            print(details.user)
            print(details.fullName)
            print(details.email)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
}
    



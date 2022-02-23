//
//  UserManager.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 7/17/21.
//

import Foundation

class UserManager{
    private init(){
        
    }
    static let shared = UserManager()
    func isUserLoggedIn() -> Bool{
        if UserDefaultsManager.shared.getLoggedInUser() == nil{
            return false
        } else {
            return true
        }
    }
    
    func loginUser(user: User){
        UserDefaultsManager.shared.saveUser(user: user)
    }
    
    func getUser()-> User?{
        return UserDefaultsManager.shared.getLoggedInUser()
    }
}

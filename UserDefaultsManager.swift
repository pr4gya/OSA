//
//  UserDefaultsManager.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 7/17/21.
//

import Foundation

class UserDefaultsManager{
    private let userDefaults = UserDefaults.standard
    init(){
        
    }
    
    static let shared = UserDefaultsManager()
    
    func saveUser(user: User){
        let encoder = JSONEncoder()
        let data = try? encoder.encode(user)
        
        if data != nil{
            userDefaults.setValue(data, forKey: "LoggedIn")
        } else{
            fatalError("can't save")
            
        }
    }
    func getLoggedInUser() -> User? {
        guard let data = userDefaults.value(forKey: "LoggedIn") as? Data else{
            return nil
        }
        
        let decoder = JSONDecoder()
        let user = try? decoder.decode(User.self, from: data)
        return user
    }
}

///Extensions methods to save ''Objects'' into user defaults
extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}

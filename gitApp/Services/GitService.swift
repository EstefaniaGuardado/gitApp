//
//  GitService.swift
//  gitApp
//
//  Created by Estefania Guardado on 03.04.17.
//  Copyright © 2017 Larsecg. All rights reserved.
//

import Foundation

let GITHUB_REPOSITORIES_URL_TOPIC = "https://api.github.com/search/repositories?q=topic:"
let GITHUB_REPOSITORIES_URL_ORDER = "&sort=stars&order=desc"
let GITHUB_REPOSITORIES_URL_PERPAGE = "&per-page=30"
var setIds = Set<Int>()

class GitService: IRepositoryDataSource {

    /**
     @ref https://api.github.com/search/repositories?q=topic:helloworld&sort=stars&order=desc
     */
    func getRepositories(searchTerm:String, pageNumber: String, completion:@escaping (_ repositoriesData: Array<Repository>?, _ error:NSError?) -> Void) -> Void {
        
        var repositories = [Repository]()
        
        var requestURL = URLRequest (url: URL (string: GITHUB_REPOSITORIES_URL_TOPIC + searchTerm +
                                    GITHUB_REPOSITORIES_URL_ORDER + "&page=" + pageNumber +
                                    GITHUB_REPOSITORIES_URL_PERPAGE)!)
        
        requestURL.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: requestURL) {
            data, response, error in
        
            if (error != nil) {
                print("ERROR=\(error)")
                completion(repositories, error as NSError?)
                return
            }
            
            let response = String (data: data!, encoding: .utf8)
            print("RESPONSE = \(response)")
            
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    
                    repositories = self.getArrayOfRepositories(dictionary: convertedJsonIntoDict)
                    completion(repositories, error as NSError?)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }

        task.resume()
    }
    
    func getArrayOfRepositories(dictionary:NSDictionary) -> Array<Repository> {
        let items = [[dictionary.value(forKey: "items")][0]][0] as! Array<NSDictionary>
        
        // TODO: Use map
        var repositoryArray = [Repository]()
        
        for (_, item) in items.enumerated(){
            let itemID = item.value(forKey: "id") as! Int
            
            if !self.existRepository(id: itemID) {
                repositoryArray.append(self.initializeRepositoryData(id: itemID, data: item))
            }
        }
        
        return repositoryArray
    }
    
    func existRepository(id: Int) -> Bool {
        if setIds.contains(id) {
            return true
        }
        
        setIds.insert(id)
        return false
    }
    
        let itemName = data.value(forKey: "name") as! String
        let itemLanguage = (data.value(forKey: "language") as? String != nil) ?
                data.value(forKey: "language") as! String : ""
        let itemForks = data.value(forKey: "forks_count") as! Int
        let owner = data.value(forKey: "owner") as! NSDictionary
        let loginOwner = owner.value(forKey: "login") as! String
        let avatarOwner = (owner.value(forKey: "avatar_url") as? String != nil) ?
                owner.value(forKey: "avatar_url") as! String : ""
            
                               imageURL: URL.init(string: avatarOwner)!)
        
    }

}

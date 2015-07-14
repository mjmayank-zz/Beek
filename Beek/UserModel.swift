//
//  UserModel.swift
//  Beek
//
//  Created by Mayank Jain on 7/13/15.
//  Copyright (c) 2015 Mayank Jain. All rights reserved.
//

import Foundation
import Parse

class UserModel{
    
    var username : String!
    var objectId : String!
    
    init(user: PFUser){
        self.username = user.objectForKey("username") as! String
        self.objectId = user.objectId
    }
    
    class func currentUser() -> UserModel{
        var user = UserModel(user: PFUser.currentUser()!)
        return user
    }

}
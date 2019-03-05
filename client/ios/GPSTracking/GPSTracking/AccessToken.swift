//
//  AccessToken.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/25/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import Locksmith

let KEY_KEYACHAIN       : String = "GPSTRACKING_ACCESS_TOKEN";
let AUTH_SERVICE_NAMED  : String = "AUTH";

class AccessToken {
    var value           : String = "";
    var accountNamed    : String?;
    
    func get() -> String {
        return value;
    }
    
    func set(accessToken : String, accountNamed: String) -> Bool {
        self.value           = accessToken;
        self.accountNamed    = accountNamed;
        
        saveAccessToken();
        return true;
    }
    
    func update(accessToken : String, accountNamed: String) -> Bool {
        self.value           = accessToken;
        self.accountNamed    = accountNamed;

        saveAccessToken();
        return true;
    }
    
    func drop() ->Bool {
        if let accountNamed = self.accountNamed {
            do {
                try Locksmith.deleteDataForUserAccount(accountNamed, inService: AUTH_SERVICE_NAMED)
                
                self.value           = "";
                self.accountNamed    = "";
            }catch {}
        }
        
        return true;
    }
    
    func saveAccessToken() {
        do {
            try Locksmith.updateData([KEY_KEYACHAIN: value], forUserAccount: accountNamed!, inService: AUTH_SERVICE_NAMED)
        }catch {}
        
    }
    
    func tryLoadAccessToken(accountNamed : String) {
        if let dictionary = Locksmith.loadDataForUserAccount(accountNamed, inService: AUTH_SERVICE_NAMED) {
            self.value           = dictionary[KEY_KEYACHAIN] as! String;
            self.accountNamed    = accountNamed;
        }
    }
}
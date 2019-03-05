//
//  Checkin
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation


class Checkin: Model {
    override func formNamed() -> String {
        return "checkin"
    }
    
    override var description: String {
        return "[Checkin] id:" + id;
    }
    
    func location() -> CLLocation {
        let slat = self.valueForKey("latitude")     as! CLLocationDegrees
        let slng = self.valueForKey("longitude")    as! CLLocationDegrees

        return CLLocation(latitude: slat, longitude: slng)
    }
    
    func getOwner() -> User{
        return User(raw: ["_id" : ownerIdValue()])
    }
    
    func compareTo(other: Checkin) -> Bool {
        let loc  = self.location()
        let loc2 = other.location()
        let distance: CLLocationDistance = loc.distanceFromLocation(loc2)
        return (distance as Double) < 10.0
    }
}

func == (lhs: Checkin, rhs: Checkin) -> Bool {
    return lhs.id == rhs.id
}

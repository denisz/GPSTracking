//var dict : Dictionary<String, String> = [
//    "item": "World"
//]
//
//Template.render("Hello {item}!", dict: dict)

import Foundation

class Template {
    
    class func render (var str: String, dict: Dictionary<String, String>) -> String {
        for (key, value) in dict {
            str = str.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        }
        return str
    }
    
}
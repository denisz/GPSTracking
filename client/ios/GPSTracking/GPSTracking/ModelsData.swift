func ModelsData() -> [String: AnyObject] {
    let path = NSBundle.mainBundle().pathForResource("newModels", ofType: "json")

    do{
        let jsonData = try NSData(contentsOfFile: path!, options: .DataReadingMappedIfSafe)
        let obj = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! [String : AnyObject]
        
        return obj
    } catch {
        
    }
    return [:]
}

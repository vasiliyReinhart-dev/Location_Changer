
import CoreData
import UIKit

final class StorageManager {
    
    static let shared = StorageManager()
    
    var appDelegate: AppDelegate
    var objectContext: NSManagedObjectContext
    init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        objectContext = appDelegate.persistentContainer.viewContext
    }
}

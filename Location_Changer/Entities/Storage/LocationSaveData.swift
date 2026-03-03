
import CoreData
import UIKit
import CoreLocation

@objc(LocationSaveData)
public class LocationSaveData: NSManagedObject {}
extension LocationSaveData {
    @NSManaged public var uuid: String?
    
    @NSManaged public var city: String?
    @NSManaged public var street: String?
    @NSManaged public var country: String?
    
    @NSManaged public var coordinate: String?
    
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    
    @NSManaged public var preview: Data?
}
extension LocationSaveData : Identifiable {}


extension StorageManager {
    
    func getAllLocation() -> [LocationSaveData] {
        let fetch = NSFetchRequest<LocationSaveData>(entityName: "LocationSaveData")
        do {
            let context = appDelegate.persistentContainer.viewContext
            return try context.fetch(fetch)
        } catch {
            print("Failed to fetch drafts: \(error)")
            return []
        }
    }
    func saveLocation(placemark: CLPlacemark?,
                      preview: UIImage?) {
        guard let placemark, let entity = NSEntityDescription.entity(forEntityName: "LocationSaveData",
                                                                     in: objectContext) else { return }
        let loc = LocationSaveData(entity: entity,
                                   insertInto: objectContext)
        loc.uuid = UUID().uuidString
        loc.city = placemark.locality
        loc.country = placemark.country
        loc.street = placemark.thoroughfare
        loc.coordinate = "\(placemark.location?.coordinate.latitude ?? 0.0), \(placemark.location?.coordinate.longitude ?? 0.0)"
        loc.latitude = placemark.location?.coordinate.latitude ?? 0.0
        loc.longitude = placemark.location?.coordinate.longitude ?? 0.0
        loc.preview = preview?.pngData()
        appDelegate.saveContext()
    }
    func editLocation(uuid: String?,
                      placemark: CLPlacemark?,
                      preview: UIImage?) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationSaveData")
        do {
            guard let placemark,
                  let data = try? objectContext.fetch(fetch) as? [LocationSaveData],
                  let attribute = data.first(where: { $0.uuid == uuid }) else { return }
            attribute.city = placemark.locality
            attribute.country = placemark.country
            attribute.street = placemark.thoroughfare
            attribute.coordinate = "\(placemark.location?.coordinate.latitude ?? 0.0), \(placemark.location?.coordinate.longitude ?? 0.0)"
            attribute.latitude = placemark.location?.coordinate.latitude ?? 0.0
            attribute.longitude = placemark.location?.coordinate.longitude ?? 0.0
            attribute.preview = preview?.pngData()
        }
        appDelegate.saveContext()
    }
    func fetchLocation(_ street: String?) -> LocationSaveData? {
        guard let street else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationSaveData")
        request.predicate = NSPredicate(format: "street == %@", street)
        do {
            let results = try objectContext.fetch(request) as? [LocationSaveData]
            return results?.first
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
    func removeLocationData(_ uid: [String?]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationSaveData")
        fetchRequest.predicate = NSPredicate(format: "uuid IN %@", uid)
        do {
            if let result = try objectContext.fetch(fetchRequest) as? [LocationSaveData] {
                for template in result {
                    objectContext.delete(template)
                }
                appDelegate.saveContext()
            }
        } catch {
            print("Ошибка при удалени: \(error.localizedDescription)")
        }
    }
}

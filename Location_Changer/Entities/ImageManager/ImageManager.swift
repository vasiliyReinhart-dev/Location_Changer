import UIKit
import Photos
import ImageIO
import CoreLocation

final class ImageManager {
    
    static let shared = ImageManager()
    var isSaveCompleted: ((Bool) -> Void)?
    
    func selectImage(_ provider: NSItemProvider) async throws -> UIImage? {
        guard provider.canLoadObject(ofClass: UIImage.self) else { return nil }
        return try await withCheckedThrowingContinuation { continuation in
            let _ = provider.loadObject(ofClass: UIImage.self) { object, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                if let image = object as? UIImage {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    func fetchRawMetadata(_ provider: NSItemProvider) async throws -> RawMetadata {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: "public.image") { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let url = url else {
                    continuation.resume(returning: RawMetadata())
                    return
                }
                let metadata = self.extractMetadata(url)
                continuation.resume(returning: metadata)
            }
        }
    }
    func savePhoto(_ data: EXIFData?) {
        guard let exifData = data,
              let image = exifData.image,
              let imageData = image.jpegData(compressionQuality: 1.0)
        else {
            print("Нет изображения для сохранения")
            isSaveCompleted?(false)
            return
        }
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let type = CGImageSourceGetType(source)
        else { return }

        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData as CFMutableData, type, 1, nil) else { return }
        var metadata = [String: Any]()
        var tiff = [String: Any]()
        if let model = exifData.deviceModel {
            tiff[kCGImagePropertyTIFFModel as String] = model
        }
        metadata[kCGImagePropertyTIFFDictionary as String] = tiff
        var exif = [String: Any]()
        if let date = exifData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            exif[kCGImagePropertyExifDateTimeOriginal as String] = formatter.string(from: date)
            exif[kCGImagePropertyExifDateTimeDigitized as String] = formatter.string(from: date)
        }
        metadata[kCGImagePropertyExifDictionary as String] = exif
        if let location = exifData.location {
            var gps = [String: Any]()
            gps[kCGImagePropertyGPSLatitude as String] = abs(location.coordinate.latitude)
            gps[kCGImagePropertyGPSLatitudeRef as String] = location.coordinate.latitude >= 0 ? "N" : "S"
            gps[kCGImagePropertyGPSLongitude as String] = abs(location.coordinate.longitude)
            gps[kCGImagePropertyGPSLongitudeRef as String] = location.coordinate.longitude >= 0 ? "E" : "W"
            metadata[kCGImagePropertyGPSDictionary as String] = gps
        }
        CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
        CGImageDestinationFinalize(destination)
        PHPhotoLibrary.shared().performChanges({
            let options = PHAssetResourceCreationOptions()
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: mutableData as Data, options: options)
        }) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.isSaveCompleted?(true)
                }
            } else {
                DispatchQueue.main.async {
                    self.isSaveCompleted?(false)
                }
                print("Ошибка сохранения:", error?.localizedDescription ?? "")
            }
        }
    }
}
private extension ImageManager {
    func extractMetadata(_ url: URL) -> RawMetadata {
         guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
               let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
             return RawMetadata()
         }
         var result = RawMetadata()
         if let tiff = metadata[kCGImagePropertyTIFFDictionary] as? [CFString: Any],
            let dateTime = tiff[kCGImagePropertyTIFFDateTime] as? String {
             let formatter = DateFormatter()
             formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
             result.date = formatter.date(from: dateTime)
         }
         if let tiff = metadata[kCGImagePropertyTIFFDictionary] as? [CFString: Any] {
             result.model = tiff[kCGImagePropertyTIFFModel] as? String
         }
         if let gps = metadata[kCGImagePropertyGPSDictionary] as? [CFString: Any],
            let lat = gps[kCGImagePropertyGPSLatitude] as? Double,
            let lon = gps[kCGImagePropertyGPSLongitude] as? Double {
             let latRef = gps[kCGImagePropertyGPSLatitudeRef] as? String ?? "N"
             let lonRef = gps[kCGImagePropertyGPSLongitudeRef] as? String ?? "E"
             
             let finalLat = latRef == "S" ? -lat : lat
             let finalLon = lonRef == "W" ? -lon : lon
             result.location = CLLocation(latitude: finalLat, longitude: finalLon)
         }
         return result
     }
}

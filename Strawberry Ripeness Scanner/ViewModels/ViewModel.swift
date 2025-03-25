//
//  ViewModel.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 1/14/25.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseStorage

// this is for image orientation, mainly to fix bounding box issues with uploading directly from camera
extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1  // maintain scale
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? self
    }
}

class ViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var showPicker = false
    @Published var source: Picker.Source = .camera
    @Published var showCameraAlert = false
    @Published var cameraError: Picker.CameraErrorType?
    @Published var isEditing = false
    @Published var selectedImage: MyImage?
    @Published var myImages: [MyImage] = []
    @Published var showFileAlert = false
    @Published var appError: MyImageError.ErrorType?
    @Published var imageChanged = false
    @Published var currentUser: User? 
    @Published var syncing = false {
        didSet {
            if !syncing && cloudImageAdded {
                loadImages()
                cloudImageAdded = false
            }
        }
    }
    @Published var displayedImages: [MyImage] = []
    @Published var interval: ReportInterval
    @Published var ripe = 0
    @Published var unripe = 0
    @Published var nearlyRipe = 0
    @Published var date = Date()
    @Published var endDate = Date()
    @Published var loading = false
    
    private let objectRecognizer = ObjectRecognizer()
    private var cloudImageAdded = false {
        didSet {
            if cloudImageAdded {
                if !syncing {
                    loadImages()
                    cloudImageAdded = false
                }
            }
        }
    }
    
    init() {
        interval = .allTime
        print(FileManager.docDirURL.path)
    }
    
    var reportInterval: String {
        switch interval {
        case .allTime:
            return "All Time"
        case .today:
            return "Today"
        case .custom:
            let startDate = formatter.string(from: self.date)
            let stopDate = formatter.string(from: self.endDate)
            let today = formatter.string(from: Date())
            if startDate == stopDate {
                if startDate == today {
                    return "Today"
                }
                return startDate
            }
            return "\(startDate) to \(stopDate)"
        }
    }
    
    private var imagesHash = Set<String>()
    
    private var formatter: DateFormatter {
        let temp = DateFormatter()
        temp.dateFormat = "yyyy/MM/dd"
        return temp
    }
    
    var deleteButtonIsHidden: Bool {
        isEditing || selectedImage == nil
    }
    
    var pathsUpdated = false {
        didSet {
            if pathsUpdated {
                Task {
                    defer { pathsUpdated = false }
                    await updatePaths()
                }
            }
        }
    }
    
    func setUser(_ user: User?) {
        if user != nil {
            self.currentUser = user
            self.syncing = true
            print("\(self.syncing)")
            Task {
                await updateLocalAndCloud()
            }
        }
        else {
            self.currentUser = nil
        }
    }
    
    func showPhotoPicker() {
        do {
            if source == .camera {
                try Picker.checkPermissions()
            }
            showPicker = true
        } catch {
            showCameraAlert = true
            cameraError = Picker.CameraErrorType(error: error as! Picker.PickerError)
        }
    }
    
    func reset() {
        image = nil
        isEditing = false
        selectedImage = nil
    }
    
    func display(_ myImage: MyImage) {
        image = myImage.image
        selectedImage = myImage
    }
    
    
    func deleteSelected() {
        if let index = myImages.firstIndex(where: {$0.id == selectedImage!.id}) {
            if self.currentUser != nil {
                if let path = self.currentUser!.imagePaths["\(myImages[index].id)"] {
                    self.currentUser!.imagePaths.removeValue(forKey: "\(myImages[index].id)")
                    self.pathsUpdated = true
                    self.syncing = true
                    Task {
                        await deleteImageFromCloud(path)
                        await MainActor.run {
                            self.syncing = false
                        }
                    }
                }
            }
            self.imagesHash.remove("\(myImages[index].id)")
            myImages.remove(at: index)
            loadImages()
            saveMyImagesJSONFile()
            reset()
        }
    }
    
    func addMyImage(image: UIImage) {
        reset()
        var myImage = MyImage(date: Date())

        let fixedImage = image.fixedOrientation() // normalize orientation
        let resizedImage = fixedImage.resized(to: CGSize(width: 640, height: 640)) // resize for model, necessary for camera images

        // run object recognition
        objectRecognizer.recognize(fromImage: resizedImage) { recognizedObjects in
            var finalImage = resizedImage

            if !recognizedObjects.isEmpty {
                // print("Detected \(recognizedObjects.count) objects, drawing bounding boxes.")

                let imageSize = resizedImage.size
                UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
                resizedImage.draw(at: .zero)

                for detection in recognizedObjects {
                    let boundingBox = detection.bounds
                    let x = boundingBox.minX * imageSize.width
                    let y = (1.0 - boundingBox.maxY) * imageSize.height
                    let width = boundingBox.width * imageSize.width
                    let height = boundingBox.height * imageSize.height
                    let rectangle = CGRect(x: x, y: y, width: width, height: height)
                    var color: UIColor
                    
                    // draw bounding box
                    if detection.label == "Ripe" {
                        myImage.ripe += 1
                        color = UIColor.green
                    } else if detection.label == "Nearly Ripe" {
                        myImage.nearlyRipe += 1
                        color = UIColor.yellow
                    } else {
                        myImage.unripe += 1
                        color = UIColor.red
                    }
                    color.setStroke()
                    
                    let path = UIBezierPath(rect: rectangle)
                    path.lineWidth = 3
                    path.stroke()

                    // draw label
                    let text = "\(detection.label) (\(String(format: "%.2f", detection.confidence * 100))%)"
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 14),
                        .foregroundColor: UIColor.black,
                        .backgroundColor: color
                    ]
                    let textSize = text.size(withAttributes: attributes)
                    let textRect = CGRect(x: max(0, min(x, imageSize.width - textSize.width)),
                                          y: max(0, y - textSize.height - 2),
                                          width: textSize.width,
                                          height: textSize.height)
                    text.draw(in: textRect, withAttributes: attributes)
                    
                    // update class counts in myImage
                }

                finalImage = UIGraphicsGetImageFromCurrentImageContext() ?? resizedImage
                UIGraphicsEndImageContext()
            } else {
                print("No objects detected, saving original image.")
            }

            // save image to JSON
            do {
                try FileManager().saveImage("\(myImage.id)", image: finalImage)
                self.myImages.append(myImage)
                self.imagesHash.insert("\(myImage.id)")
                self.loadImages()
                self.saveMyImagesJSONFile()
                if self.currentUser != nil {
                    self.syncing = true
                    self.uploadPhoto(myImage) {
                        DispatchQueue.main.async {
                            self.syncing = false
                            //print("\nSync: \(self.syncing)")
                        }
                    }
                }
            } catch {
                self.showFileAlert = true
                self.appError = MyImageError.ErrorType(error: error as! MyImageError)
            }
        }
        
        if self.imageChanged {
            self.imageChanged = false
        }
        display(myImage)
        loading = false
    }

    func addCloudImage(myImage: MyImage, image: UIImage) {
        do {
            try FileManager().saveImage("\(myImage.id)", image: image)
            self.myImages.append(myImage)
            self.imagesHash.insert("\(myImage.id)")
            self.saveMyImagesJSONFile()
        } catch {
            self.showFileAlert = true
            self.appError = MyImageError.ErrorType(error: error as! MyImageError)
        }
    }
    
    func saveMyImagesJSONFile() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(myImages)
            let jsonString = String(decoding: data, as: UTF8.self)
            reset()
            do {
                try FileManager().saveDocument(contents: jsonString)
            } catch {
                showFileAlert = true
                appError = MyImageError.ErrorType(error: error as! MyImageError)
            }
        } catch {
            showFileAlert = true
            appError = MyImageError.ErrorType(error: .encodingError)
        }
    }
    
    func loadMyImagesJSONFile() {
        do {
            let data = try FileManager().readDocument()
            let decoder = JSONDecoder()
            do {
                myImages = try decoder.decode([MyImage].self, from: data)
                loadImages()
                for image in myImages {
                    // add image IDs to hash for fast lookup
                    imagesHash.insert("\(image.id)")
                }
            } catch {
                showFileAlert = true
                appError = MyImageError.ErrorType(error: .decodingError)
            }
        } catch {
            showFileAlert = true
            appError = MyImageError.ErrorType(error: error as! MyImageError)
        }
    }
    
    func loadImages() {
        ripe = 0
        unripe = 0
        nearlyRipe = 0
        if self.cloudImageAdded {
            myImages.sort(by: {$0.date < $1.date})
            print("Images were sorted!\n")
        }
        switch interval {
        case .allTime:
            displayedImages = myImages
        case .today:
            displayedImages = []
            let today = formatter.string(from: Date())
            for image in myImages {
                if formatter.string(from: image.date) == today {
                    displayedImages.append(image)
                }
            }
        case .custom:
            displayedImages = []
            var imageDate: String
            let startDate = formatter.string(from: self.date)
            let stopDate = formatter.string(from: self.endDate)
            for image in myImages {
                imageDate = formatter.string(from: image.date)
                if (startDate <= imageDate) && (imageDate <= stopDate) {
                    displayedImages.append(image)
                }
            }
        }
        for images in displayedImages {
            ripe += images.ripe
            unripe += images.unripe
            nearlyRipe += images.nearlyRipe
        }
    }
    
    // need to make it escaping to change self.syncDone = false
    // make it optional because self.syncDone = false does not have to be set for some functions
    func uploadPhoto(_ image: MyImage, completion: (() -> Void)? = nil) {
        // create storage reference
        let storage = Storage.storage().reference()
        
        // turn image into data
        let imageData = image.image.jpegData(compressionQuality: 0.8)
        
        guard imageData != nil else {
            return
        }
        
        //get user id
        guard let userID = currentUser?.id else {
            return
        }
        
        //specify the file path and name
        let fileRef = storage.child("\(userID)/images/\(image.id).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = [
            "uploadDate": "\(image.date)",
            "ripe": String(image.ripe),
            "nearlyRipe": String(image.nearlyRipe),
            "unripe": String(image.unripe)
        ]

        
        let _ = fileRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            // check for errors
            if error == nil && metadata != nil {
                self.currentUser?.imagePaths["\(image.id)"] = "\(userID)/images/\(image.id).jpg"
                self.pathsUpdated = true
                // print(self.currentUser!.imagePaths)
            }
            // .putData is asynchronous so use completion function to signify uploadPhoto is done and to execute its completion
            completion?()
        }
    }
    
    func updatePaths() async {
        if let user = self.currentUser {
            let db = Firestore.firestore().collection("users").document(user.id)
            do {
              try await db.updateData([
                "imagePaths": currentUser!.imagePaths
              ])
                print("imagePaths successfully updated!")
            } catch {
                print("Error updating imagePaths: \(error)")
            }
        }
        else {
            print("User became invalid. Server possibly went down.")
            return
        }
    }
    
    func deleteImageFromCloud(_ path: String) async {
        // Create a reference to the file to delete
        let imageRef = Storage.storage().reference().child(path)

        do {
            // delete the file
            try await imageRef.delete()
            print("Image was successfully deleted from the cloud.")
        } catch {
            // error
            print("There was an error when attempting the image from the cloud.")
            return
        }
    }
    
    func updateLocalAndCloud() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        // Retrieving images stored on cloud
        for (id, path) in currentUser!.imagePaths {
            if imagesHash.contains(id) {
//                print("Hashset: \(imagesHash), images: \(myImages)\n")
                continue
            }
            // no need for Task, function is async
            if let metadata = await getMetaData(path) {
//                print("Metadata retrieved for image: \(metadata.customMetadata)\n")
                retrievePhoto(path) { image in
                    if let img = image {
//                        print("photo retrieved, UPDATE HERE: \(id)")
                        if let date = formatter.date(from: metadata.customMetadata!["uploadDate"]!) {
                            let myImage = MyImage(id: UUID(uuidString: id)!, date: date, ripe: Int(metadata.customMetadata!["ripe"]!)!, unripe: Int(metadata.customMetadata!["unripe"]!)!, nearlyRipe: Int(metadata.customMetadata!["nearlyRipe"]!)!)
                            self.addCloudImage(myImage: myImage, image: img)
                            if !self.cloudImageAdded {
                                self.cloudImageAdded = true
                            }
//                            print("date converted\n")
                        } else {
                            print("date conversion in update failed\n")
                        }
                    }
                    else {
                        print("Could not get photo for image id: \(id)")
                    }
                }
            } else {
                print("Metadata retrieval failed for image at path: \(path)")
            }
        }
        
        // Store local images on cloud
        var count = 0
        var total = 0
        for myImage in myImages {
            if currentUser!.imagePaths["\(myImage.id)"] == nil {
                total += 1
                // print("Uploading image \(myImage.id)...\n")
                uploadPhoto(myImage) {
                    // forces UI updates to run on main thread
                    Task { @MainActor in
                        count += 1
                        if count == total {
                            self.syncing = false
                        }
                    }
                }
            }
        }
        if total == 0 {
            Task { @MainActor in
                self.syncing = false
            }
        }
    }
    
    // imageRef is async since uses getData, but it seems that FireBase has not yet used Swift's new async feature
    func retrievePhoto(_ path: String, completion: @escaping (UIImage?) -> Void) {
        // Create a reference to the file you want to download
        let imageRef = Storage.storage().reference().child(path)

        // Download in memory with a maximum allowed size of 10MB (10 * 1024 * 1024 bytes)
        imageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
          if let error = error {
              print("An error occured when retrieving image from cloud: \(error)\n")
              completion(nil)
          } else {
              // Data for "images/island.jpg" is returned
              completion(UIImage(data: data!))
          }
        }
    }
    
    func getMetaData(_ path: String) async -> StorageMetadata? {
        let imageRef = Storage.storage().reference().child(path)
        
        do {
            return try await imageRef.getMetadata()
        } catch {
            print("Error getting image metadata.\n")
            return nil
        }
    }
}

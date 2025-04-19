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

class ViewModel: NSObject, ObservableObject {
    @Published var image: UIImage? {
        didSet {
            if image != nil {
                imageSaved = false
            }
        }
    }
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
            if !syncing {
                if deleteImages {
                    deleteImages = false
                    deleteAllImages()
                }
                if cloudImageAdded {
                    loadImages()
                    cloudImageAdded = false
                }
            }
        }
    }
    @Published var displayedImages: [MyImage] = []
    @Published var interval: ReportInterval
    @Published var ripe = 0
    @Published var unripe = 0
    @Published var nearlyRipe = 0
    @Published var rotten = 0
    @Published var date = Date()
    @Published var endDate = Date()
    @Published var loading = false
    @Published var imageSaved = false
    @Published var cloudSyncing = false
    @Published var deletionsInProgress = false
    @Published var deleteImages = false {
        didSet {
            if deleteImages {
                if !syncing {
                    deleteImages = false
                    deleteAllImages()
                }
            }
        }
    }
    @Published var reversedOrder = true {
        didSet {
            loadImages()
        }
    }
    
    private var totalToDelete = 0 {
        didSet {
            if deletionsInProgress {
                print("Total to Delete: \(totalToDelete)")
                if totalToDelete == 0 {
                    deletionsInProgress = false
                    loading = false
                }
            }
        }
    }
    
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
    
    override init() {
        interval = .allTime
        print(FileManager.docDirURL.path)
        super.init()
    }
    
    var reportInterval: String {
        switch interval {
        case .allTime:
            return "All Time"
        case .today:
            return "Today"
        case .custom:
            let startDate = displayFormatter.string(from: self.date)
            let stopDate = displayFormatter.string(from: self.endDate)
            let today = displayFormatter.string(from: Date())
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
    
    private var displayFormatter: DateFormatter {
        let temp = DateFormatter()
        temp.dateFormat = "MM/dd/yyyy"
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
            print("New user data/new user set! Sycing local and cloud!")
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
        imageChanged = false
    }
    
    func display(_ myImage: MyImage) {
        image = myImage.image
        selectedImage = myImage
    }
    
    
    func deleteImage(_ image: MyImage) {
        if let index = myImages.firstIndex(where: {$0.id == image.id}) {
            if selectedImage != nil && selectedImage!.id == image.id {
                reset()
            }
            if self.currentUser != nil {
                if let path = self.currentUser!.imagePaths["\(myImages[index].id)"] {
                    self.currentUser!.imagePaths.removeValue(forKey: "\(myImages[index].id)")
                    self.currentUser!.deletedImages["\(myImages[index].id)"] = "\(Date())"
                    self.pathsUpdated = true
                    self.syncing = true
                    Task {
                        await deleteImageFromCloud(path)
                        await MainActor.run {
                            if self.deletionsInProgress {
                                self.totalToDelete -= 1
                                print("Total to delete in MainActor: \(totalToDelete)")
                            }
                            if !self.cloudSyncing {
                                self.syncing = false
                                print("syncing set to false in deleteImage")
                            }
                        }
                    }
                }
            }
            self.imagesHash.remove("\(myImages[index].id)")
            myImages.remove(at: index)
            loadImages()
            saveMyImagesJSONFile()
        }
    }
    
    func deleteAllImages() {
        reset()
        deletionsInProgress = true
        totalToDelete = myImages.count
        for image in myImages {
            deleteImage(image)
        }
        if currentUser == nil {
            deleteImages = false
            loading = false
        }
    }
    
    func addMyImage(image: UIImage) {
        reset()
        var myImage = MyImage(date: Date())

        let fixedImage = image.fixedOrientation() // normalize orientation

        // run object recognition
        objectRecognizer.recognize(fromImage: fixedImage) { recognizedObjects in
            var finalImage = fixedImage

            if !recognizedObjects.isEmpty {
                // print("Detected \(recognizedObjects.count) objects, drawing bounding boxes.")

                let imageSize = fixedImage.size
                UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
                fixedImage.draw(at: .zero)

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
                    } else if detection.label == "Unripe" {
                        myImage.unripe += 1
                        color = UIColor.red
                    }
                    else {
                        myImage.rotten += 1
                        color = UIColor.black
                    }
                    color.setStroke()
                    
                    let path = UIBezierPath(rect: rectangle)
                    path.lineWidth = 3
                    path.stroke()

                    // draw label
                    let text = "\(detection.label) (\(String(format: "%.2f", detection.confidence * 100))%)"
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 14),
                        .foregroundColor: detection.label == "Rotten" ? UIColor.white : UIColor.black,
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

                finalImage = UIGraphicsGetImageFromCurrentImageContext() ?? fixedImage
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
        rotten = 0
//        if self.cloudImageAdded {
//            myImages.sort(by: {$0.date < $1.date})
//            print("Images were sorted!\n")
//        }
        if reversedOrder {
            myImages.sort(by: {$0.date > $1.date})
        } else {
            myImages.sort(by: {$0.date < $1.date})
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
        for image in displayedImages {
            ripe += image.ripe
            unripe += image.unripe
            nearlyRipe += image.nearlyRipe
            rotten += image.rotten
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
        let fileRef = storage.child("users/\(userID)/scans/\(image.id).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = [
            "uploadDate": "\(image.date)",
            "ripe": String(image.ripe),
            "nearlyRipe": String(image.nearlyRipe),
            "unripe": String(image.unripe),
            "rotten": String(image.rotten)
        ]

        
        let _ = fileRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            // check for errors
            if error == nil && metadata != nil {
                self.currentUser?.imagePaths["\(image.id)"] = "users/\(userID)/scans/\(image.id).jpg"
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
                "imagePaths": currentUser!.imagePaths,
                "deletedImages": currentUser!.deletedImages
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
        // delete images that were deleted on other devices
        Task { @MainActor in
            cloudSyncing = true
        }
        for image in myImages {
            if currentUser!.deletedImages["\(image.id)"] != nil {
                print("Deleting image: \(image.id)")
                Task { @MainActor in
                    deleteImage(image)
                }
            }
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        // Retrieving images stored on cloud
        for (id, path) in currentUser!.imagePaths {
            if imagesHash.contains(id) {
//                print("Hashset: \(imagesHash), images: \(myImages)\n")
                continue
            }
            if currentUser!.deletedImages["\(id)"] != nil {
                if currentUser!.imagePaths["\(id)"] != nil {
                    Task { @MainActor in
                        currentUser!.imagePaths.removeValue(forKey: "\(id)")
                        pathsUpdated = true
                    }
                }
                continue
            }
            // no need for Task, function is async
            if let metadata = await getMetaData(path) {
//                print("Metadata retrieved for image: \(metadata.customMetadata)\n")
                retrievePhoto(path) { image in
                    if let img = image {
//                        print("photo retrieved, UPDATE HERE: \(id)")
                        if let date = formatter.date(from: metadata.customMetadata!["uploadDate"]!) {
                            let myImage = MyImage(id: UUID(uuidString: id)!, date: date, ripe: Int(metadata.customMetadata!["ripe"]!)!, unripe: Int(metadata.customMetadata!["unripe"]!)!, nearlyRipe: Int(metadata.customMetadata!["nearlyRipe"]!)!, rotten: Int(metadata.customMetadata!["rotten"]!)!)
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
                            self.cloudSyncing = false
                            self.syncing = false
                        }
                    }
                }
            }
        }
        if total == 0 {
            Task { @MainActor in
                self.cloudSyncing = false
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
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        imageSaved = true
        print("here")
    }
    
    func saveAllImages() {
        for imageObj in myImages {
            writeToPhotoAlbum(image: imageObj.image)
        }
    }
}

//
//  ReportItemViewModel.swift
//  FindItKIET
//
//  ViewModel for reporting lost/found items
//

import Foundation
import Combine
import PhotosUI
import SwiftUI

@MainActor
class ReportItemViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var category: ItemCategory = .other
    @Published var status: ItemStatus = .lost
    @Published var location = ""
    @Published var reportedDate = Date()
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var selectedImages: [UIImage] = []
    @Published var imageUrls: [String] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var submitSuccess = false
    
    var isValidForm: Bool {
        !title.isEmpty && title.count >= 3 &&
        !description.isEmpty && description.count >= 10 &&
        !location.isEmpty
    }
    
    func submitItem() async {
        guard isValidForm else {
            errorMessage = "Please fill all required fields correctly"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Upload Images if any
            var uploadedUrls: [String] = []
            if !selectedImages.isEmpty {
                uploadedUrls = try await ImageUploadService.shared.uploadImages(selectedImages)
            }
            
            // 2. Submit Item
            let endpoint = Endpoint(
                path: "/items",
                method: .post,
                body: [
                    "title": title,
                    "description": description,
                    "category": category.rawValue,
                    "status": status.rawValue,
                    "location": location,
                    "reportedAt": ISO8601DateFormatter().string(from: reportedDate),
                    "imageUrls": uploadedUrls
                ],
                requiresAuth: true
            )
            
            let _: Item = try await APIClient.shared.request(
                endpoint,
                responseType: Item.self
            )
            
            submitSuccess = true
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    
    func loadImages() async {
        selectedImages = []
        
        for item in selectedPhotos {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { continue }
            selectedImages.append(image)
        }
        // Images are stored in selectedImages and will be uploaded on submit
    }
    
    func resetForm() {
        title = ""
        description = ""
        category = .other
        status = .lost
        location = ""
        reportedDate = Date()
        selectedPhotos = []
        selectedImages = []
        imageUrls = []
    }
}

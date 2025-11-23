import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    // MARK: - Picker Source (Camera or Library)
    enum Source {
        case camera
        case library
    }

    var source: Source = .camera
    var onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator

        // Set source type
        switch source {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
            } else {
                print("⚠️ Camera not available — falling back to photo library")
                picker.sourceType = .photoLibrary
            }
        case .library:
            picker.sourceType = .photoLibrary
        }

        picker.allowsEditing = false
        picker.mediaTypes = ["public.image"]
        return picker
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

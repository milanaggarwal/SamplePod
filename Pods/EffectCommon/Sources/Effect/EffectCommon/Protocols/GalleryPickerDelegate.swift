import UIKit

/// Enables showing image picker and its handling
/// 
public protocol GalleryPickerDelegate : AnyObject {
    func showImagePicker(includeVideos: Bool, includePhotos: Bool, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate)
    func dismissImagePicker(completion: (() -> Void)?)
}

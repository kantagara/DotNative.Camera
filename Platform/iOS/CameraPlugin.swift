import Foundation
import UIKit

@MainActor
final class CameraPlugin: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    private static var instance: CameraPlugin?
    static func register() {
        if instance == nil {
            instance = CameraPlugin()
        }
    }
    private var picker: UIImagePickerController?
    private var pending: PluginReply?
    private override init() {
        super.init()
        let channel = NativeChannels.channel("dotnative.camera")
        channel.onReset = {
            [weak self] in self?.finish(nil)
        }
        channel.handle("capturePhoto") {
            [weak self] _, reply in
            guard let self else {
                reply.failure("unavailable", "Camera plugin is unavailable")
                return
            }
            guard self.pending == nil else {
                reply.failure("busy", "A camera capture is already open")
                return
            }
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                reply.failure("unavailable", "Camera is unavailable on this device")
                return
            }
            guard let presenter = NativeChannels.presenter else {
                reply.failure("unavailable", "No active view controller is available")
                return
            }
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.cameraCaptureMode = .photo
            self.picker = picker
            self.pending = reply
            reply.onCancel = {
                [weak self] in self?.finish(nil)
            }
            presenter.present(picker, animated: true)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        finish(nil)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = info[.originalImage] as? UIImage else {
            finish(nil)
            return
        }
        let maxSide: CGFloat = 512
        let scale = min(1, maxSide / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: size)
        let data = renderer.jpegData(withCompressionQuality: 0.75) {
            _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        finish(data.count <= 900_000 ? data : nil)
    }

    private func finish(_ data: Data?) {
        let reply = pending
        pending = nil
        picker?.dismiss(animated: true)
        picker = nil
        if let data {
            reply?.success(.bytes(data))
        } else {
            reply?.success()
        }
    }
}

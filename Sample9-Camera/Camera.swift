//
//  Camera.swift
//  Sample9-Camera
//
//  Created by keiji yamaki on 2021/01/13.
//
/*
    カメラの使用方法
 @ObservedObject var camera = Camera()              // カメラ情報の初期設定
 CALayerView(caLayer: camera.previewLayer)          // カメラビューの表示
 camera.takePhoto()                                 // 撮影
 camera.image                                       // 撮影した画像
 */
import SwiftUI
import Combine
import AVFoundation

class Camera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    ///撮影した画像
    @Published var image: UIImage?
    ///プレビュー用レイヤー
    var previewLayer:AVCaptureVideoPreviewLayer!
    ///撮影開始フラグ
    private var _takePhoto:Bool = false
    ///セッション
    private let captureSession = AVCaptureSession()
    ///撮影デバイス
    private var capturepDevice:AVCaptureDevice!

    override init() {
        super.init()
        prepareCamera()
        beginSession()
    }

    func takePhoto() {
        _takePhoto = true
    }

    private func prepareCamera() {
        captureSession.sessionPreset = .photo

        if let availableDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first {
            capturepDevice = availableDevice
        }
    }

    private func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: capturepDevice)

            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // カメラの向きを教える。
        /*
        if let orientation = self.convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}) {
            previewLayer.connection!.videoOrientation = orientation
        }
 */
        self.previewLayer = previewLayer

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]

        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }

        captureSession.commitConfiguration()

        let queue = DispatchQueue(label: "FromF.github.com.AVFoundationSwiftUI.AVFoundation")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }

    func startSession() {
        if captureSession.isRunning { return }
        captureSession.startRunning()
    }

    func endSession() {
        if !captureSession.isRunning { return }
        captureSession.stopRunning()
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if _takePhoto {
            _takePhoto = false
            if let image = getImageFromSampleBuffer(buffer: sampleBuffer) {
                DispatchQueue.main.async {
                    // カメラロールに写真を保存
                    self.image = image
                }
            }
        }
    }

    @objc func didFinishSavingImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer){
        if error != nil {
            print(error.code)
        }
    }

    private func getImageFromSampleBuffer (buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()

            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))

            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }

        return nil
    }
    /*
    func appOrientation() -> UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    // 画面の向きをコンバート
    func convertUIOrientation2VideoOrientation(f: () -> UIInterfaceOrientation) -> AVCaptureVideoOrientation? {
        let v = f()
        switch v {
        case UIInterfaceOrientation.unknown:
                return nil
            default:
                return ([
                    UIInterfaceOrientation.portrait: AVCaptureVideoOrientation.portrait,
                    UIInterfaceOrientation.portraitUpsideDown: AVCaptureVideoOrientation.portraitUpsideDown,
                    UIInterfaceOrientation.landscapeLeft: AVCaptureVideoOrientation.landscapeLeft,
                    UIInterfaceOrientation.landscapeRight: AVCaptureVideoOrientation.landscapeRight
                ])[v]
        }
    }
    //画面の回転にも対応したい時は viewWillTransitionToSize で同じく向きを教える。
    override func viewWillTransition(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        coordinator.animate(
            alongsideTransition: nil,
            completion: {(UIViewControllerTransitionCoordinatorContext) in
                //画面の回転後に向きを教える。
                if let orientation = self.convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}) {
                    videoPreviewLayer?.connection.videoOrientation = orientation
                }
            }
        )
    }
 */
}
// カメラを表示するビュー
struct CALayerView: UIViewControllerRepresentable {
    var caLayer:CALayer
    func makeUIViewController(context: UIViewControllerRepresentableContext<CALayerView>) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.layer.addSublayer(caLayer)
        caLayer.frame = viewController.view.layer.frame
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CALayerView>) {
        caLayer.frame = uiViewController.view.layer.frame
    }
}

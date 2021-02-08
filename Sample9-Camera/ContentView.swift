//
//  ContentView.swift
//  Sample9-Camera
//
//  Created by keiji yamaki on 2021/01/13.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var camera = Camera()   // カメラ情報の初期設定
    @State var imageShow = false            // カメラで撮影した画像を表示
    @State var cameraOn = false             // カメラの表示をON/OFF
    
    var body: some View {
        VStack {
            ZStack {
                // カメラビューの表示
                CALayerView(caLayer: camera.previewLayer)
                    // カメラの画像を撮影すると、画像を表示
                    .onChange(of: camera.image, perform: { value in
                        imageShow = true
                    })
                // カメラで撮影した画像を表示
                if imageShow {
                    Image(uiImage: camera.image!)
                        .onTapGesture {
                            imageShow = false
                        }
                }
            }
            HStack {
                Spacer()
                // カメラの機能をON・OFF
                Button(action: {
                    // カメラの向きを取得して、画面の向きを設定
                    guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
                                return
                            }
                    camera.previewLayer.connection?.videoOrientation = convertUIOrientation2VideoOrientation(interface: orientation)
                    
                    self.cameraOn.toggle()
                    if self.cameraOn {
                        self.camera.startSession()
                    } else{
                        self.camera.endSession()
                    }
                }) {
                    Text(cameraOn ? "カメラOFF" : "カメラON")
                    }
                Spacer()
                // 撮影
                if cameraOn {
                    Button(action: {    // カメラボタン
                        self.camera.takePhoto()
                    }) {
                        Image(systemName: "livephoto")
                            .resizable()
                            .scaledToFit()
                        }
                }
                Spacer()
            }.frame(height:50)
        }
    }
    // UIInterfaceOrientation -> AVCaptureVideoOrientationにConvert
    func convertUIOrientation2VideoOrientation(interface: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch interface {
            case UIInterfaceOrientation.portrait:
                return AVCaptureVideoOrientation.portrait
            case UIInterfaceOrientation.portraitUpsideDown:
                return AVCaptureVideoOrientation.portraitUpsideDown
            case UIInterfaceOrientation.landscapeLeft:
                return AVCaptureVideoOrientation.landscapeLeft
            case UIInterfaceOrientation.landscapeRight:
                return AVCaptureVideoOrientation.landscapeRight
            default:
                return AVCaptureVideoOrientation.portrait

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

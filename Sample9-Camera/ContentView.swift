//
//  ContentView.swift
//  Sample9-Camera
//
//  Created by keiji yamaki on 2021/01/13.
//

import SwiftUI

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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  Sample9-Camera
//
//  Created by keiji yamaki on 2021/01/13.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var camera = Camera()              // カメラ情報の初期設定
    
    var body: some View {
        CALayerView(caLayer: camera.previewLayer)          // カメラビューの表示
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

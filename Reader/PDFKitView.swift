//
//  PDFKitView.swift
//  Reader
//
//  Created by Suwat Saegauy on 11/24/21.
//

import SwiftUI

struct PDFKitView: View {
    
    var data: Data
    
    var body: some View {
        PDFKitRepresentedView(data: data)
            .onAppear {
                print("[reader] \(data)")
            }
    }
}

struct PDFKitView_Previews: PreviewProvider {
    
    static var previews: some View {
        let content = DownloadManager.shared.bundle(with: "sample") ?? Data()
        PDFKitView(data: content)
    }
}

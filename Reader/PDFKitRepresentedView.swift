//
//  PDFKitRepresentedView.swift
//  Reader
//
//  Created by Suwat Saegauy on 11/12/21.
//

import SwiftUI
import PDFKit

struct PDFKitRepresentedView: UIViewRepresentable {
    
    typealias UIViewType = PDFView
    
    let data: Data
    let singlePage: Bool
    
    init(data: Data, singlePage: Bool = false) {
        self.data = data
        self.singlePage = singlePage
    }
    
    func makeUIView(context _: UIViewRepresentableContext<PDFKitRepresentedView>) -> UIViewType {
        // Create a `PDFView` and set its `PDFDocument`.
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true)
        pdfView.pageBreakMargins = .zero
                
        if singlePage {
            pdfView.displayMode = .singlePage
        }
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: UIViewType, context _: UIViewRepresentableContext<PDFKitRepresentedView>) {
        pdfView.document = PDFDocument(data: data)
    }
}

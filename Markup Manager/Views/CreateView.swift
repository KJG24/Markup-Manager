//
//  CreateView.swift
//  Markup Manager
//
//  Created by Koby Grah on 12/9/22.
//

import SwiftUI
import UIKit
import PDFKit

struct CreateView: View {
    @State var isDocumentPickerShown = false
    @State var selectedDocumentURL: URL?
    @State var pdfDocument: PDFDocument?
    
    var body: some View {
        VStack {
            Button("Select PDF") {
                isDocumentPickerShown = true
            }
            if let pdfDocument = pdfDocument {
                PDFViewWrapper(pdfDocument: pdfDocument)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Button("Save PDF") {
                if let pdfDocument = pdfDocument, let documentURL = selectedDocumentURL {
                    savePDF(pdfDocument, from: documentURL)
                }
            }
        }
        .sheet(isPresented: $isDocumentPickerShown) {
            DocumentPicker(selectedDocumentURL: $selectedDocumentURL, pdfDocument: $pdfDocument)
        }
    }
    
    private func savePDF(_ pdfDocument: PDFDocument, from documentURL: URL) {
        do {
            let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentDirectoryURL.appendingPathComponent(documentURL.lastPathComponent)
            try pdfDocument.write(to: destinationURL)
            print("PDF saved successfully at: \(destinationURL.absoluteString)")
        } catch {
            print("Error saving PDF: \(error.localizedDescription)")
        }
    }
}

struct PDFViewWrapper: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: UIViewRepresentableContext<PDFViewWrapper>) -> UIView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PDFViewWrapper>) {
        guard let pdfView = uiView as? PDFView else { return }
        pdfView.document = pdfDocument
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedDocumentURL: URL?
    @Binding var pdfDocument: PDFDocument?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        documentPicker.delegate = context.coordinator
        documentPicker.modalPresentationStyle = .fullScreen
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedDocumentURL: $selectedDocumentURL, pdfDocument: $pdfDocument)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var selectedDocumentURL: URL?
        @Binding var pdfDocument: PDFDocument?
        
        init(selectedDocumentURL: Binding<URL?>, pdfDocument: Binding<PDFDocument?>) {
            _selectedDocumentURL = selectedDocumentURL
            _pdfDocument = pdfDocument
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedURL = urls.first else {
                return
            }
            
            selectedDocumentURL = selectedURL
            if let pdfDocument = PDFDocument(url: selectedURL) {
                self.pdfDocument = pdfDocument
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            selectedDocumentURL = nil
            pdfDocument = nil
        }
    }
}

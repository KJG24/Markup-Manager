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
    @State var folderName = ""
    
    var body: some View {
        VStack {
            TextField("Enter your project name:", text: $folderName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            Button("Select PDF") {
                isDocumentPickerShown = true
            }
            if let pdfDocument = pdfDocument {
                PDFViewWrapper(pdfDocument: pdfDocument)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Button("Save Project") {
                if let pdfDocument = pdfDocument, let documentURL = selectedDocumentURL {
                    savePDF(pdfDocument, from: documentURL, folderName: folderName)
                }
            }
        }
        .sheet(isPresented: $isDocumentPickerShown) {
            DocumentPicker(selectedDocumentURL: $selectedDocumentURL, pdfDocument: $pdfDocument)
        }
    }
    
    private func savePDF(_ pdfDocument: PDFDocument, from documentURL: URL, folderName: String) {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let folderURL = documentsDirectory.appendingPathComponent(folderName)
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            let destinationURL = folderURL.appendingPathComponent(documentURL.lastPathComponent)
            try pdfDocument.write(to: destinationURL)
            print("PDF saved successfully at: \(destinationURL.absoluteString)")
        } catch {
            print("Error saving PDF: \(error.localizedDescription)")
        }
    }
}

struct PDFViewWrapper: UIViewRepresentable {
    let pdfDocument: PDFDocument
    var onTap: ((CGPoint) -> Void)?
    var onPinTap: ((CGPoint) -> Void)?

    func makeUIView(context: UIViewRepresentableContext<PDFViewWrapper>) -> UIView {

        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.isUserInteractionEnabled = true
        
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(_:)))
        tapRecognizer.numberOfTapsRequired = 2
        pdfView.addGestureRecognizer(tapRecognizer)
        
        let pinTapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinTapGesture(_:)))
        pinTapRecognizer.require(toFail: tapRecognizer)
        pdfView.addGestureRecognizer(pinTapRecognizer)
        
        
        pdfView.document = pdfDocument
        return pdfView
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PDFViewWrapper>) {
        guard let pdfView = uiView as? PDFView else { return }
        pdfView.document = pdfDocument
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap, onPinTap: onPinTap)
    }
    
    class Coordinator: NSObject {
        var onTap: ((CGPoint) -> Void)?
        var onPinTap: ((CGPoint) -> Void)?
        
        init(onTap: ((CGPoint) -> Void)?, onPinTap: ((CGPoint) -> Void)?) {
            self.onTap = onTap
            self.onPinTap = onPinTap
        }
        
        @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
            let tapLocation = sender.location(in: sender.view)
            onTap?(tapLocation)
        }
        
        @objc func handlePinTapGesture(_ sender: UITapGestureRecognizer) {
            guard let pdfView = sender.view as? PDFView else { return }
            let tapLocation = sender.location(in: pdfView)
            print(tapLocation)
            
            // Create a red circle view
            let markerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            markerView.backgroundColor = .red
            markerView.layer.cornerRadius = 5
            
            // Set the center of the marker view to the tapped location
            markerView.center = tapLocation
            
            // Add the marker view as a subview to the PDF view
            pdfView.addSubview(markerView)
            
            // Call the onPinTap closure with the tapped location
            onPinTap?(tapLocation)
        }
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

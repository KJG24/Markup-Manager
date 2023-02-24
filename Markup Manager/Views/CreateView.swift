//
//  CreateView.swift
//  Markup Manager
//
//  Created by Koby Grah on 12/9/22.
//

import SwiftUI
import UIKit

struct CreateView: View {
    @State var isDocumentPickerShown = false
    @State var selectedDocumentURL: URL?
    
    var body: some View {
        VStack {
            Button("Select Document") {
                isDocumentPickerShown = true
            }
            if let documentURL = selectedDocumentURL {
                Text("Selected Document URL: \(documentURL.absoluteString)")
            }
        }
        .sheet(isPresented: $isDocumentPickerShown) {
            DocumentPicker(selectedDocumentURL: $selectedDocumentURL)
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedDocumentURL: URL?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
        documentPicker.delegate = context.coordinator
        documentPicker.modalPresentationStyle = .fullScreen
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedDocumentURL: $selectedDocumentURL)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var selectedDocumentURL: URL?
        
        init(selectedDocumentURL: Binding<URL?>) {
            _selectedDocumentURL = selectedDocumentURL
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedURL = urls.first else {
                return
            }
            
            selectedDocumentURL = selectedURL
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}


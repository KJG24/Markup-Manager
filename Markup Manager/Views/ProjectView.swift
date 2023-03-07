//
//  ProjectView.swift
//  Markup Manager
//
//  Created by Koby Grah on 12/9/22.
//

import SwiftUI
import PDFKit

struct ProjectView: View {
    let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    @State private var directories: [URL] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(directories, id: \.self) { directoryURL in
                    NavigationLink(destination: FolderView(directoryURL: directoryURL)) {
                        Text(directoryURL.lastPathComponent)
                    }
                }
                .onDelete(perform: deleteDirectory)
            }
            .navigationTitle("Projects")
        }
        .onAppear {
            directories = getDirectories()
        }
    }
    
    func getDirectories() -> [URL] {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            return contents.filter { (url) -> Bool in
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
                return isDirectory.boolValue
            }
        } catch {
            print("Error getting directories: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteDirectory(at offsets: IndexSet) {
        for offset in offsets {
            do {
                try FileManager.default.removeItem(at: directories[offset])
                directories.remove(at: offset)
            } catch {
                print("Error deleting directory: \(error.localizedDescription)")
            }
        }
    }
}

struct FolderView: View {
    let directoryURL: URL
    @State private var pdfFiles: [URL] = []

    var body: some View {
        List {
            ForEach(pdfFiles, id: \.self) { pdfFileURL in
                NavigationLink(destination: PDFViewWrapper(pdfDocument: PDFDocument(url: pdfFileURL)!, onPinTap: { tapLocation in
                    // Create a red circle view
                    let markerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                    markerView.backgroundColor = .red
                    markerView.layer.cornerRadius = 5
                    
                    // Set the center of the marker view to the tapped location
                    markerView.center = tapLocation
                    
                    // Add the marker view as a subview to the PDF view
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let pdfView = windowScene.windows.first?.rootViewController?.view.subviews.first(where: { $0 is PDFView }) as? PDFView {
                        // Do something with pdfView
                        pdfView.addSubview(markerView)
                    }
                })) {
                    Text(pdfFileURL.lastPathComponent)
                }
            }
            .onDelete(perform: deletePDFFile)
        }
        .navigationTitle(directoryURL.lastPathComponent)
        .onAppear(perform: loadPDFFiles)
    }

    func loadPDFFiles() {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            pdfFiles = contents.filter { (url) -> Bool in
                return url.pathExtension.lowercased() == "pdf"
            }
        } catch {
            print("Error getting PDF files: \(error.localizedDescription)")
        }
    }

    func deletePDFFile(at offsets: IndexSet) {
        for index in offsets {
            let pdfFileURL = pdfFiles[index]
            do {
                try FileManager.default.removeItem(at: pdfFileURL)
                pdfFiles.remove(at: index)
            } catch {
                print("Error deleting PDF file: \(error.localizedDescription)")
            }
        }
    }
}



/*
class PDFKitRepresentedView: UIView {
    let pdfView: PDFView

    init(_ pdfView: PDFView) {
        self.pdfView = pdfView
        super.init(frame: .zero)
        addSubview(pdfView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pdfView.frame = bounds
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectView()
    }
}
*/

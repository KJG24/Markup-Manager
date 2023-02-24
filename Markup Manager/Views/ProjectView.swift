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

    var body: some View {
        NavigationView {
            List(getDirectories(), id: \.self) { directoryURL in
                NavigationLink(destination: FolderView(directoryURL: directoryURL)) {
                    Text(directoryURL.lastPathComponent)
                }
            }
            .navigationTitle("Projects")
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
}

struct FolderView: View {
    let directoryURL: URL

    var body: some View {
        List(getPDFFiles(), id: \.self) { pdfFileURL in
            NavigationLink(destination: PDFViewWrapper(pdfDocument: PDFDocument(url: pdfFileURL)!)) {
                Text(pdfFileURL.lastPathComponent)
            }
        }
        .navigationTitle(directoryURL.lastPathComponent)
    }

    func getPDFFiles() -> [URL] {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            return contents.filter { (url) -> Bool in
                return url.pathExtension.lowercased() == "pdf"
            }
        } catch {
            print("Error getting PDF files: \(error.localizedDescription)")
            return []
        }
    }
}


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

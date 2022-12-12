//
//  GetFile.swift
//  Markup Manager
//
//  Created by Koby Grah on 12/12/22.
//

import SwiftUI

struct GetFile: View {
    let documentPicker =
        UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
    documentPicker.delegate = self
    documentPicker.directoryURL = [.Users]
    present(selectFile, animated: true, completion: nil)
    var body: some View {
        Text("Hello")
    }
}

struct GetFile_Previews: PreviewProvider {
    static var previews: some View {
        GetFile()
    }
}

//
//  ProjectView.swift
//  Markup Manager
//
//  Created by Koby Grah on 12/9/22.
//

import SwiftUI

struct ProjectView: View {
    let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    var body: some View {
        List {
            ForEach(getDirectories(), id: \.self) { directoryURL in
                Text(directoryURL.lastPathComponent)
            }
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


struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectView()
    }
}

//
//  CreateView.swift
//  Markup Manager
//
//  Created by Koby Grah on 12/9/22.
//

import SwiftUI

struct CreateView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: GetFile()) {
                    Text("Select a file")
                        .padding()
                }
            }
        }
    }
}
struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView()
    }
}

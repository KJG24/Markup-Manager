//
//  ContentView.swift
//  Markup Manager
//
//  Created by Koby Grah on 12/9/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: ProjectView()) {
                    Text("View existing Projects")
                        .padding()
                        }
                NavigationLink(destination: CreateView()) {
                    Text("Create a new project")
                        .padding()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

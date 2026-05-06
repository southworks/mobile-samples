//
//  ContentView.swift
//  common_ui
//
//  Created by ec2-user on 5/6/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BasicsMenuView()
                .tabItem {
                    Label("Basics", systemImage: "sparkles")
                }

            LayoutMenuView()
                .tabItem {
                    Label("Layout", systemImage: "square.grid.3x3")
                }

            NavigationExamplesMenuView()
                .tabItem {
                    Label("Navigation", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                }

            InputsMenuView()
                .tabItem {
                    Label("Inputs", systemImage: "slider.horizontal.3")
                }
        }
    }
}

#Preview {
    ContentView()
}

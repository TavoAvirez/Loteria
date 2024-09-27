//
//  LoteriaApp.swift
//  Loteria
//
//  Created by Gustavo Juarez on 19/09/24.
//

import SwiftUI

@main
struct LoteriaApp: App {
    @State var showTutorial = true
    var body: some Scene {
        WindowGroup {
            if showTutorial {
                TutorialView(showTutorial: $showTutorial)
            } else {
                ContentView()
            }
        }
    }
}

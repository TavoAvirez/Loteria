//
//  LoteriaApp.swift
//  Loteria
//
//  Created by Gustavo Juarez on 19/09/24.
//

import SwiftUI

@main
struct LoteriaApp: App {
    @StateObject var gameModel = GameModel()

    var body: some Scene {
        WindowGroup {
            if gameModel.options.enableTutorial {
                TutorialView(showTutorial: $gameModel.options.enableTutorial, gameOptions: gameModel.options)
            } else {
                ContentView()
            }
        }
    }
}

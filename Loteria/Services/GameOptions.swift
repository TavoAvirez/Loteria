//
//  GameOptions.swift
//  Loteria
//
//  Created by Gustavo Juarez on 14/10/24.
//

import Foundation
import Combine


class GameOptions: ObservableObject {
    @Published var changeInterval: TimeInterval {
        didSet {
            saveToUserDefaults()
        }
    }
    
    @Published var soundEnabled: Bool {
        didSet {
            saveToUserDefaults()
        }
    }

    @Published var enableTutorial: Bool {
        didSet {
            saveToUserDefaults()
        }
    }
    
    init(changeInterval: TimeInterval, soundEnabled: Bool, enableTutorial: Bool) {
        self.changeInterval = changeInterval
        self.soundEnabled = soundEnabled
        self.enableTutorial = enableTutorial
        saveToUserDefaults()
    }

    // Guardar las opciones en UserDefaults
    func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(changeInterval, forKey: "changeInterval")
        defaults.set(soundEnabled, forKey: "soundEnabled")
        defaults.set(enableTutorial, forKey: "enableTutorial")
    }

    // Cargar las opciones desde UserDefaults
    static func loadFromUserDefaults() -> GameOptions {
        let defaults = UserDefaults.standard
        let changeInterval = defaults.double(forKey: "changeInterval") != 0 ? defaults.double(forKey: "changeInterval") : 3.0
        let soundEnabled = defaults.bool(forKey: "soundEnabled")
        let enableTutorial = defaults.bool(forKey: "enableTutorial")
        return GameOptions(changeInterval: changeInterval, soundEnabled: soundEnabled, enableTutorial: enableTutorial)
    }
}

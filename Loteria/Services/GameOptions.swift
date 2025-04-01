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
    
    @Published var queueSounds: Bool { // Nueva opción para encolar sonidos
        didSet {
            saveToUserDefaults()
        }
    }
    
    init(changeInterval: TimeInterval = 5.0, soundEnabled: Bool = true, enableTutorial: Bool = true, queueSounds: Bool = true) {
        self.changeInterval = changeInterval
        self.soundEnabled = soundEnabled
        self.enableTutorial = enableTutorial
        self.queueSounds = queueSounds
        saveToUserDefaults()
    }

    // Guardar las opciones en UserDefaults
    func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(changeInterval, forKey: "changeInterval")
        defaults.set(soundEnabled, forKey: "soundEnabled")
        defaults.set(enableTutorial, forKey: "enableTutorial")
        defaults.set(queueSounds, forKey: "queueSounds") // Guardar la opción de encolar sonidos
    }

    // Cargar las opciones desde UserDefaults
    static func loadFromUserDefaults() -> GameOptions {
        let defaults = UserDefaults.standard
        let changeInterval = defaults.double(forKey: "changeInterval") != 0 ? defaults.double(forKey: "changeInterval") : 5.0
        let soundEnabled = defaults.object(forKey: "soundEnabled") != nil ? defaults.bool(forKey: "soundEnabled") : true
        let enableTutorial = defaults.object(forKey: "enableTutorial") != nil ? defaults.bool(forKey: "enableTutorial") : true
        let queueSounds = defaults.object(forKey: "queueSounds") != nil ? defaults.bool(forKey: "queueSounds") : true  // Valor por defecto en true
        return GameOptions(changeInterval: changeInterval, soundEnabled: soundEnabled, enableTutorial: enableTutorial, queueSounds: queueSounds)
    }
}

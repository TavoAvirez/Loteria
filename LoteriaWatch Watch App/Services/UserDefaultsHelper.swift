//
//  UserDefaultsHelper.swift
//  Loteria
//
//  Created by Gustavo Juarez on 14/10/24.
//

import Foundation

struct StoredGameOptions: Codable {
    var changeInterval: TimeInterval
    var soundEnabled: Bool
    var enableTutorial: Bool
}

class UserDefaultsHelper {
    static let shared = UserDefaultsHelper()

    private let gameOptionsKey = "gameOptions"

    // Guardar las opciones del juego
    func saveGameOptions(_ options: StoredGameOptions) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(options) {
            UserDefaults.standard.set(encoded, forKey: gameOptionsKey)
        }
    }

    // Cargar las opciones del juego
    func loadGameOptions() -> StoredGameOptions {
        if let savedOptions = UserDefaults.standard.object(forKey: gameOptionsKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedOptions = try? decoder.decode(StoredGameOptions.self, from: savedOptions) {
                return loadedOptions
            }
        }
        // Devuelve valores predeterminados si no hay opciones guardadas
        return StoredGameOptions(changeInterval: 3.0, soundEnabled: true, enableTutorial: true)
    }
}

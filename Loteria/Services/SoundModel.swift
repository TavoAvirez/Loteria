//
//  SoundModel.swift
//  Loteria
//
//  Created by Gustavo Juarez on 15/10/24.
//

import Foundation
import AVFoundation

class SoundModel: NSObject, AVAudioPlayerDelegate {
    let soundName: String
    var soundEnabled: Bool
    var initialSound: Bool
    var formatType: String
    weak var gameModel: GameModel?
    var audioPlayer: AVAudioPlayer?
    
    init(soundName: String, soundEnabled: Bool, initialSound: Bool = false, gameModel: GameModel, formatType: String = "m4a") {
        self.soundName = soundName
        self.soundEnabled = soundEnabled
        self.initialSound = initialSound
        self.gameModel = gameModel
        self.formatType = formatType
        
        super.init()
        
        if soundEnabled {
            // Verifica si los sonidos deben encolarse o reproducirse inmediatamente
            if gameModel.options.queueSounds {
                print("encolado")
                SoundQueue.shared.enqueueSound(named: soundName, formatType: formatType, initialSound: initialSound, gameModel: gameModel)
            } else {
//                print("inmediato")
                // Si no se deben encolar, reproduce el sonido inmediatamente
                playSoundImmediately(named: soundName, formatType: formatType)
            }
        }
    }
    
    func playSoundImmediately(named soundName: String, formatType: String) {
        if let path = Bundle.main.path(forResource: soundName, ofType: formatType) {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error al reproducir el sonido: \(error)")
            }
        } else {
            print("Archivo de sonido no encontrado: \(soundName).")
        }
    }
}

class SoundQueue: NSObject, AVAudioPlayerDelegate {
    static let shared = SoundQueue()
    private var soundQueue: [(player: AVAudioPlayer, initialSound: Bool, gameModel: GameModel?)] = []
    private var isPlaying = false
    
    func enqueueSound(named soundName: String, formatType: String = "m4a", initialSound: Bool = false, gameModel: GameModel? = nil) {
        if let path = Bundle.main.path(forResource: soundName, ofType: formatType) {
            let url = URL(fileURLWithPath: path)
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.delegate = self
                soundQueue.append((player: player, initialSound: initialSound, gameModel: gameModel))
                playNextSound()
            } catch {
                print("Error al cargar el sonido: \(error)")
            }
        } else {
            print("Archivo de sonido no encontrado: \(soundName).")
        }
    }
    
    private func playNextSound() {
        if !isPlaying, let nextSound = soundQueue.first {
            isPlaying = true
            nextSound.player.play()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("Se ha reproducido el sonido \(player.url?.lastPathComponent ?? "desconocido")")
            
            // Verifica si es el sonido inicial y cambia la carta si es necesario
            if let currentSound = soundQueue.first, currentSound.initialSound {
                currentSound.gameModel?.changeCard()
            }
        }
        
        // Remover el sonido que terminó de reproducirse de la cola
        soundQueue.removeFirst()
        isPlaying = false
        
        // Reproduce el siguiente sonido
        playNextSound()
    }
}

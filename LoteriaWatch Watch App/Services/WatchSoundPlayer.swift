//
//  SoundPlayer.swift
//  Loteria
//
//  Created by Gustavo Juarez on 24/09/24.
//

import AVFoundation

class WatchSoundPlayer: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    func stopSound ()  {
        if let audioPlayer {
            audioPlayer.stop()
        }
    }
    

    func playSound(named soundName: String, formatType: String = "m4a") {

        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: formatType) else {
            print("Sound file not found: \(soundName).\(formatType)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay() // Prepara el audio para la reproducción

            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}

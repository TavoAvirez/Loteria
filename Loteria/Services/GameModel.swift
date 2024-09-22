//
//  GameModel.swift
//  Loteria
//
//  Created by Gustavo Juarez on 22/09/24.
//

import Combine
import SwiftUI
import AVFoundation

class GameModel: ObservableObject {
    @Published var cartasUsadas: [Carta] = []
    @Published var gameStarted = false
    @Published var gamePaused = false
    @Published var changeInterval: TimeInterval = 3
    @Published var loteriaCartasEnJuego: [Carta] = []
    @Published var showImage = false
    @Published var cardName: String = ""
    // Propiedad para manejar el sonido
    @Published var soundModel: SoundModel?
    @Published var showOptions = false
    @Published var progress: CGFloat = 0.0
    
    var timer: AnyCancellable?
    var timerRectangle: Timer?
    var timeRemaining: TimeInterval = 0
    
    
    
    struct Carta: Identifiable, Equatable{
        let id = UUID() // Identificador único
        let nombre: String
    }
    
    
    
    
    // Lista de cartas completas
    @Published var loteriaCartasCompletas = [
        Carta(nombre: "alacran"), Carta(nombre: "apache"), Carta(nombre: "arana"),
        Carta(nombre: "arbol"), Carta(nombre: "arpa"), Carta(nombre: "bandera"),
        Carta(nombre: "bandolon"), Carta(nombre: "barril"), Carta(nombre: "bota"),
        Carta(nombre: "borracho"), Carta(nombre: "botella"), Carta(nombre: "calavera"),
        Carta(nombre: "camaron"), Carta(nombre: "cantarito"), Carta(nombre: "campana"),
        Carta(nombre: "catrin"), Carta(nombre: "cazo"), Carta(nombre: "chalupa"),
        Carta(nombre: "corazon"), Carta(nombre: "corona"), Carta(nombre: "cotorro"),
        Carta(nombre: "dama"), Carta(nombre: "diablito"), Carta(nombre: "escalera"),
        Carta(nombre: "estrella"), Carta(nombre: "gallo"), Carta(nombre: "garza"),
        Carta(nombre: "gorrito"), Carta(nombre: "jaras"), Carta(nombre: "luna"),
        Carta(nombre: "maceta"), Carta(nombre: "mano"), Carta(nombre: "melon"),
        Carta(nombre: "muerte"), Carta(nombre: "mundo"), Carta(nombre: "musico"),
        Carta(nombre: "negrito"), Carta(nombre: "nopal"), Carta(nombre: "pajaro"),
        Carta(nombre: "palma"), Carta(nombre: "paraguas"), Carta(nombre: "pera"),
        Carta(nombre: "pescado"), Carta(nombre: "pino"), Carta(nombre: "rana"),
        Carta(nombre: "rosa"), Carta(nombre: "sandia"), Carta(nombre: "sirena"),
        Carta(nombre: "sol"), Carta(nombre: "soldado"), Carta(nombre: "tambor"),
        Carta(nombre: "valiente"), Carta(nombre: "venado"), Carta(nombre: "violoncello")
    ]
    
    
    // Este método se llama para reiniciar las cartas en juego
    func resetGame() {
        stopTimer()
        stopTimerRectangle()
        showImage = false
        gameStarted = false
        gamePaused = false
        timeRemaining = changeInterval
        progress = 0.0 // Reinicia el progreso
        
        cartasUsadas.removeAll()
        loteriaCartasEnJuego = loteriaCartasCompletas.map { Carta(nombre: $0.nombre) }
        
    }
    
    func stopTimer() {
        gameStarted = false
        timer?.cancel() // Detén el temporizador
        timer = nil // Limpia el temporizador
    }
    
    func stopTimerRectangle() {
        timerRectangle?.invalidate()
        timerRectangle = nil
    }
    
    func startTimerRectangle() {
        // Asegúrate de que el progreso comience en 0
        self.progress = 0.0

        // Detén cualquier temporizador anterior antes de iniciar uno nuevo
        stopTimerRectangle()

        // Inicializa el temporizador con el intervalo adecuado para el progreso
        let step = 0.01 // El progreso aumentará en pasos de 1%
        let interval = changeInterval * step // Define el intervalo en función de la duración total
        
        timerRectangle = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            if self.progress < 1.0 {
                self.progress += step // Incrementa el progreso gradualmente
            } else {
                self.stopTimerRectangle() // Detiene el temporizador cuando el progreso llega al 100%
            }
        }
    }
    
    struct SoundModel {
        let soundName: String
        var bombSoundEffect: AVAudioPlayer?
        
        init(soundName: String) {
            self.soundName = soundName
            
            if let path = Bundle.main.path(forResource: soundName, ofType: "m4a") {
                let url = URL(fileURLWithPath: path)
                
                do {
                    bombSoundEffect = try AVAudioPlayer(contentsOf: url)
                    bombSoundEffect?.prepareToPlay() // Prepara el sonido para la reproducción
                } catch {
                    print("Error al cargar el sonido: \(error)")
                }
            } else {
                print("Archivo de sonido no encontrado para \(soundName).")
            }
        }
        
        func playSound() {
            bombSoundEffect?.play() // Reproduce el sonido
        }
    }
    
    func startTimer() {
        self.gameStarted = true
        self.timeRemaining = self.changeInterval // Reinicia el tiempo restante
        self.startTimerRectangle()
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    withAnimation {
                        self.showImage = false // Oculta la imagen actual
                        
                        // Espera un pequeño tiempo para la transición de ocultar antes de mostrar la nueva imagen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let cartaAleatoria = self.randomElement(from: &self.loteriaCartasEnJuego) {
                                self.startTimerRectangle()
                                self.cardName = cartaAleatoria.nombre
                                self.cartasUsadas.append(cartaAleatoria) // Agrega la carta utilizada al array
                                
                                // Muestra la nueva imagen
                                self.showImage = true
                                
                                // Inicializa el modelo de sonido y reproduce el sonido
                                self.soundModel = SoundModel(soundName: self.cardName) // Cambia aquí el nombre del sonido
                                self.soundModel?.playSound()
                            } else {
                                // Si no hay más cartas, asegúrate de mostrar la última imagen y reproducir el sonido
                                if let lastCard = self.cartasUsadas.last {
                                    self.cardName = lastCard.nombre
                                    self.showImage = true
                                    
                                    // Reproduce el sonido de la última carta
                                    self.soundModel = SoundModel(soundName: self.cardName)
                                    self.soundModel?.playSound()
                                }
                                self.stopTimer()
                            }
                            self.timeRemaining = self.changeInterval // Reinicia el tiempo restante
                        }
                    }
                }
            }
    }

    
    
    func randomElement(from array: inout [Carta]) -> Carta? {
        guard !array.isEmpty else { return nil }
        return array.remove(at: Int.random(in: 0..<array.count)) // Elimina y devuelve una carta aleatoria
    }
    
    func pauseGame() {
        gamePaused = true
        stopTimer()
        stopTimerRectangle()
    }
    
    func continueGame() {
        gamePaused = false
        startTimer()
        startTimerRectangle()
    }
    
    // Otros métodos que manejen la lógica del juego...
}

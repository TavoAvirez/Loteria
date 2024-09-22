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
    
    @Published var options: GameOptions
    
    var gameOptions = GameOptions(
        changeInterval: 3.0,     // Intervalo de cambio de carta
        soundEnabled: true      // Sonido activado
    )
    
    @Published var cartasUsadas: [Carta] = []
    @Published var gameStarted = false
    @Published var gamePaused = false
    
    @Published var loteriaCartasEnJuego: [Carta] = []
    @Published var showImage = false
    @Published var cardName: String = ""
    // Propiedad para manejar el sonido
    @Published var soundModel: SoundModel?
    @Published var showTimerModal = false
    @Published var showOptionsModal = false
    @Published var progress: CGFloat = 0.0
    
    var timer: AnyCancellable?
    var timerRectangle: Timer?
    var timeRemaining: TimeInterval = 0
    
    init(options: GameOptions) {
        self.options = options
    }
    
    
    struct Carta: Identifiable, Equatable{
        let id = UUID() // Identificador único
        let nombre: String
    }
    
    struct GameOptions {
        var changeInterval: TimeInterval
        var soundEnabled: Bool
        
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
        timeRemaining = gameOptions.changeInterval
        progress = 0.0 // Reinicia el progreso
        
        cartasUsadas.removeAll()
        loteriaCartasEnJuego = loteriaCartasCompletas.map { Carta(nombre: $0.nombre) }
        
    }
    
    func stopTimer() {
        gameStarted = false
        timer?.cancel() // Detén el temporizador
        timer = nil // Limpia el temporizador
    }
    
    
    
    
    class SoundModel: NSObject, AVAudioPlayerDelegate {
        let soundName: String
        var bombSoundEffect: AVAudioPlayer?
        var soundEnabled: Bool // Pasar esta configuración desde GameModel
        var initialSound: Bool // Sonido inicial
        
        weak var gameModel: GameModel? // Referencia al GameModel para poder llamar a changeCard()

        init(soundName: String, soundEnabled: Bool, initialSound: Bool = false, gameModel: GameModel) {
            self.soundName = soundName
            self.soundEnabled = soundEnabled
            self.initialSound = initialSound
            self.gameModel = gameModel // Pasar el GameModel al inicializar

            super.init() // Llama a super.init() ya que estamos usando NSObject

            if let path = Bundle.main.path(forResource: soundName, ofType: "m4a") {
                let url = URL(fileURLWithPath: path)
                
                do {
                    bombSoundEffect = try AVAudioPlayer(contentsOf: url)
                    bombSoundEffect?.prepareToPlay() // Prepara el sonido para la reproducción
                    bombSoundEffect?.delegate = self // Establece el delegado
                } catch {
                    print("Error al cargar el sonido: \(error)")
                }
            } else {
                print("Archivo de sonido no encontrado para \(soundName).")
            }
        }
        
        func playSound() {
            if soundEnabled {
                bombSoundEffect?.play() // Reproduce el sonido
            }
        }

        // Método delegado que se llama cuando el sonido termina de reproducirse
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            if flag {
                if initialSound {
                    gameModel?.changeCard()
                }
                print("El sonido \(soundName) ha terminado de reproducirse correctamente.")
            } else {
                print("El sonido \(soundName) no terminó correctamente.")
            }
        }
    }
    
    func stopTimerRectangle() {
        timerRectangle?.invalidate()
        timerRectangle = nil
    }
    
    func startTimerRectangle() {
        stopTimerRectangle() // Detener cualquier temporizador activo
        
        // Reiniciar el progreso a 0.0 al iniciar el temporizador
        self.progress = 0.0
        
        // Establecer el tiempo total de la duración
        let totalTime = gameOptions.changeInterval
        let step = 0.01
        let totalSteps = Int(1.0 / step) // Número total de pasos para completar el progreso
        let interval = totalTime / Double(totalSteps) // Intervalo para cada paso
        
        timerRectangle = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            if self.progress < 1.0 {
                self.progress += step // Incrementa el progreso de manera gradual
            } else {
                self.stopTimerRectangle() // Detén el temporizador al llegar a 100%
            }
        }
    }
    
    func startTimer() {
        self.gameStarted = true
        
        // Si el juego estaba en pausa, continúa desde donde quedó
        if gamePaused {
            gamePaused = false
            startTimerRectangle() // Continúa el progreso visual
        } else {
            self.timeRemaining = self.gameOptions.changeInterval // Reiniciar el temporizador si es un nuevo juego
            self.progress = 0.0 // Reiniciar el progreso visual
            startTimerRectangle()
        }
        
        // Iniciar o continuar el temporizador del juego
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.changeCard() // Llamar a la nueva función para cambiar la carta
                }
            }
    }
    
    func changeCard() {

        withAnimation {
            self.showImage = false // Ocultar la imagen actual
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let cartaAleatoria = self.randomElement(from: &self.loteriaCartasEnJuego) {
                    self.cardName = cartaAleatoria.nombre
                    self.cartasUsadas.append(cartaAleatoria) // Agregar carta usada
                    
                    // Mostrar la nueva carta
                    self.showImage = true
                    
                    // Reiniciar el progreso visual
                    self.progress = 0.0 // Reiniciar el progreso
                    self.startTimerRectangle() // Reiniciar el progreso visual aquí
                    
                    // Reproducir el sonido asociado
                    self.soundModel = SoundModel(soundName: self.cardName, soundEnabled: self.options.soundEnabled, gameModel: self)
                    self.soundModel?.playSound()
                } else {
                    // Si no quedan cartas, muestra la última y reproduce el sonido
                    if let lastCard = self.cartasUsadas.last {
                        self.cardName = lastCard.nombre
                        self.showImage = true
                        
                        self.soundModel = SoundModel(soundName: self.cardName, soundEnabled: self.options.soundEnabled, gameModel: self)
                        self.soundModel?.playSound()
                    }
                    self.stopTimer() // Detén el temporizador
                }
                
                // Reiniciar el temporizador
                self.timeRemaining = self.gameOptions.changeInterval
            }
        }
    }
    
    
    
    
    
    
    func randomElement(from array: inout [Carta]) -> Carta? {
        guard !array.isEmpty else { return nil }
        return array.remove(at: Int.random(in: 0..<array.count)) // Elimina y devuelve una carta aleatoria
    }
    
    
    
    
    func pauseGame() {
        gamePaused = true
        stopTimer() // Pausa el temporizador del juego
        stopTimerRectangle() // Pausa el progreso del rectángulo
    }
    
    func continueGame() {
        if gamePaused {
            gamePaused = false
            startTimer() // Continúa el temporizador del juego
            startTimerRectangle() // Continúa el progreso del rectángulo
        }
    }
    
    // Otros métodos que manejen la lógica del juego...
}

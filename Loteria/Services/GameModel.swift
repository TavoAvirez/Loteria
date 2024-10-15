//
//  GameModel.swift
//  Loteria
//
//  Created by Gustavo Juarez on 22/09/24.
//

import Combine
import SwiftUI
import AVFoundation


class GameModel: ObservableObject{
    @Published var options: GameOptions
    @Published var connectToWatchModel = ConnectToWatchModel()
    

    init() {
        
        self.options = GameOptions.loadFromUserDefaults()
        setupConnectToWatchModel()
       }               
    
    func setupConnectToWatchModel() {
        connectToWatchModel.setupWithGameModel(self)
    }

    
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
//    @Published var progressBackup: CGFloat = 0.0
    
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
        timeRemaining = options.changeInterval
        progress = 0.0 // Reinicia el progreso
        
        cartasUsadas.removeAll()
        loteriaCartasEnJuego = loteriaCartasCompletas.map { Carta(nombre: $0.nombre) }
        
    }
    
    func stopTimer() {
        timer?.cancel() // Detén el temporizador
        timer = nil // Limpia el temporizador
    }
                       
    func stopTimerRectangle() {
//        print("stop timer rectangle antes \(self.progress)")
        timerRectangle?.invalidate()
        timerRectangle = nil

        
//        print("stop timer rectangle despues \(self.progress)")
    }
    
    func startTimerRectangle() {
//        print("startTimerRectangle antes \(self.progress)")
        stopTimerRectangle() // Detener cualquier temporizador activo
        
        if !gamePaused {
            self.progress = 0.0 // Reiniciar el progreso a 0.0 al iniciar el temporizador
        }
//        print("startTimerRectangle despues \(self.progress)")

        gamePaused = false

        // Establecer el tiempo total de la duración según el nuevo intervalo
        let totalTime = options.changeInterval
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
        

       if !gamePaused {
           self.timeRemaining = self.options.changeInterval // Reiniciar el temporizador si es un nuevo juego
        }
                           
        startTimerRectangle() // Continúa el progreso visual

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
                    
                    self.stopTimer()
                    self.stopTimerRectangle()
                    self.cardName = cartaAleatoria.nombre
                    self.cartasUsadas.append(cartaAleatoria) // Agregar carta usada
                    
                    self.connectToWatchModel.sendCardNameToWatch(cardName: cartaAleatoria.nombre, gamePaused: self.gamePaused)
                    
                    // Mostrar la nueva carta
                    self.showImage = true
                    
                    // Reiniciar el progreso visual
                    self.progress = 0.0 // Reiniciar el progreso
                    self.startTimer() // Reiniciar el progreso visual aquí
                    // sonido de transicion de carta
                    self.soundModel = SoundModel(soundName: "deslizar1", soundEnabled: self.options.soundEnabled, gameModel: self, formatType: "mp3")
                    // Reproducir el sonido asociado
                    self.soundModel = SoundModel(soundName: self.cardName, soundEnabled: self.options.soundEnabled, gameModel: self)

                }
                else {
                    self.stopTimer() // Detén el temporizador
                }
                
                // Reiniciar el temporizador
                self.timeRemaining = self.options.changeInterval
            }
        }
    }
    
    
    
    
    
    
    func randomElement(from array: inout [Carta]) -> Carta? {
        guard !array.isEmpty else { return nil }
        return array.remove(at: Int.random(in: 0..<array.count)) // Elimina y devuelve una carta aleatoria
    }
    
    
    
    
    func pauseGame(messageFromWatch: Bool = false) {
        
        // Reproducir el sonido asociado
        self.soundModel = SoundModel(soundName: "pause1", soundEnabled: self.options.soundEnabled, gameModel: self, formatType: "mp3")

        gamePaused = true
        gameStarted = true
        if !messageFromWatch {
            connectToWatchModel.pauseGameToWatch(gamePaused: true)
        }
        stopTimer() // Pausa el temporizador del juego
        stopTimerRectangle() // Pausa el progreso del rectángulo
    }
    
    func continueGame(messageFromWatch: Bool = false) {
        // Reproducir el sonido asociado
        self.soundModel = SoundModel(soundName: "pause1", soundEnabled: self.options.soundEnabled, gameModel: self, formatType: "mp3")
        if !messageFromWatch {
            connectToWatchModel.pauseGameToWatch(gamePaused: false)
        }
        if gamePaused {
            startTimer() // Continúa el temporizador del juego
//            startTimerRectangle() // Continúa el progreso del rectángulo
        }
    }
    
    func startGame() {
        // Inicializa y reproduce el sonido de inicio
        if(self.options.soundEnabled){
            self.soundModel = .init(soundName: "inicio", soundEnabled: self.options.soundEnabled, initialSound: true, gameModel: self)
            
            self.connectToWatchModel.initialSoundToWatch()
        }
        
        // Inicia el temporizador después de reproducir el sonido
        self.startTimer()
    }
    
    // Otros métodos que manejen la lógica del juego...
}

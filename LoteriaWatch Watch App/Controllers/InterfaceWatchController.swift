//
//  InterfaceWatchController.swift
//  Loteria
//
//  Created by Gustavo Juarez on 24/09/24.
//
import SwiftUI
import WatchConnectivity
import AVFoundation

class InterfaceController: NSObject, ObservableObject, WCSessionDelegate {
    
    @Published var currentCard: String = "Sin carta" // Propiedad observada

    @Published var gamePaused: Bool = false

    @State private var soundPlayer = WatchSoundPlayer()
    

    
    var session: WCSession?
    
    override init() {
        super.init()
        
        // Configura la sesión de conectividad
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    // Método para manejar el contexto de la aplicación cuando se recibe desde el iPhone
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        for (key, value) in applicationContext {
            switch key {
            case "currentCard":
                if let cardName = value as? String {
                    DispatchQueue.main.async {
                        self.currentCard = cardName
                        self.soundPlayer.playSound(named: cardName)
                    }
                }

            case "gamePaused":
                if let gamePaused = value as? Bool {
                    DispatchQueue.main.async {
                        self.gamePaused = gamePaused
                        self.soundPlayer.playSound(named: "pause1", formatType: "mp3")
                    }
                }
                
            case "initialSound":
                if let initialSound = value as? Bool {
                    DispatchQueue.main.async {                        
                        self.soundPlayer.playSound(named: "inicio")
                    }
                }

            default:
                print("Clave no reconocida: \(key)")
            }
        }
    }
    
    // Método para pausar el juego en el iPhone
    func pauseGameOnPhone() {
        if let session = session, session.isReachable {
            session.sendMessage(["command": "pauseGame"], replyHandler: { response in
                if let status = response["status"] as? String, status == "gamePaused" {
                    DispatchQueue.main.async {
                        self.gamePaused = true
                        self.soundPlayer.playSound(named: "pause1", formatType: "mp3")
                        print("Juego pausado desde el Apple Watch.")
                    }
                }
            }, errorHandler: { error in
                print("Error enviando el comando de pausa: \(error.localizedDescription)")
            })
        }
    }

    // Método para continuar el juego en el iPhone
    func unPauseGameOnPhone() {
        if let session = session, session.isReachable {
            session.sendMessage(["command": "resumeGame"], replyHandler: { response in
                if let status = response["status"] as? String, status == "gameResumed" {
                    DispatchQueue.main.async {
                        self.gamePaused = false
                        self.soundPlayer.playSound(named: "pause1", formatType: "mp3")
                        print("Juego continuado desde el Apple Watch.")
                    }
                }
            }, errorHandler: { error in
                print("Error enviando el comando de reanudación: \(error.localizedDescription)")
            })
        }
    }
    
    // Método para cambiar de carta al deslizar
    func changeCard() {
        if let session = session, session.isReachable {
            session.sendMessage(["command": "changeCard"], replyHandler: { response in
                // Aquí puedes manejar cualquier respuesta que necesites
            }, errorHandler: { error in
                print("Error enviando el comando: \(error.localizedDescription)")
            })
        }
    }
    
    
    // Implementación de WCSessionDelegate para recibir mensajes desde el Watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let command = message["command"] as? String, command == "pauseGame" {
            // solo para cuando el comando sea pauseGame
            DispatchQueue.main.async {
//                self.gameModel?.pauseGame()
                print("Comando recibido desde el Watch: \(command)")
            }
        }
    }


    // Implementa los métodos obligatorios del delegado WCSession
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Error durante la activación: \(error.localizedDescription)")
        } else {
            print("Sesión activada con estado: \(activationState)")
        }
    }
    
    
    
    
}



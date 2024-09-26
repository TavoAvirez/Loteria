//
//  ConnectWatchModel.swift
//  Loteria
//
//  Created by Gustavo Juarez on 24/09/24.
//

import SwiftUI
import Foundation
import WatchConnectivity

class ConnectToWatchModel: NSObject, ObservableObject, WCSessionDelegate {
  
    @Published var isConnected: Bool = false
    var gameModel: GameModel?
    
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
    

    // Configura la relación con GameModel
    func setupWithGameModel(_ gameModel: GameModel) {
        self.gameModel = gameModel
    }

    
    // Función para enviar el nombre de la carta al Apple Watch
    // En el modelo de conectividad en la app iOS
    func sendCardNameToWatch(cardName: String, gamePaused: Bool) {
        if let validSession = session, validSession.isPaired, validSession.isWatchAppInstalled {
            let applicationContext = ["currentCard": cardName] as [String : Any]
            do {
                try validSession.updateApplicationContext(applicationContext)
            } catch {
                print("Error enviando el contexto de la aplicación: \(error.localizedDescription)")
            }
        } else {
            print("Watch app no instalada o no emparejada.")
        }
    }
    
    func pauseGameToWatch(gamePaused: Bool) {
        if let validSession = session, validSession.isPaired, validSession.isWatchAppInstalled {
            let applicationContext = ["gamePaused": gamePaused] as [String : Bool]
            do {
                try validSession.updateApplicationContext(applicationContext)
            } catch {
                print("Error enviando el contexto de la aplicación: \(error.localizedDescription)")

            }
        }
    }
    
    func initialSoundToWatch() {
        if let validSession = session, validSession.isPaired, validSession.isWatchAppInstalled {
            let applicationContext = ["initialSound": true] as [String: Bool]
            do {
                try validSession.updateApplicationContext(applicationContext)
            } catch {
                print("Error enviando el contexto de la aplicación: \(error.localizedDescription)")

            }
        }
    }
    
    func resetGameToWatch() {
        if let validSession = session, validSession.isPaired, validSession.isWatchAppInstalled {
            let applicationContext = ["resetGame": true] as [String: Bool]
            do {
                try validSession.updateApplicationContext(applicationContext)
            } catch {
                print("Error enviando el contexto de la aplicación: \(error.localizedDescription)")

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
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        isConnected = session.isReachable
        print("¿Conectado?: \(isConnected)")
    }
        func sessionDidBecomeInactive(_ session: WCSession) {}
        func sessionDidDeactivate(_ session: WCSession) {}
    
    
    // Recepcion de mensajes desde el apple watch
    // Recepción de mensajes desde el Apple Watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let command = message["command"] as? String {
            switch command {
            case "pauseGame":
                DispatchQueue.main.async {
                    self.gameModel?.pauseGame(messageFromWatch: true)
                    replyHandler(["status": "gamePaused"])
                }
            
            case "resumeGame":
                DispatchQueue.main.async {
                    self.gameModel?.continueGame(messageFromWatch: true)
                    replyHandler(["status": "gameResumed"])
                }
            
            case "changeCard":
                DispatchQueue.main.async {
                    self.gameModel?.changeCard()
                    replyHandler(["status": "cardChanged"])
                }
            case "startGame":
                DispatchQueue.main.async {
                    self.gameModel?.startGame()
                    replyHandler(["status": "gameStarted"])
                }

            default:
                print("Comando desconocido: \(command)")
                replyHandler(["status": "unknownCommand"])
            }
        }
    }
}

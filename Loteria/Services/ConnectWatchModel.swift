//
//  ConnectWatchModel.swift
//  Loteria
//
//  Created by Gustavo Juarez on 24/09/24.
//

import SwiftUI
import Foundation
import WatchConnectivity

class ConnectWatchModel: NSObject, ObservableObject, WCSessionDelegate {
  
    @Published var isConnected: Bool = false
    
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

    // Función para enviar el nombre de la carta al Apple Watch
    // En el modelo de conectividad en la app iOS
    func sendCardNameToWatch(cardName: String) {
        if let validSession = session, validSession.isPaired, validSession.isWatchAppInstalled {
            let applicationContext = ["currentCard": cardName]
            do {
                try validSession.updateApplicationContext(applicationContext)
            } catch {
                print("Error enviando el contexto de la aplicación: \(error.localizedDescription)")
            }
        } else {
            print("Watch app no instalada o no emparejada.")
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
}

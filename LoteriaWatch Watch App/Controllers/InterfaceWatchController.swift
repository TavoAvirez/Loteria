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
        if let cardName = applicationContext["currentCard"] as? String {
            DispatchQueue.main.async {
                self.currentCard = cardName
                self.soundPlayer.playSound(named: cardName)
                
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



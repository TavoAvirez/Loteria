//
//  ContentView.swift
//  Loteria
//
//  Created by Gustavo Juarez on 19/09/24.
//
import SwiftUI
import AVFoundation
import Combine

struct ContentView: View {
    // Inicializa el modelo del juego con opciones personalizadas usando @StateObject
    @StateObject private var gameModel: GameModel
    
    // Inicialización de la vista
    init() {
        // Define las opciones iniciales
        let initialOptions = GameModel.GameOptions(changeInterval: 1, soundEnabled: true)
        
        // Inicializa el StateObject con el GameModel y las opciones
        _gameModel = StateObject(wrappedValue: GameModel(options: initialOptions))
    }
    
    
    var body: some View {
        VStack {
            // Sección de cartas usadas
            UsedCards(gameModel: gameModel)
            Spacer()
            
            // Binding para actualizar las cartas usadas
            CardAppear(gameModel: gameModel)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(0)
        .background(.backgroundApp)
    }
}

struct CardAppear: View {
    @ObservedObject var gameModel: GameModel
    
    fileprivate func progressRectangule() -> some View {
        return RoundedRectangle(cornerRadius: 10)
            .trim(from: 0.0, to: gameModel.progress)
            .stroke(Color.timerRectangleBorder, lineWidth: 6.0)
            .animation(.linear, value: gameModel.progress)
        
    }
    
    var body: some View {
        let screenHeight = UIScreen.main.bounds.height
        
        GeometryReader { geometry in
            HStack {
                // Sección izquierda (Botón)
                VStack {
                    Button(action: {
                        if gameModel.gameStarted {
                            gameModel.pauseGame()
                        }
                        gameModel.showTimerModal = true
                    }) {
                        Image(systemName: "hourglass")
                            .frame(maxWidth: .infinity, maxHeight: 80)
                            .font(.largeTitle)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $gameModel.showTimerModal) {
                        TimerModal(gameModel: gameModel)
                    }
                    
                    if gameModel.gameStarted || gameModel.gamePaused {
                        Button(action: {
                            gameModel.resetGame()
                        }) {
                            Image(systemName: "repeat")
                                .frame(maxWidth: .infinity, maxHeight: 80)
                                .font(.largeTitle)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(width: 80)
                
                // Sección central (Contenido principal)
                VStack {
                    //                                    Text("\(geometry)")
                    if gameModel.showImage {
                        ZStack {
                            if screenHeight <= 926 { // iPhone 12 Pro Max, 13 Pro Max, 14 Plus, 14 Pro Max
                                progressRectangule()
                                    .frame(height: 50)
                            } else {
                                progressRectangule()
                                    .frame(height: 50) // Altura para dispositivos más grandes
                            }
                            
                            
                            Image(gameModel.cardName)
                                .resizable()
                                .scaledToFit()
                                .padding(.horizontal, 8)
                                .transition(.slide)
                                .onTapGesture {
                                    if gameModel.gameStarted {
                                        gameModel.pauseGame()
                                    } else {
                                        gameModel.continueGame()
                                    }
                                }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    Spacer()
                    if !gameModel.gameStarted && !gameModel.showImage {
                        Button(action: {
                            
                            // Inicializa y reproduce el sonido de inicio
                            if(gameModel.options.soundEnabled){
                                gameModel.soundModel = .init(soundName: "inicio", soundEnabled: gameModel.options.soundEnabled, initialSound: true, gameModel: gameModel)
                                gameModel.soundModel?.playSound()
                                
                                
                                
                            }
                            
                            // Inicia el temporizador después de reproducir el sonido
                            gameModel.startTimer()
                        }) {
                            Text("Iniciar")
                                .padding()
                                .background(.backgroundStartButton)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    } else {
                        Button(action: {
                            gameModel.changeCard()
                        }) {
                            Text("Siguiente")
                                .padding()
                                .background(.backgroundResetButton)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(0)
                //boton derecho
                VStack {
                    Button(action: {
                        gameModel.showOptionsModal = true
                    }) {
                        Image(systemName: "gear")
                            .frame(maxWidth: .infinity, maxHeight: 80)
                            .font(.largeTitle)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $gameModel.showOptionsModal) {
                        OptionsModal(gameModel: gameModel)
                    }
                }
                .padding(0)
                .frame(width: 70)
            }
            .onAppear {
                gameModel.resetGame()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


struct UsedCards: View {
    @ObservedObject var gameModel: GameModel // Usar el modelo existente
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(gameModel.cartasUsadas) { card in
                        Image(card.nombre) // Asegúrate de que las imágenes estén en tu proyecto
                            .resizable()
                            .frame(width: 100, height: 100) // Ajusta el tamaño según necesites
                            .padding(1) // Agrega un poco de espacio entre las imágenes
                            .shadow(radius: 5) // Añade una sombra para dar un efecto de profundidad
                            .id(card.id) // Asegúrate de que cada imagen tenga un ID único
                    }
                }
                .padding() // Agrega espacio alrededor del HStack
            }
            .frame(height: 120) // Ajusta la altura del ScrollView según sea necesario
            .onChange(of: gameModel.cartasUsadas) { _ in
                if let lastCard = gameModel.cartasUsadas.last {
                    withAnimation {
                        scrollProxy.scrollTo(lastCard.id, anchor: .trailing) // Desplaza hacia la última carta añadida
                    }
                }
            }
        }
    }
}



// modal de opciones del timer
struct TimerModal: View {
    @ObservedObject var gameModel: GameModel // Observa el modelo de juego
    @Environment(\.dismiss) var dismiss // Permite cerrar la vista modal
    
    var body: some View {
        NavigationView {
            List(1...15, id: \.self) { option in
                Button(action: {
                    gameModel.gameOptions.changeInterval = TimeInterval(option) // Asegúrate de que sea TimeInterval
                    gameModel.continueGame()
                    dismiss() // Cierra el modal al seleccionar una opción
                }) {
                    Text(String(option))
                }
            }
            .navigationTitle("Selecciona una Opción")
        }
    }
}

// Vista emergente de opciones
struct OptionsModal: View {
    @ObservedObject var gameModel: GameModel // Observa el modelo de juego
    @Environment(\.dismiss) var dismiss // Permite cerrar la vista modal
    
    var body: some View {
        NavigationView {
            Form {
                // Control deslizante para ajustar el intervalo de cambio de carta
                Section(header: Text("Intervalo de Cambio")) {
                    Slider(value: $gameModel.options.changeInterval, in: 1...10, step: 0.5) {
                        Text("Intervalo")
                    }
                }
                
                // Switch para habilitar/deshabilitar el sonido
                Section(header: Text("Sonido")) {
                    Toggle("Sonido Activado", isOn: $gameModel.options.soundEnabled)
                }
            }
            .navigationTitle("Opciones del Juego")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        // Aquí cerraríamos la vista emergente
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

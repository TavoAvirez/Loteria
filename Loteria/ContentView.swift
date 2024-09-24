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
    @State private var isVisible = true

    // Inicialización de la vista
    init() {
        // Define las opciones iniciales
        let initialOptions = GameModel.GameOptions(changeInterval: 5, soundEnabled: true)
        
        // Inicializa el StateObject con el GameModel y las opciones
        _gameModel = StateObject(wrappedValue: GameModel(options: initialOptions))
    }
    
    
    var body: some View {
        ZStack {
            // Contenido principal del juego
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
            
            // Pantalla de pausa superpuesta
            if gameModel.gamePaused {
                Color.black.opacity(0.6) // Cubre la pantalla con un fondo semitransparente
                    .ignoresSafeArea() // Asegura que cubra toda la pantalla
                    .onTapGesture {
                        gameModel.continueGame() // Al tocar, continua el juego
                    }
                
                VStack {
                    Text("Juego en Pausa")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .opacity(isVisible ? 1 : 0)
                                  .onAppear {
                                      withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                          isVisible.toggle()
                                      }
                                  }
                    Text("Toca para continuar")
                        .foregroundColor(.white)
                        .font(.title2)
                    
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    //                    Text("Height: \(screenHeight)")
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
                    
                    if gameModel.gameStarted || gameModel.gamePaused || gameModel.cartasUsadas.count == 54{
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
                            // ipad pro 13'
                            if screenHeight >= 1000 {
                                if geometry.size.width > geometry.size.height {
                                    //landscape
                                    progressRectangule()
                                        .frame(maxWidth: 470, maxHeight: 730)
                                } else {
                                    //portrait
                                    progressRectangule()
                                        .frame(width: 585, height: 915)
                                }
                                
                                // iPhone 11 Pro Max, iPhone 12/13/14 Pro Max
                            }else if screenHeight >= 896 {
                                progressRectangule()
                                    .frame(height: 410)
                                // iPhone X, iPhone 12/13/14, etc.
                            } else if screenHeight >= 812 {
                                progressRectangule()
                                    .frame(height: 350)
                            } else {
                                progressRectangule()
                                    .frame(height: 150)
                            }
                            
                            
                            
                            
                            // landscape
                            if geometry.size.width > geometry.size.height {
                               
                                Image(gameModel.cardName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 700)
                                    .padding(.horizontal, 8)
                                    .transition(.slide)
                                    .onTapGesture {
                                        if !gameModel.gamePaused {
                                            gameModel.pauseGame()
                                        }
                                    }
                            } else {
                                //portrait
                                
                                Image(gameModel.cardName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 900)
                                    .padding(.horizontal, 8)
                                    .transition(.slide)
                                    .onTapGesture {
                                        if !gameModel.gamePaused {
                                            gameModel.pauseGame()
                                        }
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
                        print("gameModel.gameStarted: \(gameModel.gameStarted)")
                        if gameModel.gameStarted {
                            gameModel.pauseGame()
                        }
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
                        // Reanudar el juego cuando el modal desaparece
                        OptionsModal(gameModel: gameModel)
                            .onDisappear {
                                gameModel.continueGame() // Reanudar el juego al cerrar el modal
                            }
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
        
        //        Text("Cartas restantes: \(gameModel.loteriaCartasEnJuego.count)")
        //        Text("Cartas usadas: \(gameModel.cartasUsadas.count)")
        //        Text("segundos: \(gameModel.options.changeInterval)")
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
                    gameModel.options.changeInterval = TimeInterval(option) // Asegúrate de que sea TimeInterval
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
                VStack {
                    // Control deslizante para ajustar el intervalo de cambio de carta
                    Section(header: Text("Intervalo de cambio de carta")) {
                        Slider(value: $gameModel.options.changeInterval, in: 1...15, step: 1) {
                            Text("Intervalo")
                        }
                    }
                    Text("Intervalo: \(Int(gameModel.options.changeInterval)) segundos")
                        .font(.subheadline) // Puedes ajustar el estilo del texto
                        .foregroundColor(.gray) // Color opcional para el texto
                    
                    
                }
                
                // Switch para habilitar/deshabilitar el sonido
                Section(header: Text("Sonido")) {
                    Toggle("Sonido Activado", isOn: $gameModel.options.soundEnabled)
                }
            }
            .navigationTitle("Opciones del Juego")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                    }) {
                        Text("Cerrar")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

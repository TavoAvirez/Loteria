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
    @StateObject private var gameModel = GameModel() // Asegúrate de que GameModel esté bien definido
    
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
    
    var body: some View {
        HStack {
            // Sección izquierda (Botón)
            VStack {
                Button(action: {
                    if gameModel.gameStarted {
                        gameModel.pauseGame()
                    }
                    gameModel.showOptions = true
                }) {
                    Image(systemName: "hourglass")
                        .frame(maxWidth: .infinity, maxHeight: 80)
                        .font(.largeTitle)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $gameModel.showOptions) {                    
                    OptionsView(gameModel: gameModel)
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
            .frame(width: 80, height:.infinity )

            // Sección central (Contenido principal)
            VStack {
                if gameModel.showImage {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                                 .trim(from: 0.0, to: gameModel.progress)
                                 .stroke(Color.blue, lineWidth: 6.0)
                                 .animation(.linear, value: gameModel.progress)
                                 .frame(maxWidth: .infinity, maxHeight: 349)
                   
                        Image(gameModel.cardName)
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 8)
                            .transition(.slide)
                            .onTapGesture {
                                if gameModel.gameStarted {
                                    gameModel.pauseGame()
                                } else {
                                    gameModel.startTimer()
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Spacer()
                if !gameModel.gameStarted && !gameModel.showImage {
                    Button(action: {
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
                        gameModel.resetGame()
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

             VStack {
                Button(action: {
                    // Acción para el botón izquierdo
                }) {
                    Rectangle()
                    
                    
                }
            }
            .padding(0)
            .frame(width: 70, height: .infinity )
        }
        .onAppear {
            gameModel.resetGame()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
struct OptionsView: View {
    @ObservedObject var gameModel: GameModel // Observa el modelo de juego
    @Environment(\.dismiss) var dismiss // Permite cerrar la vista modal
    
    var body: some View {
        NavigationView {
            List(1...15, id: \.self) { option in
                Button(action: {
                    gameModel.changeInterval = TimeInterval(option) // Asegúrate de que sea TimeInterval
                    dismiss() // Cierra el modal al seleccionar una opción
                }) {
                    Text(String(option))
                }
            }
            .navigationTitle("Selecciona una Opción")
            .navigationBarItems(trailing: Button("Cerrar") {
                dismiss() // Cierra el modal al presionar "Cerrar"
            })
        }
    }
}


#Preview {
    ContentView()
}

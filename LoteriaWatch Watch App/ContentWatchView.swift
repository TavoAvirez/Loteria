import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @StateObject private var interfaceController = InterfaceController()
    @StateObject private var soundPlayer = WatchSoundPlayer()
    @State private var isButtonRepeatDisabled = false // Variable de estado para controlar el estado del botón
    @State private var isButtonStartDisabled = false // Variable de estado para controlar el estado del botón

    @State private var isVisible = true
    
    var body: some View {
        ZStack {
            
            VStack {
            // Imagen principal
            ImageRenderView(interfaceController: interfaceController)
            
            
                Spacer() // Empuja los botones hacia abajo
                
                // Botones que se muestran según la carta actual
                if interfaceController.currentCard == "Sin carta" {
                    Button(action: {
                        print("button presed")
                        interfaceController.startGame()
                        isButtonRepeatDisabled = false
                        isButtonStartDisabled = true
                    }) {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30) // Tamaño del ícono del botón
                    }
                    .buttonStyle(PlainButtonStyle()) // Evita el estilo predeterminado del botón
                    .disabled(isButtonStartDisabled) // Deshabilita el botón si isButtonDisabled es true

                } else {
                    Button(action: {
                        isButtonRepeatDisabled = true
                        isButtonStartDisabled = false
                        interfaceController.resetGame()
                    }) {
                        Image(systemName: "repeat.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30) // Tamaño del ícono del botón
                    }
                    .buttonStyle(PlainButtonStyle()) // Evita el estilo predeterminado del botón
                    .disabled(isButtonRepeatDisabled) // Deshabilita el botón si isButtonDisabled es true

                }
            }
            
            // Pantalla de pausa superpuesta
            if interfaceController.gamePaused {
                Color.black.opacity(0.6) // Cubre la pantalla con un fondo semitransparente
                    .ignoresSafeArea() // Asegura que cubra toda la pantalla
                    .onTapGesture {
                        interfaceController.unPauseGameOnPhone() // Al tocar, continua el juego
                    }
                
                VStack {
                    Text("Juego en Pausa")
                        .font(.title2)
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
                        .font(.title3)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundApp)
     
    }
}

struct ImageRenderView: View {
    @ObservedObject var interfaceController: InterfaceController
    @ObservedObject var soundPlayer = WatchSoundPlayer()
    
    var body: some View {
        if interfaceController.currentCard != "Sin carta" {
            Image(interfaceController.currentCard)
                .resizable()
                .frame(maxWidth: 150, maxHeight: 300) // Imagen ocupa todo el espacio disponible
                .padding(.horizontal, 8)
                .transition(.slide)
                .onTapGesture {
                    interfaceController.pauseGameOnPhone()
                }.gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < 0 {
                                // Deslizar hacia la izquierda
                                interfaceController.changeCard()
                            }
                        }
                )
        } else {
            Text(interfaceController.currentCard)
        }
    }
}

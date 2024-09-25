import SwiftUI
import WatchConnectivity


struct ContentView: View {
    @StateObject private var interfaceController = InterfaceController()
    @StateObject private var soundPlayer = WatchSoundPlayer()
    
    @State private var isVisible = true
    
    var body: some View {
        ZStack {
            // Contenido principal del juego
            VStack {
                ImageRenderView(interfaceController: interfaceController)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(0)
            .background(.backgroundApp)
            
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
    }
}

struct ImageRenderView: View {
    @ObservedObject var interfaceController: InterfaceController
    @ObservedObject var soundPlayer = WatchSoundPlayer()
    
    var body: some View {
        if interfaceController.currentCard != "Sin carta" {
            Image(interfaceController.currentCard)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 700)
                .padding(.horizontal, 8)
                .transition(.slide)
                .onTapGesture {
                    interfaceController.pauseGameOnPhone()
                }
            
        } else {
            Text(interfaceController.currentCard)
        }
        
    }
}

import SwiftUI
import WatchConnectivity


struct ContentView: View {
    @StateObject private var interfaceController = InterfaceController()
    @StateObject private var soundPlayer = WatchSoundPlayer()
    
    var body: some View {
        VStack {
            ImageRenderView(interfaceController: interfaceController)
            
        }
        .onAppear {
            soundPlayer.playSound(named: "inicio")
        }
        .padding()
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
            
        } else {
            Text(interfaceController.currentCard)
        }
        
    }
}

//
//  Tutorial.swift
//  Loteria
//
//  Created by Gustavo Juarez on 26/09/24.
//


import SwiftUI

// ViewModel que manejará el estado del tutorial
class TutorialViewModel: ObservableObject {
    @Published var currentPage: Int = 0 // Página actual del tutorial
    let totalPages: Int = 3 // Número total de páginas

    func nextPage(gotoPage: Int) {
        currentPage = gotoPage
    }
}

struct TutorialView: View {
    @Binding var showTutorial: Bool // Este valor controla si se muestra el tutorial
    @StateObject private var viewModel = TutorialViewModel() // Instancia del ViewModel

    var body: some View {
        VStack {
            TabView(selection: $viewModel.currentPage) {
                // Página 1
                VStack {
                    Text("¡Bienvenido al tutorial!")
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding()
                    Image("gallo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .padding()
                    Text("Aquí aprenderás cómo usar la aplicación.")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    Text("Desliza para ver más instrucciones.")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .tag(0)
                
                // Página timer
                VStack {
                    TimerPage(viewModel: viewModel)
                }.tag(1)

                // Página timer options
                VStack {
                    TimerOptionsPage()
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle())

            Spacer()

            // Botón para saltar el tutorial
            Button(action: {
                showTutorial = false // Ocultar el tutorial
            }) {
                Text("Saltar tutorial")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
            }
        }
        .background(.backgroundApp)
    }
}

struct TimerPage: View {
    @ObservedObject var viewModel: TutorialViewModel // Usamos ObservedObject para observar el ViewModel
    @State private var isArrowBouncing = false

    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                // Imagen de fondo
                Image("pagina_inicio")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                // Flecha que apunta al botón
                VStack {
                    Spacer()
                    Text("Aquí puedes seleccionar el tiempo entre cada carta")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center) // Centra el texto
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                    // Flecha animada que apunta hacia abajo
                    Image(systemName: "arrow.down")
                        .font(.system(size: geometry.size.height * 0.08)) // Tamaño de la flecha relativo al alto de la pantalla
                        .foregroundColor(.white)
                        .offset(y: isArrowBouncing ? -10 : 0) // Movimiento de la flecha
                        .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isArrowBouncing)
                        .onAppear {
                            isArrowBouncing = true
                        }
                        .padding(.bottom, geometry.size.height * 0)
                        .padding(.leading, geometry.size.height * -0.24)

                    // Botón de temporizador
                    Button(action: {
                        print("Temporizador iniciado")
                        viewModel.nextPage(gotoPage: 2) // Llama a la función para cambiar de página
                    }) {
                        Image(systemName: "hourglass")
                            .resizable()
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1) // Tamaño relativo al ancho
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, geometry.size.height * 0.37)
                    .padding(.leading, geometry.size.height * -0.25)
                }
                .frame(width: geometry.size.width * 0.8) // Posiciona la flecha y el botón relativo al ancho
            }
        }
        .padding(.bottom, 25)
    }
}

struct TimerOptionsPage: View {
    var body: some View {
        VStack {
                
      Text("5 segundos es el tiempo por defecto")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center) // Centra el texto

                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                
            Image("menu_timer")
                    .resizable()
                    .scaledToFit()
                    .frame(width: .infinity, height: .infinity)
                    .padding()
            
            
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity) // Asegúrate de que el VStack use todo el espacio disponible
            .padding()

    }
}

// Vista previa
struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        @State var showTutorial: Bool = true
        TutorialView(showTutorial: $showTutorial)
    }
}
#Preview {
    @Previewable @State var showTutorial: Bool = true
    TutorialView(showTutorial: $showTutorial)
}

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
    let totalPages: Int = 10 // Número total de páginas

    func nextPage(gotoPage: Int) {
        currentPage = gotoPage
    }
}

struct TutorialView: View {
    @Binding var showTutorial: Bool // Este valor controla si se muestra el tutorial
    @StateObject private var viewModel = TutorialViewModel() // Instancia del ViewModel
    @ObservedObject var gameOptions: GameOptions // Referencia a las opciones del juego

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
                    TimerPageView(viewModel: viewModel)
                }.tag(1)

                // Página timer options
                VStack {
                    SharedViewForOptionsDetailsView(text: "5 segundos es el tiempo por defecto", image: "menu_timer")
                }
                .tag(2)
                // Página options
                VStack {
                    OptionsPageView(viewModel:viewModel)
                }
                .tag(3)
                // pagina de las opciones configurables
                VStack {
                    SharedViewForOptionsDetailsView(text: "Modifica las opciones a tu gusto", image: "menu_opciones")
                }
                .tag(4)
                VStack {
                    StartPageView(viewModel: viewModel)
                }
                .tag(5)
                VStack {
                    StartPageDetails1View(viewModel: viewModel)
                }
                .tag(6)
                VStack {
                    StartPageDetails2View(viewModel: viewModel)
                }
                .tag(7)
                VStack {
                    StartPageDetails3View(viewModel: viewModel)
                }
                .tag(8)
                VStack {
                    StartPageDetails4View(viewModel: viewModel)
                }
                .tag(9)
                VStack {
                    TutorialsEnd(viewModel: viewModel)
                }
                .tag(10)
            }
            .tabViewStyle(PageTabViewStyle())

            Spacer()

            // Botón para saltar el tutorial
            Button(action: {
                showTutorial = false // Ocultar el tutorial
            }) {
                Text(viewModel.currentPage == 10 ? "Terminar" : "Omitir tutorial")
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

struct TimerPageView: View {
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
                    .padding(.bottom, geometry.size.height * 0.38)
                    .padding(.leading, geometry.size.height * -0.25)
                }
                .frame(width: geometry.size.width * 0.8) // Posiciona la flecha y el botón relativo al ancho
            }
        }
        .padding(.bottom, 25)
    }
}

struct SharedViewForOptionsDetailsView: View {
    @State var text: String = ""
    @State var image: String = ""
    
    var body: some View {
        VStack {
                
      Text(text)
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center) // Centra el texto

                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                
            Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: .infinity, height: .infinity)
                    .padding()
        }.frame(maxWidth: .infinity, maxHeight: .infinity) // Asegúrate de que el VStack use todo el espacio disponible
            .padding()

    }
}

struct OptionsPageView: View {
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
                    Text("Aquí puedes cambiar las opciones")
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
                        .padding(.leading, geometry.size.height * 0.42)

                    // Botón de temporizador
                    Button(action: {
                        viewModel.nextPage(gotoPage: 4) // Llama a la función para cambiar de página
                    }) {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1) // Tamaño relativo al ancho
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, geometry.size.height * 0.37)
                    .padding(.leading, geometry.size.height * 0.42)
                }
                .frame(width: geometry.size.width * 0.8) // Posiciona la flecha y el botón relativo al ancho
            }
        }
        .padding(.bottom, 25)
    }
}


struct StartPageView: View {
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
                    Text("Inicia el juego")
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
                        .padding(.bottom, geometry.size.height * 0.0)
                    // Botón de temporizador
                    Button(action: {
                        viewModel.nextPage(gotoPage: 6) // Llama a la función para cambiar de página
                    }) {
                        Text("Iniciar")
                            .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.12) // Tamaño relativo al ancho
                            .background(.backgroundStartButton)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.bottom, geometry.size.width * 0.012)
                            
                            
                            
                            
                    }
                    .padding(.bottom, geometry.size.height * 0)
                    .padding(.leading, geometry.size.height * 0)
                        

                }
                .frame(width: geometry.size.width * 0.8) // Posiciona la flecha y el botón relativo al ancho
            }
        }
        .padding(.bottom, 25)
    }
}

struct StartPageDetails1View: View {
    @ObservedObject var viewModel: TutorialViewModel // Usamos ObservedObject para observar el ViewModel
    @State private var isArrowBouncing = false

    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                // Imagen de fondo
                Image("controles")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                // Flecha que apunta al botón
                VStack {
                    Spacer()
                   
                    // Botón de temporizador
                    Button(action: {
                        viewModel.nextPage(gotoPage: 7) // Llama a la función para cambiar de página
                    }) {
                        Image(systemName: "repeat")
                            .resizable()
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1) // Tamaño relativo al ancho
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, geometry.size.height * 0.01)
                    .padding(.leading, geometry.size.height * -0.256)
                    
                    
                    // Flecha animada que apunta hacia abajo
                    Image(systemName: "arrow.up")
                        .font(.system(size: geometry.size.height * 0.08)) // Tamaño de la flecha relativo al alto de la pantalla
                        .foregroundColor(.white)
                        .offset(y: isArrowBouncing ? -10 : 0) // Movimiento de la flecha
                        .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isArrowBouncing)
                        .onAppear {
                            isArrowBouncing = true
                        }
                        .padding(.bottom, geometry.size.height * 0)
                        .padding(.leading, geometry.size.height * -0.24)
                    
                    Text("Aquí puedes reiniciar la partida")
                        .font(.callout)
                        .bold()
                        .multilineTextAlignment(.center) // Centra el texto
                        .foregroundColor(.white)
                        .padding(.bottom, geometry.size.height * 0.2)
                        .padding(.leading, geometry.size.height * -0.24)
                   
                }
                .frame(width: geometry.size.width * 0.8) // Posiciona la flecha y el botón relativo al ancho
            }
        }
        .padding(.bottom, 25)
    }
}

struct StartPageDetails2View: View {
    @ObservedObject var viewModel: TutorialViewModel // Usamos ObservedObject para observar el ViewModel
    @State private var isArrowBouncing = false

    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                // Imagen de fondo
                Image("controles")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                // Flecha que apunta al botón
                VStack {
                    Spacer()
                    Text("Aquí puedes cambiar de carta")
                        .font(.callout)
                        .bold()
                        .multilineTextAlignment(.center) // Centra el texto
                        .foregroundColor(.white)
                        .padding(.bottom, geometry.size.width * 0)
//                    Spacer()
                    // Flecha animada que apunta hacia abajo
                    Image(systemName: "arrow.down")
                        .font(.system(size: geometry.size.height * 0.08)) // Tamaño de la flecha relativo al alto de la pantalla
                        .foregroundColor(.white)
                        .offset(y: isArrowBouncing ? -10 : 0) // Movimiento de la flecha
                        .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isArrowBouncing)
                        .onAppear {
                            isArrowBouncing = true
                        }
                        .padding(.bottom, geometry.size.height * 0.0)
                    // Botón de temporizador
                    Button(action: {
                        viewModel.nextPage(gotoPage: 8) // Llama a la función para cambiar de página
                    }) {
                        Text("Siguiente")
                            .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.12) // Tamaño relativo al ancho
                            .background(.backgroundResetButton)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.bottom, geometry.size.width * 0.02)
                    }
                    .padding(.bottom, geometry.size.height * 0)
                    .padding(.leading, geometry.size.height * 0)
                        

                }
                .frame(width: geometry.size.width * 0.8) // Posiciona la flecha y el botón relativo al ancho
            }
        }
        .padding(.bottom, 25)
    }
}

struct StartPageDetails3View: View {
    @ObservedObject var viewModel: TutorialViewModel // Usamos ObservedObject para observar el ViewModel
    @State private var isArrowBouncing = false

    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                // Imagen de fondo
                Image("controles")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                // Flecha que apunta al botón
                VStack {
                    Spacer()
                    Text("Carta actual. Puedes deslizar para cambiar de carta")
                        .font(.callout)
                        .bold()
                        .multilineTextAlignment(.center) // Centra el texto
                        .foregroundColor(.white)
                        .padding(.bottom, geometry.size.width * 0)
//                    Spacer()
                    ZStack {
                        // Flecha animada que apunta hacia abajo
                        Image(systemName: "arrow.down")
                            .font(.system(size: geometry.size.height * 0.08)) // Tamaño de la flecha relativo al alto de la pantalla
                            .foregroundColor(.white)
                            .offset(y: isArrowBouncing ? -10 : 0) // Movimiento de la flecha
                            .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isArrowBouncing)
                            .onAppear {
                                isArrowBouncing = true
                            }
                            .padding(.bottom, geometry.size.height * 0.7)
                        Button(action: {
                            viewModel.nextPage(gotoPage: 9) // Llama a la función para cambiar de página

                        })
                        {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: geometry.size.height * 0.3, height: geometry.size.height * 0.6)
                        }
                    }
                   
                }
                .frame(width: geometry.size.width * 0.8) // Posiciona la flecha y el botón relativo al ancho
            }
        }
        .padding(.bottom, 25)
    }
}

struct StartPageDetails4View: View {
    @ObservedObject var viewModel: TutorialViewModel
    @State private var isArrowBouncing = false

    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                // Imagen de fondo
                Image("cartas_usadas")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Rectángulo y botón
                    Button(action: {
                        viewModel.nextPage(gotoPage: 10)
                    }) {
                        Rectangle()
                            .fill(.clear)
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.14) // Ancho ajustado para darle espacio a los lados
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 20) // Añado padding entre el rectángulo y la flecha
                    
                    // Flecha animada que apunta hacia abajo
                    Image(systemName: "arrow.up")
                        .font(.system(size: geometry.size.height * 0.08)) // Tamaño de la flecha relativo al alto de la pantalla
                        .foregroundColor(.white)
                        .offset(y: isArrowBouncing ? -10 : 0) // Movimiento de la flecha
                        .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isArrowBouncing)
                        .onAppear {
                            isArrowBouncing = true
                        }
                                                                    
                    Text("Cartas pasadas. Puedes deslizar para visualizarlas")
                        .font(.callout)
                        .bold()
                        .multilineTextAlignment(.center) // Centra el texto
                        .foregroundColor(.white)
                        .padding(.bottom, geometry.size.height * 0.75) // Añado padding para ajustar la distancia del texto
                }
            }
        }
        .padding(.bottom, 50)
    }
}

struct TutorialsEnd: View {
    @ObservedObject var viewModel: TutorialViewModel
    var body: some View {
        VStack {
            Text("¡Tutorial Finalizado!")
                .font(.title)
                .foregroundStyle(.white)
                .padding()
            Image("gallo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .padding()
            Text("¡A Jugar!")
                .font(.title2)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

// Vista previa
//struct TutorialView_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var showTutorial: Bool = true
//        TutorialView(showTutorial: $showTutorial)
//    }
//}
//#Preview {
//    @Previewable @State var showTutorial: Bool = true
//    TutorialView(showTutorial: $showTutorial)
//}

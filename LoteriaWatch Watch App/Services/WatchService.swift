//
//  WatchService.swift
//  LoteriaWatch Watch App
//
//  Created by Gustavo Juarez on 24/09/24.
//

import Foundation
import SwiftUI

class WatchService: ObservableObject {
    
    @State var interfaceController: InterfaceController!
    
    init() {
        interfaceController = InterfaceController()
    }           
}

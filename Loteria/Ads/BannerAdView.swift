//
//  BannerAd.swift
//  Loteria
//
//  Created by Gustavo Juarez on 14/10/24.
//

import SwiftUI
import GoogleMobileAds

struct BannerAd: UIViewControllerRepresentable {
    var adUnitID: String // Añadimos adUnitID como parámetro

    func makeUIViewController(context: Context) -> UIViewController {
        
//        bannerView.adUnitID = "ca-app-pub-1285793609420967/7086865752"
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // ID de prueba
//        bannerView.adUnitID = "ca-app-pub-6001921858582655/5897809104"
//        bannerView.adUnitID = "ca-app-pub-6001921858582655/6031742293"
//         
        
        let viewController = UIViewController()
           let bannerView = GADBannerView(adSize: GADAdSizeBanner)
           
           bannerView.adUnitID = adUnitID // Usamos el adUnitID que recibimos
           bannerView.rootViewController = viewController
           viewController.view.addSubview(bannerView)
        let request = GADRequest()
             bannerView.load(request)


        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor).isActive = true
        bannerView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor).isActive = true
            
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

//
//  BannerAd.swift
//  Loteria
//
//  Created by Gustavo Juarez on 14/10/24.
//

import SwiftUI
import GoogleMobileAds

struct BannerAd: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)

        bannerView.adUnitID = "ca-app-pub-1285793609420967/7086865752"
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // ID de prueba
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)

        bannerView.load(GADRequest())

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor).isActive = true
        bannerView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor).isActive = true

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

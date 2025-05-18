//
//  IntroViewController.swift
//  FigureCollection
//
//  Created by Ronaldo Rendón Loja on 23/04/2025.
//


import UIKit
import AVKit

class IntroViewController: UIViewController {

    private var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        playIntroVideo()
    }

    private func playIntroVideo() {
        guard let path = Bundle.main.path(forResource: "IntroAnimation", ofType: "mp4") else {
            navigateToMain()
            return
        }

        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
        player = AVPlayer(playerItem: playerItem)

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        player?.play()
    }

    @objc func videoDidEnd() {
        // Detenemos y limpiamos el player
        player?.pause()
        player = nil

        // Quitamos todos los layers agregados (incluido el del video)
        view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        // Guardamos que ya se vio la intro
        UserDefaults.standard.set(true, forKey: "hasSeenIntro")

        // Navegamos al menú principal
        navigateToMain()
    }


    private func navigateToMain() {
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            UIView.transition(with: sceneDelegate.window!,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: {
                                  sceneDelegate.showMainMenu()
                              },
                              completion: nil)
        }
    }


}

//
//  CatalogViewController.swift
//  FigureCollection
//
//  Created by Ronaldo Rendón Loja on 27/04/2025.
//

import UIKit
import WebKit
import ImageIO

extension UIImageView {
    func loadGif(name: String) {
        DispatchQueue.global().async {
            guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                return
            }

            let options: [CFString: Any] = [kCGImageSourceShouldCache: true]
            guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
                return
            }

            var images = [UIImage]()
            let count = CGImageSourceGetCount(source)

            for i in 0..<count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, options as CFDictionary) {
                    images.append(UIImage(cgImage: cgImage))
                }
            }

            DispatchQueue.main.async {
                self.animationImages = images
                self.animationDuration = Double(count) * 0.07 // velocidad de la animación
                self.startAnimating()
            }
        }
    }
}

class CatalogViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var loadingImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Catálogo"
        view.backgroundColor = .systemBackground

        // Crear el WebView
        webView = WKWebView(frame: .zero)
        webView.navigationDelegate = self // Para saber cuando empieza y termina de cargar
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        // Crear el loadingImageView
        loadingImageView = UIImageView()
        loadingImageView.loadGif(name: "goku")
        loadingImageView.contentMode = .scaleAspectFit
        loadingImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingImageView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            loadingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingImageView.widthAnchor.constraint(equalToConstant: 150),
            loadingImageView.heightAnchor.constraint(equalToConstant: 150)
        ])

        // Cargar la página web
        if let url = URL(string: "https://www.dbzshfigs.com/figures") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingImageView.isHidden = false // Mostrar goku mientras carga
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingImageView.isHidden = true // Ocultar goku cuando termina de cargar
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingImageView.isHidden = true // Ocultar goku si falla
    }
}

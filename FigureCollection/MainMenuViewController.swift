//
//  MainMenuViewController.swift
//  FigureCollection
//
//  Created by Ronaldo Rendón Loja on 18/04/2025.
//


import UIKit

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
    }

    private func setupBackground() {
    
        let backgroundImage = UIImageView(image: UIImage(named: "background"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)

        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Menú Principal"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        let verBtn = makeButton(title: "👀 Ver Colección", action: #selector(verColeccion))
        let agregarBtn = makeButton(title: "➕ Agregar Figura", action: #selector(agregarFigura))
        let eliminarBtn = makeButton(title: "🗑️ Eliminar Figuras", action: #selector(eliminarFiguras))
        let catalogoBtn = makeButton(title: "📚 Catálogo", action: #selector(verCatalogo))

        

        [verBtn, agregarBtn, eliminarBtn, catalogoBtn].forEach { stack.addArrangedSubview($0) }

        view.addSubview(titleLabel)
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        btn.layer.cornerRadius = 12
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.layer.shadowRadius = 6
        btn.contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }

    @objc private func verColeccion() {
        self.navigationItem.backButtonTitle = "Atrás"
        let vc = CollectionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func agregarFigura() {
        self.navigationItem.backButtonTitle = "Atrás"
        let vc = AddFigureViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func eliminarFiguras() {
        self.navigationItem.backButtonTitle = "Atrás"
        let vc = DeleteFiguresViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func verCatalogo() {
        self.navigationItem.backButtonTitle = "Atrás"
        let vc = CatalogViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}


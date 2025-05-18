//
//  HomeViewController.swift
//  FigureCollection
//
//  Created by Ronaldo Rendón Loja on 18/04/2025.
//


import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Mi Colección"

        let verButton = makeButton(title: "Ver Colección", action: #selector(verColeccion))
        let agregarButton = makeButton(title: "Agregar Figura", action: #selector(agregarFigura))
        let eliminarButton = makeButton(title: "Eliminar Figuras", action: #selector(eliminarFiguras))

        let stack = UIStackView(arrangedSubviews: [verButton, agregarButton, eliminarButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.layer.cornerRadius = 12
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        return button
    }

    @objc private func verColeccion() {
        navigationController?.pushViewController(CollectionViewController(), animated: true)
    }

    @objc private func agregarFigura() {
        navigationController?.pushViewController(AddFigureViewController(), animated: true)
    }

    @objc private func eliminarFiguras() {
        navigationController?.pushViewController(DeleteFiguresViewController(), animated: true)
    }
}

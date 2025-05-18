//
//  FigureCell.swift
//  FigureCollection
//
//  Created by Ronaldo Rendón Loja on 18/04/2025.
//


import UIKit

class FigureCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let infoButton = UIButton(type: .infoLight)

    private var figureDescription: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        
        // Layout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(selectionOverlay)
        
        NSLayoutConstraint.activate([
            selectionOverlay.topAnchor.constraint(equalTo: imageView.topAnchor),
            selectionOverlay.leftAnchor.constraint(equalTo: imageView.leftAnchor),
            selectionOverlay.rightAnchor.constraint(equalTo: imageView.rightAnchor),
            selectionOverlay.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        contentView.addSubview(checkmarkImageView)

        NSLayoutConstraint.activate([
            checkmarkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            checkmarkImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])



        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1

        infoButton.addTarget(self, action: #selector(showDescription), for: .touchUpInside)

        

        
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.90),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: infoButton.leftAnchor, constant: -8),

            infoButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            infoButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8)
        ])
    }

    func configure(with figure: Figure, selected: Bool) {
        imageView.image = UIImage(data: figure.imageData)
        titleLabel.text = figure.title
        figureDescription = figure.description
        
        contentView.layer.borderWidth = selected ? 3 : 0
        contentView.layer.borderColor = selected ? UIColor.systemBlue.cgColor : nil
        
        selectionOverlay.isHidden = !selected
        checkmarkImageView.isHidden = !selected
    }

    
    private let selectionOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()



    @objc private func showDescription() {
        guard let parentVC = findViewController() else { return }

        let alert = UIAlertController(title: "Año", message: figureDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel))
        parentVC.present(alert, animated: true)
    }

    // Para poder presentar alertas desde la celda
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}

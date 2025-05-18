//
//  AddEditFigureViewController.swift
//  FigureCollection
//
//  Created by Ronaldo Rendón Loja on 24/04/2025.
//


import UIKit

protocol AddEditFigureDelegate: AnyObject {
    func didSaveFigure(_ figure: Figure)
}

class AddEditFigureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    weak var delegate: AddEditFigureDelegate?
    
    var figureToEdit: Figure?

    private let titleField: UITextField = {
        let field = UITextField()
        field.placeholder = "Nombre Figura"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let descriptionField: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Seleccionar Imagen", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = figureToEdit == nil ? "Agregar Figura" : "Editar Figura"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveFigure))

        setupViews()
        if let figure = figureToEdit {
            configureWithFigure(figure)
        }
    }

    private func setupViews() {
        view.addSubview(titleField)
        view.addSubview(descriptionField)
        view.addSubview(imageView)
        view.addSubview(selectImageButton)

        selectImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)

        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            descriptionField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 20),
            descriptionField.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            descriptionField.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            descriptionField.heightAnchor.constraint(equalToConstant: 120),

            imageView.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            selectImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            selectImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func configureWithFigure(_ figure: Figure) {
        titleField.text = figure.title
        descriptionField.text = figure.description
        imageView.image = UIImage(data: figure.imageData)
    }

    @objc private func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        dismiss(animated: true)
    }

    @objc private func saveFigure() {
        guard let title = titleField.text, !title.isEmpty,
              let description = descriptionField.text, !description.isEmpty,
              let image = imageView.image,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            let alert = UIAlertController(title: "Error", message: "Completa todos los campos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let figure = Figure(
            id: figureToEdit?.id ?? UUID(),
            title: title,
            description: description,
            imageData: imageData
        )

        delegate?.didSaveFigure(figure)
        navigationController?.popViewController(animated: true)
    }
}


//
//  AddFigureViewController.swift
//  FigureCollection
//
//  Created by Ronaldo Rendón Loja on 18/04/2025.
//

import UIKit

class AddFigureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let imageView = UIImageView()
    private let titleField = UITextField()
    private let descriptionField = UITextField()
    private let addPhotoButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Agregar Figura"
        view.backgroundColor = .systemBackground
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)


        setupUI()
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let bottomInset = keyboardFrame.height
            self.view.frame.origin.y = -bottomInset / 2 
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        self.view.frame.origin.y = 0
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        // Imagen
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.systemGray4.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 220).isActive = true

        // Botón subir foto
        addPhotoButton.setTitle("Subir Foto", for: .normal)
        addPhotoButton.setTitleColor(.white, for: .normal)
        addPhotoButton.backgroundColor = UIColor.systemBlue
        addPhotoButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addPhotoButton.layer.cornerRadius = 20
        addPhotoButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        addPhotoButton.addTarget(self, action: #selector(pickPhoto), for: .touchUpInside)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false

        // Campo Nombre Figura
        titleField.placeholder = "Nombre de la figura"
        configureTextField(titleField, systemImage: "tag")

        // Campo Año
        descriptionField.placeholder = "Año de lanzamiento"
        configureTextField(descriptionField, systemImage: "calendar")

        // Botón guardar
        saveButton.setTitle("Guardar Figura", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.layer.cornerRadius = 12
        saveButton.layer.shadowColor = UIColor.systemBlue.cgColor
        saveButton.layer.shadowOpacity = 0.3
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        saveButton.layer.shadowRadius = 10
        saveButton.addTarget(self, action: #selector(saveFigure), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // Stack Layout
        let stack = UIStackView(arrangedSubviews: [imageView, addPhotoButton, titleField, descriptionField, saveButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])

        // Alinear textfields y botones
        titleField.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        descriptionField.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        saveButton.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.6).isActive = true
    }

    private func configureTextField(_ textField: UITextField, systemImage: String) {
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.secondarySystemBackground
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let imageView = UIImageView(image: UIImage(systemName: systemImage))
        imageView.tintColor = .gray
        textField.leftView = imageView
        textField.leftViewMode = .always
    }

    @objc private func pickPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let edited = info[.editedImage] as? UIImage {
            selectedImage = edited
            imageView.image = edited
        } else if let original = info[.originalImage] as? UIImage {
            selectedImage = original
            imageView.image = original
        }
        picker.dismiss(animated: true)
    }

    @objc private func saveFigure() {
        guard let image = selectedImage,
              let title = titleField.text, !title.isEmpty,
              let desc = descriptionField.text, !desc.isEmpty,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            let alert = UIAlertController(title: "Error", message: "Completa todos los campos e incluye una imagen.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
            return
        }

        let newFigure = Figure(id: UUID(), title: title, description: desc, imageData: imageData)

        var savedFigures: [Figure] = []
        if let data = UserDefaults.standard.data(forKey: "figures"),
           let decoded = try? JSONDecoder().decode([Figure].self, from: data) {
            savedFigures = decoded
        }
        savedFigures.append(newFigure)

        if let encoded = try? JSONEncoder().encode(savedFigures) {
            UserDefaults.standard.set(encoded, forKey: "figures")
        }

        navigationController?.popViewController(animated: true)
    }
}

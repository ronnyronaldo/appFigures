//
//  CollectionViewController.swift
//  FigureCollection
//
//  Created by Ronaldo Rendón Loja on 18/04/2025.
//


import UIKit

class CollectionViewController: UIViewController, UIDocumentPickerDelegate {

    private var figures: [Figure] = []
    private var selectedIndexes: Set<IndexPath> = []
    private var currentPage: Int = 0
    private let pageSize: Int = 4
    private var filteredFigures: [Figure] = []
    private let paginationStack = UIStackView()
    private let pageLabel = UILabel()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let spacing: CGFloat = 16
        let totalSpacing = spacing * 3
        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / 2
        layout.itemSize = CGSize(width: itemWidth, height: 300)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsVerticalScrollIndicator = false
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Colección"
        setupNavigationItems()
        loadFigures()
        setupCollectionView()
        setupPaginationControls()
    }

    private func setupNavigationItems() {
        if figures.isEmpty {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Importar", style: .plain, target: self, action: #selector(importFigures))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Exportar", style: .plain, target: self, action: #selector(exportFigures))
        }
    }

    private func setupCollectionView() {
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        collectionView.register(FigureCell.self, forCellWithReuseIdentifier: "FigureCell")
        collectionView.dataSource = self

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        guard gesture.state == .began,
              let indexPath = collectionView.indexPathForItem(at: location) else {
            return
        }

        let figure = filteredFigures[indexPath.item]
        let alert = UIAlertController(title: "Opciones", message: "¿Qué deseas hacer con esta figura?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Modificar", style: .default, handler: { _ in
            self.editFigure(figure)
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(origin: location, size: CGSize(width: 1, height: 1))
        }

        present(alert, animated: true)
    }

    private func editFigure(_ figure: Figure) {
        let addEditVC = AddEditFigureViewController()
        addEditVC.figureToEdit = figure
        addEditVC.delegate = self
        navigationController?.pushViewController(addEditVC, animated: true)
    }

    private func loadFigures() {
        if let data = UserDefaults.standard.data(forKey: "figures"),
           let decoded = try? JSONDecoder().decode([Figure].self, from: data) {
            figures = decoded
        }
        applyPagination()
    }

    private func applyPagination() {
        let start = currentPage * pageSize
        let end = min(start + pageSize, figures.count)
        filteredFigures = (start < end) ? Array(figures[start..<end]) : []
        collectionView.reloadData()
        pageLabel.text = "Página \(currentPage + 1)"
        setupNavigationItems()
    }

    private func setupPaginationControls() {
        prevButton.setTitle("Anterior", for: .normal)
        nextButton.setTitle("Siguiente", for: .normal)
        pageLabel.text = "Página 1"
        pageLabel.textAlignment = .center

        let midnightBlue = UIColor(red: 25/255, green: 42/255, blue: 86/255, alpha: 1)

        [prevButton, nextButton].forEach {
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = midnightBlue
            $0.layer.cornerRadius = 12
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 4
            $0.layer.shadowOpacity = 0.25
            $0.titleLabel?.font = UIFont(name: "AvenirNextCondensed-Regular", size: 16)
            $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        }

        pageLabel.font = UIFont(name: "AvenirNextCondensed-Regular", size: 16)
        pageLabel.textColor = midnightBlue

        prevButton.addTarget(self, action: #selector(prevPage), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)

        paginationStack.axis = .horizontal
        paginationStack.spacing = 12
        paginationStack.alignment = .center
        paginationStack.translatesAutoresizingMaskIntoConstraints = false
        paginationStack.addArrangedSubview(prevButton)
        paginationStack.addArrangedSubview(pageLabel)
        paginationStack.addArrangedSubview(nextButton)

        view.addSubview(paginationStack)

        NSLayoutConstraint.activate([
            paginationStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            paginationStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func prevPage() {
        if currentPage > 0 {
            currentPage -= 1
            applyPagination()
        }
    }

    @objc private func nextPage() {
        let maxPage = (figures.count - 1) / pageSize
        if currentPage < maxPage {
            currentPage += 1
            applyPagination()
        }
    }

    @objc private func exportFigures() {
        guard let data = try? JSONEncoder().encode(figures) else { return }

        let fileName = "figures_export.figures.json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: url)
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activityVC, animated: true)
        } catch {
            print("Error exportando figuras: \(error)")
        }
    }

    @objc private func importFigures() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let pickedURL = urls.first else { return }

        guard pickedURL.startAccessingSecurityScopedResource() else {
            print("❌ No se pudo acceder al archivo por seguridad.")
            return
        }

        defer { pickedURL.stopAccessingSecurityScopedResource() }

        do {
            // Copiar el archivo al directorio de documentos de la app
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsURL.appendingPathComponent(pickedURL.lastPathComponent)

            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            try fileManager.copyItem(at: pickedURL, to: destinationURL)

            // Leer y decodificar los datos del archivo copiado
            let data = try Data(contentsOf: destinationURL)
            let importedFigures = try JSONDecoder().decode([Figure].self, from: data)

            // Guardamos las figuras importadas
            self.figures = importedFigures
            UserDefaults.standard.set(data, forKey: "figures")

            // Volvemos a la primera página y refrescamos la UI
            currentPage = 0
            applyPagination()

            // Mostrar alerta de éxito
            let alert = UIAlertController(title: "Importación exitosa", message: "Se importaron \(importedFigures.count) figuras.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
            present(alert, animated: true)

        } catch {
            print("❌ Error al importar: \(error)")
            // Mostrar alerta de error
            let alert = UIAlertController(title: "Error", message: "No se pudo importar el archivo: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
            present(alert, animated: true)
        }
    }

}

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredFigures.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FigureCell", for: indexPath) as? FigureCell else {
            return UICollectionViewCell()
        }
        let figure = filteredFigures[indexPath.item]
        cell.configure(with: figure, selected: false)
        return cell
    }
}

extension CollectionViewController: AddEditFigureDelegate {
    func didSaveFigure(_ figure: Figure) {
        if let index = figures.firstIndex(where: { $0.id == figure.id }) {
            figures[index] = figure
        } else {
            figures.append(figure)
        }
        saveFigures()
        applyPagination()
    }

    private func saveFigures() {
        if let encoded = try? JSONEncoder().encode(figures) {
            UserDefaults.standard.set(encoded, forKey: "figures")
        }
    }
}




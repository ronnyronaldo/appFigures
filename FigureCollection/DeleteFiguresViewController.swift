//
//  DeleteFiguresViewController.swift
//  FigureCollection
//
//  Created by Ronaldo Rendón Loja on 18/04/2025.
//


import UIKit
import AVFoundation

class DeleteFiguresViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private var figures: [Figure] = []
    private var selectedIndexes: Set<IndexPath> = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 16
        let totalSpacing = spacing * 3
        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / 2
        layout.itemSize = CGSize(width: itemWidth, height: 250)

        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(FigureCell.self, forCellWithReuseIdentifier: "FigureCell")
        cv.delegate = self
        cv.dataSource = self
        cv.allowsMultipleSelection = true
        return cv
    }()

    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Eliminar Seleccionados", for: .normal)
        btn.backgroundColor = .systemRed
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(deleteSelected), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Eliminar Figuras"
        view.backgroundColor = .systemBackground
        setupViews()
        loadFigures()
    }
    
    var audioPlayer: AVAudioPlayer?

    func playTrashSound() {
        guard let url = Bundle.main.url(forResource: "trash", withExtension: "wav") else {
            print("No se encontró el archivo de sonido.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error al reproducir sonido: \(error.localizedDescription)")
        }
    }
    
    func deleteFigure(at indexPath: IndexPath) {
        figures.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
        playTrashSound()
    }


    private func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -10),

            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            deleteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func loadFigures() {
        if let data = UserDefaults.standard.data(forKey: "figures"),
           let decoded = try? JSONDecoder().decode([Figure].self, from: data) {
            self.figures = decoded
            collectionView.reloadData()
        }
    }

    @objc private func deleteSelected() {
        let indexes = selectedIndexes.sorted { $0.item > $1.item }
        
        guard !indexes.isEmpty else { return } // por si no hay nada seleccionado
        
        for indexPath in indexes {
            figures.remove(at: indexPath.item)
        }

        if let encoded = try? JSONEncoder().encode(figures) {
            UserDefaults.standard.set(encoded, forKey: "figures")
        }

        selectedIndexes.removeAll()
        loadFigures()
        
        playTrashSound()
    }

    // MARK: Collection View

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return figures.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let figure = figures[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FigureCell", for: indexPath) as! FigureCell
        cell.configure(with: figure, selected: selectedIndexes.contains(indexPath))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexes.contains(indexPath) {
            selectedIndexes.remove(indexPath)
        } else {
            selectedIndexes.insert(indexPath)
        }
        collectionView.reloadItems(at: [indexPath])
    }
}

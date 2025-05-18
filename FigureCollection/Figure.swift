//
//  Figure.swift
//  FigureCollection
//
//  Created by Ronaldo Rendón Loja on 18/04/2025.
//


    import UIKit

    struct Figure: Codable, Equatable {
        let id: UUID
        var title: String
        var description: String
        var imageData: Data
    }

//
//  SavedNewsModel.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 05/08/25.
//

import Foundation

struct NewsModel: Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let imageURL: String
    let newsDescription: String
    let publishedTime: String
    let PublishedDate: String
    let newsURL: String
}

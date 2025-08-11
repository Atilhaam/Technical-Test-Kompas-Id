//
//  SavedNewsNavigator.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 06/08/25.
//

import Foundation
import SwiftUI

protocol SavedNewsNavigator {
    func makeDetailView(for news: NewsModel) -> DetailNewsView
}

final class DefaultSavedNewsNavigator: SavedNewsNavigator {
    func makeDetailView(for news: NewsModel) -> DetailNewsView {
        let viewModel = Injection().provideDetailViewModel(news: news)
        return DetailNewsView(viewModel: viewModel)
    }
}

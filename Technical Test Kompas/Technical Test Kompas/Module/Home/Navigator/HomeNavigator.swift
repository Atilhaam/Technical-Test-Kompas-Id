//
//  HomeNavigator.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 06/08/25.
//

import SwiftUI

protocol HomeNavigator {
    func makeDetailView(for news: NewsModel) -> DetailNewsView
}

final class DefaultHomeNavigator: HomeNavigator {
    func makeDetailView(for news: NewsModel) -> DetailNewsView {
        let viewModel = Injection().provideDetailViewModel(news: news)
        return DetailNewsView(viewModel: viewModel)
    }
}

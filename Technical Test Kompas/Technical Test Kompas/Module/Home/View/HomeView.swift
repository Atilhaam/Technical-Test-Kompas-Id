//
//  HomeView.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 03/08/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var selectedNews: NewsModel?
    var navigator: HomeNavigator

    
    init(viewModel: HomeViewModel, navigator: HomeNavigator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.navigator = navigator
    }

    var body: some View {
        List {
            ForEach(viewModel.sections) { section in
                SectionView(section: section, viewModel: viewModel) { newsItem in
                    selectedNews = newsItem
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .contentShape(Rectangle())
                .buttonStyle(PlainButtonStyle())
                
            }
        }
        .listStyle(PlainListStyle())
        .onAppear {
            viewModel.getNews()
        }
        .navigationDestination(item: $selectedNews) { news in
            navigator.makeDetailView(for: news)
        }
        .navigationTitle("Berita Utama")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        
    }
}

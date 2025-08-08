//
//  SectionView.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 03/08/25.
//

import Foundation
import SwiftUI

struct SectionView: View {
    let section: Section
    
    @ObservedObject private var viewModel: HomeViewModel
    @EnvironmentObject var playbackManager: PlaybackManager
    var onSelectNews: ((NewsModel) -> Void)? = nil
    
    init(section: Section, viewModel: HomeViewModel, onSelectNews: ((NewsModel) -> Void)? = nil) {
        self.section = section
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self.onSelectNews = onSelectNews
    }

    var body: some View {
        LazyVStack(alignment: .leading) {
            switch section {
            case .headline(let data):
                if let content = data.data {
                    HeadlineSectionView(content: content, viewModel: viewModel, onSelectNews: onSelectNews)
                }

            case .hotTopics(let data):
                HotTopicsView(section: data)
                
            case .iframeCampaign(let data):
                if let url = data.data?.url {
                    IframeView(url: url)
                }

            case .articleList(let data): 
                ArticleListSectionView(section: data, viewModel: viewModel, onSelectNews: onSelectNews)

            case .liveReport(let data):
                if let report = data.data {
                    LiveReportView(report: report, onSelectNews: onSelectNews)
                }
            case .adsCampaign(let data):
                if let url = data.data?.url {
                    AdsSectionView(url: url)
                }
            }
        }
        .padding(.vertical)
        .background(Color(white: 0.97))
    }
}

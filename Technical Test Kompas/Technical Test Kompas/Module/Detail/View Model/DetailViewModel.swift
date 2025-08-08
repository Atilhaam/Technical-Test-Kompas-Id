//
//  DetailViewModel.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 06/08/25.
//

import Foundation
import RxSwift

class DetailViewModel: ObservableObject {
    @Published var news: NewsModel
    @Published var isSaved: Bool = false
    @Published var shareContent: [Any] = []
    
    private let useCase: DetailUseCase
    private let disposeBag = DisposeBag()
    
    init(useCase: DetailUseCase, news: NewsModel) {
        self.useCase = useCase
        self.news = news
    }
    
    func toggleBookmark() {
        if isSaved {
            removeSave()
        } else {
            addSave()
        }
    }
    
    private func addSave() {
        let article = ArticleListItem(title: news.title,
                                      label: "",
                                      description: news.newsDescription,
                                      imageDescription: "",
                                      mediaCount: 0,
                                      imageURL: news.imageURL,
                                      publishedTime: news.publishedTime,
                                      publishedDate: news.PublishedDate,
                                      id: news.id, newsURL: news.newsURL)
        useCase.saveNews(article)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                if success {
                    self?.isSaved.toggle()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func removeSave() {
        useCase.removeNews(id: news.id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                if success {
                    self?.isSaved.toggle()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func loadSavedState() {
        useCase.checkSaved(id: news.id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSaved in
                self?.isSaved = isSaved
            }, onError: { error in
                print("Error checking saved state: \(error)")
            })
            .disposed(by: disposeBag)
    }
}

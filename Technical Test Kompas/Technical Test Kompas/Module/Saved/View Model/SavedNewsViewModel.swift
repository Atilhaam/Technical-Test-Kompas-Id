//
//  SavedNewsViewModel.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 06/08/25.
//

import Foundation
import RxSwift

class SavedNewsViewModel: ObservableObject {
    @Published var savedNews: [NewsModel] = []
    
    private let useCase: SavedNewsUseCase
    private let disposeBag = DisposeBag()
    
    init(useCase: SavedNewsUseCase) {
        self.useCase = useCase
    }
    
    func removeSave(for article: NewsModel) {
        useCase.removeNews(id: article.id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                if success {
                    self?.savedNews.removeAll { $0.id == article.id }
                }
            })
            .disposed(by: disposeBag)
    }
    
    func getSavedNews() {
        useCase.getSavedNews()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] savedNews in
                self?.savedNews = savedNews
            })
            .disposed(by: disposeBag)
    }

    
}

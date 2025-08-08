//
//  HomeViewModel.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 03/08/25.
//

import Foundation
import RxSwift

class HomeViewModel: ObservableObject {
    @Published var sections: [Section] = []
    @Published var savedNewsIDs: Set<String> = []
    @Published var shareContent: [Any] = []
    
    private let homeUseCase: HomeUseCase
    private let disposeBag = DisposeBag()
    
    
    init(homeUseCase: HomeUseCase) {
        self.homeUseCase = homeUseCase
    }
    
    func getNews() {
        homeUseCase.getNews()
            .observe(on: MainScheduler.instance)
            .subscribe { result in
                self.sections = result
            } onError: { error in
                print(error)
            }.disposed(by: disposeBag)
    }
    
    func isContain(id: String) -> Bool {
        return savedNewsIDs.contains(id)
    }
    
    func loadSavedState(for id: String) {
        homeUseCase.checkSaved(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSaved in
                if isSaved {
                    print("id: \(id) is inserted from set")
                    self?.savedNewsIDs.insert(id)
                } else {
                    print("id: \(id) is removed from set")
                    self?.savedNewsIDs.remove(id)
                }
            }, onError: { error in
                print("Error checking saved state: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func toggleBookmark(for article: ArticleListItem) {
        if savedNewsIDs.contains(article.id ?? "") {
            removeSave(for: article)
        } else {
            addSave(for: article)
        }
    }
    
    private func addSave(for article: ArticleListItem) {
        homeUseCase.saveNews(article)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                if success {
                    print("Saved successfully")
                    self?.savedNewsIDs.insert(article.id ?? "")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func removeSave(for article: ArticleListItem) {
        homeUseCase.removeNews(id: article.id ?? "")
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                if success {
                    print("Removed successfully")
                    self?.savedNewsIDs.remove(article.id ?? "")
                }
            })
            .disposed(by: disposeBag)
    }
}

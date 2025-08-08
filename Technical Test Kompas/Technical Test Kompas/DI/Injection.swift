//
//  Injection.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 05/08/25.
//

import Foundation
import RealmSwift

final class Injection: NSObject {
    private func provideRepository() -> NewsRepositoryProtocol {
        let realm = try? Realm()
        let locale: LocaleDataSource = LocaleDataSource.sharedInstance(realm)
        let remote: RemoteDataSource = RemoteDataSource.sharedInstance
        
        return NewsRepository.sharedInstance(locale,remote)
    }
    
    func provideHomeUseCase() -> HomeUseCase {
        let repository = provideRepository()
        return HomeUseCase(repository: repository)
    }
    
    func provideSavedUseCase() -> SavedNewsUseCase {
        let repository = provideRepository()
        return SavedNewsUseCase(repository: repository)
    }
    
    func provideDetailUseCase() -> DetailUseCase {
        let repository = provideRepository()
        return DetailUseCase(repository: repository)
    }
    
    func provideHomeViewModel() -> HomeViewModel {
        return HomeViewModel(homeUseCase: provideHomeUseCase())
    }
    
    func provideSavedViewModel() -> SavedNewsViewModel {
        return SavedNewsViewModel(useCase: provideSavedUseCase())
    }
    
    func provideDetailViewModel(news: NewsModel) -> DetailViewModel {
        return DetailViewModel(useCase: provideDetailUseCase(), news: news)
    }
    
    func provideHomeNavigator() -> HomeNavigator {
        return DefaultHomeNavigator()
    }
    
    func provideSavedNavigator() -> SavedNewsNavigator {
        return DefaultSavedNewsNavigator()
    }
}

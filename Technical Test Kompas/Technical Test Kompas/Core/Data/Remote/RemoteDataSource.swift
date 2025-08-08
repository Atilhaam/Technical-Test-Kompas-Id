//
//  RemoteDataSource.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 05/08/25.
//

import Foundation
import RxSwift

protocol RemoteDataSourceProtocol: AnyObject {
    func getNews() -> Observable<[Section]>
}

final class RemoteDataSource: NSObject {
    
    private override init() { }
    
    static let sharedInstance: RemoteDataSource = RemoteDataSource()
    
}

extension RemoteDataSource: RemoteDataSourceProtocol {
    func getNews() -> Observable<[Section]> {
        return Observable<[Section]>.create { observer in
            if let url = Bundle.main.url(forResource: "home_mock", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoded = try JSONDecoder().decode(HomeResponse.self, from: data)
                    observer.onNext(decoded.sections)
                    print("ini sections \(decoded.sections)")
                    observer.onCompleted()
                } catch {
                    print("❌ Failed to decode JSON: \(error)")
                }
            }
            return Disposables.create()
        }
    }
}

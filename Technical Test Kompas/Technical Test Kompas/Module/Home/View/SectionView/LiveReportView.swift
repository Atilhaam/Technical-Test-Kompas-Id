//
//  LiveReportView.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 03/08/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct LiveReportView: View {
    let report: LiveReportData
    var onSelectNews: ((NewsModel) -> Void)?
    
    init(report: LiveReportData, onSelectNews: ((NewsModel) -> Void)? = nil) {
        self.report = report
        self.onSelectNews = onSelectNews
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let article = report.mainArticle {
                if let imageURL = article.imageURL, let url = URL(string: imageURL) {
                    ZStack(alignment: .topLeading) {
                        WebImage(url: url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                        
                        TypeBadge(label: report.reportType ?? "")
                            .padding(8)
                       
                    }
                    
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.category ?? "")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Text(article.title ?? "")
                        .font(.title3)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(article.publishedTime ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .onTapGesture {
                    let item = NewsModel(id: article.id ?? "",
                                         title: article.title ?? "",
                                         imageURL: article.imageURL ?? "",
                                         newsDescription: article.category ?? "",
                                         publishedTime: article.publishedTime ?? "",
                                         PublishedDate: "", newsURL: article.newsURL ?? "", audioURL: article.audioURL)
                    onSelectNews?(item)
                }
                
                if let related = report.relatedArticles {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(related) { article in
                            HStack(alignment: .top, spacing: 6) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 6, height: 6)
                                    .opacity(1.0)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(article.publishedTime ?? "")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(article.title ?? "")
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.bottom, 8)
                            .onTapGesture {
                                let item = NewsModel(id: article.id ?? "",
                                                     title: article.title ?? "",
                                                     imageURL: article.imageURL ?? "",
                                                     newsDescription: article.category ?? "",
                                                     publishedTime: article.publishedTime ?? "",
                                                     PublishedDate: "", newsURL: article.newsURL ?? "", audioURL: article.audioURL ?? "")
                                onSelectNews?(item)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    
                }
                
                if let more = report.moreReports {
                    HStack {
                        Text(more.label ?? "")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(more.count ?? "")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }) {
                            Image("share")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                    }
                    .padding(.top, 4)
                    .padding(.horizontal)
                }
                
                Divider()
                
                if let featured = report.featuredArticles {
                    VStack(spacing: 8) {
                        ForEach(featured) { article in
                            HStack(spacing: 12) {
                                Text(article.title ?? "")
                                    .font(.headline)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                if let imageURL = article.imageURL, let url = URL(string: imageURL) {
                                    WebImage(url: url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 60)
                                        .clipped()
                                        .cornerRadius(8)
                                }
                            }
                            .onTapGesture {
                                let item = NewsModel(id: article.id ?? "",
                                                     title: article.title ?? "",
                                                     imageURL: article.imageURL ?? "",
                                                     newsDescription: "",
                                                     publishedTime: "",
                                                     PublishedDate: "",
                                                     newsURL: article.newsURL ?? "", audioURL: article.audioURL ?? "")
                                onSelectNews?(item)
                            }
                            
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                    
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
    }
}

struct TypeBadge: View {
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.red)
        .clipShape(Capsule())
    }
}

//
//  MainNewsModel.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 03/08/25.
//

import Foundation

// MARK: - Root Model
struct HomeResponse: Codable {
    let sections: [Section]
}

// MARK: - Section Enum Wrapper
enum Section: Codable {
    case headline(HeadlineSection)
    case hotTopics(HotTopicsSection)
    case iframeCampaign(IframeCampaignSection)
    case articleList(ArticleListSection) 
    case liveReport(LiveReportSection)
    case adsCampaign(AdsSection)

    enum CodingKeys: String, CodingKey {
        case type
    }

    enum SectionType: String, Codable {
        case headline
        case hot_topics
        case iframe_campaign
        case kabinet
        case live_report
        case pon
        case articles
        case ads
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(SectionType.self, forKey: .type)

        switch type {
        case .headline:
            self = .headline(try HeadlineSection(from: decoder))
        case .hot_topics:
            self = .hotTopics(try HotTopicsSection(from: decoder))
        case .iframe_campaign:
            self = .iframeCampaign(try IframeCampaignSection(from: decoder))
        case .kabinet, .pon, .articles: 
            self = .articleList(try ArticleListSection(from: decoder))
        case .live_report:
            self = .liveReport(try LiveReportSection(from: decoder))
        case .ads:
            self = .adsCampaign(try AdsSection(from: decoder))
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .headline(let value):
            try value.encode(to: encoder)
        case .hotTopics(let value):
            try value.encode(to: encoder)
        case .iframeCampaign(let value):
            try value.encode(to: encoder)
        case .articleList(let value):
            try value.encode(to: encoder)
        case .liveReport(let value):
            try value.encode(to: encoder)
        case .adsCampaign(let value):
            try value.encode(to: encoder)
        }
    }
}

// MARK: - Headline Section
struct HeadlineSection: Codable {
    let type: String?
    let data: HeadlineData?
}

struct HeadlineData: Codable, Identifiable {
    let headline: String?
    let subheadline: String?
    let publishedTime: String?
    let source: String?
    let articles: [Article]?
    let imageURL: String?
    let newsURL: String?
    let audioURL: String?
    
    let id: String?

    enum CodingKeys: String, CodingKey {
        case headline
        case subheadline
        case publishedTime = "published_time"
        case source
        case articles
        case imageURL
        case id
        case newsURL
        case audioURL
    }
}

struct Article: Codable, Identifiable {
    let title: String?
    let publishedTime: String?
    let id: String
    let imageURL: String?
    let newsURL: String?
    let audioURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case publishedTime = "published_time"
        case imageURL
        case newsURL
        case audioURL
    }
}

// MARK: - Article List Section
struct ArticleListSection: Codable {
    let type: String?
    let title: String?
    let data: [ArticleListItem]?
}

struct ArticleListItem: Codable, Identifiable {
    let title: String?
    let label: String?
    let description: String?
    let imageDescription: String?
    let mediaCount: Int?
    let imageURL: String?
    let publishedTime: String?
    let publishedDate: String?
    let id: String?
    let newsURL: String?
    let audioURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case label
        case description
        case imageDescription = "image_description"
        case mediaCount = "media_count"
        case imageURL
        case publishedTime
        case publishedDate
        case newsURL
        case audioURL
    }
}

// MARK: - Hot Topics Section
struct HotTopicsSection: Codable {
    let type: String?
    let title: String?
    let data: [HotTopicItem]?
}

struct HotTopicItem: Codable, Identifiable {
    let title: String?
    let imageDescription: String?
    let id = UUID()
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case title
        case imageDescription = "image_description"
        case imageURL
    }
}

// MARK: - Iframe Campaign Section
struct IframeCampaignSection: Codable {
    let type: String?
    let data: IframeCampaignData?
}

struct IframeCampaignData: Codable {
    let url: String?
}

// MARK: - Ads Section
struct AdsSection: Codable {
    let type: String?
    let data: IframeCampaignData?
}

// MARK: - Live Report Section
struct LiveReportSection: Codable {
    let type: String?
    let data: LiveReportData?
}

struct LiveReportData: Codable {
    let reportType: String?
    let mainArticle: LiveArticle?
    let relatedArticles: [LiveArticle]?
    let moreReports: MoreReports?
    let featuredArticles: [FeaturedArticle]?

    enum CodingKeys: String, CodingKey {
        case reportType = "report_type"
        case mainArticle = "main_article"
        case relatedArticles = "related_articles"
        case moreReports = "more_reports"
        case featuredArticles = "featured_articles"
    }
}

struct LiveArticle: Codable, Identifiable {
    let id: String?
    let category: String?
    let title: String?
    let publishedTime: String?
    let imageURL: String?
    let newsURL: String?
    let audioURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case title
        case publishedTime = "published_time"
        case imageURL
        case newsURL
        case audioURL
    }
}

struct MoreReports: Codable {
    let label: String?
    let count: String?
}

struct FeaturedArticle: Codable, Identifiable {
    let id: String?
    let title: String?
    let imageURL: String?
    let newsURL: String?
    let audioURL: String?
}

// MARK: - Section Identifiable Support
extension Section: Identifiable {
    var id: String {
        switch self {
        case .headline(let section):
            return "headline-\(section.data?.headline ?? UUID().uuidString)"
        case .hotTopics(let section):
            return "hot_topics-\(section.title ?? UUID().uuidString)"
        case .iframeCampaign:
            return "iframe_campaign-\(UUID().uuidString)"
        case .articleList(let section):
            return "\(section.type ?? "articleList")-\(section.title ?? UUID().uuidString)"
        case .liveReport:
            return "live_report-\(UUID().uuidString)"
        case .adsCampaign(_):
            return "ads_campaign-\(UUID().uuidString)"
        }
    }
}

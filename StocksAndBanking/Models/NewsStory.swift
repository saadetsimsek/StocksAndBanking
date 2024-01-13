//
//  NewsStory.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import Foundation

struct NewsStory: Codable{
    let category: String
    let datetime: TimeInterval
    let headline: String
    // let id: Int
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}

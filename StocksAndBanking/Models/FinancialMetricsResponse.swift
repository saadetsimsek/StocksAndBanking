//
//  FinancialMetricsResponse.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import Foundation

//MARK: - FinancialMetricsResponse

struct FinancialMetricsResponse: Codable {
    //let series: Series
    let metric: Metric
    // let metricType, symbol:String
}

//MARK: - Metric

struct Metric: Codable {
    let the10DayAverageTradingVolume, the52WeekHigh, the52WeekLow: Double
    let the52WeekLowDate: String
    let the52WeekPriceReturnDaily, beta: Double
    
    enum CodingKeys:String, CodingKey {
        case the10DayAverageTradingVolume = "10DayAverageTradingVolume"
        case the52WeekHigh = "52WeekHigh"
        case the52WeekLow = "52WeekLow"
        case the52WeekLowDate = "52WeekLowDate"
        case the52WeekPriceReturnDaily = "52WeekPriceReturnDaily"
        case beta
    }
}

//MARK: - Series
struct Series: Codable {
    let annual: Annual
}

//MARK: - Annual
struct Annual: Codable {
    let currentRatio, salesPreShare, netMargin: [CurrentRatio]
}

//MARK: - CurrentRatio

struct CurrentRatio: Codable {
    let period: String
    let v: Double
}

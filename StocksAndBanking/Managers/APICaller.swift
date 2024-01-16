//
//  APICaller.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import Foundation

final class APICaller {
    
    static let shared = APICaller()
    
    private struct Constant{
        static let apiKey = "cmfushpr01qss8959gg0cmfushpr01qss8959ggg"
        static let secretKey = "cmfushpr01qss8959ghg"
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
    
    private init(){
        
    }
    
    //MARK: - Public
    
    public func search(query: String, completion: @escaping (Result<SearchResponse, Error>)->Void){
        
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
        request(url: url(for: .search,
                         queryParams: ["q": safeQuery]),
                expecting: SearchResponse.self,
                completion: completion)
    }
    
    //MARK: - Get Stock Info
    
    ///get news for type
    /// - Parameters:
    ///  -type: company or top stories
    ///   -compeletion: Result callback
    public func news(for type: NewsViewController.Typee, completion: @escaping(Result<[NewsStory], Error>)->Void){
        switch type {
        case .topStories:
            request(url: url(for: .topStories,
                             queryParams: ["category": "general"]),
                    expecting: [NewsStory].self,
                    completion: completion)
        case .company(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(Constant.day * 7))
            request(url: url(for: .companyNews,
                             queryParams: ["symbol": symbol,
                                           "from": DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                                           "to": DateFormatter.newsDateFormatter.string(from: today)]),
                    expecting: [NewsStory].self,
                    completion: completion)
        }
    
    }
    
    // MARK: - Search Stocks
    
    public func marketData(for symbol: String, numberOfDays: TimeInterval = 1, completion: @escaping(Result<MarketDataResponse, Error>)->Void){
        let today = Date().addingTimeInterval(-(Constant.day))
        let prior = today.addingTimeInterval(-(Constant.day * numberOfDays))
        request(url: url(for: .marketData,
                         queryParams: ["symbol": symbol,
                                       "resolution": "7",
                                       "from": "\(Int(prior.timeIntervalSince1970))",
                                       "to": "\(Int(today.timeIntervalSince1970))"]),
                expecting: MarketDataResponse.self,
                completion: completion)
    }
    
    public func financialMetrics(for symbol: String, completion: @escaping(Result<FinancialMetricsResponse, Error>)-> Void){
        let url = url(for: .financials, queryParams: ["symbol": symbol,
                                                      "metric": "all"])
        request(url: url,
                expecting: FinancialMetricsResponse.self,
                completion: completion)
    }
    
    //MARK: - Private
    private enum Endpoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "Stock/candle"
        case financials = "stock/metric"
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidUrl
    }
    
    //bu fonksiyon url yaratıyor
    private func url(for endpoint: Endpoint, queryParams: [String: String] = [:])-> URL? {
        
        var urlString = Constant.baseUrl + endpoint.rawValue
        
        var queryItems = [URLQueryItem]()
        
        for (key, value) in queryParams {
            queryItems.append(.init(name: key, value: value))
        }
        queryItems.append(.init(name: "token", value: Constant.apiKey))
        
        urlString += "?" + queryItems.map {
            "\($0.name)=\($0.value ?? "")"
        }.joined(separator: "&")
        
        return URL(string: urlString)
    }
    
    ///Perform api cell
    ///- Parameters:
    ///  - url: URL to hit
    ///  -expecting: Type we exxpect to decode data to
    ///   - completion: Result callbacl
    private func request<T: Codable>(url: URL?,
                                     expecting: T.Type,
                                     completion: @escaping (Result<T, Error>) -> Void){
        guard let url = url else{
            //Invalid url
            completion(.failure(APIError.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else{
                if let error = error {
                    completion(.failure(error))
                }
                else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
            do{
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            }
            catch{
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
}

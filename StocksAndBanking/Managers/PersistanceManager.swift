//
//  PersistanceManager.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import Foundation

final class PersistanceManager {
    
    static let shared = PersistanceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        static let onboardedKey = "hashOnboarded"
        static let watchListKey = "watchlist"
    }
    
    private init(){
        
    }
    
    //MARK: - Init
    public var watchlist: [String]{
        if !hasOnboarded{
            userDefaults.setValue(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchListKey) ?? []
    }
    
    public func watchListContains(symbol: String) -> Bool {
        return watchlist.contains(symbol)
    }
    
    public func addToWatchlist(symbol: String, companyName: String) {
        var current = watchlist
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchListKey)
        userDefaults.set(current, forKey: symbol)
        
        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }
    
    /// Remove item from watchlist
    ///  - Parameter symbol: symbol to remove
    public func removeFromWatchlist(symbol: String) {
        var newList = [String]()
        userDefaults.set(nil, forKey: symbol)
        for item in watchlist  where item != symbol {
            newList.append(item)
        }
        userDefaults.set(newList, forKey: Constants.watchListKey)
    }
    
    //MARK: - Private
    
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }
    
    private func setUpDefaults(){
        let map: [String: String] = [
            "AAPL": "Apple Inc",
            "MSFT": "Microsoft Corporation",
            "SNAP": "Snap Inc.",
            "GOOG": "Alphabet",
            "AMZN": "Amazon.com, Inc.",
            "WORK": "Slack Technologies",
            "FB": "Facebook Inc.",
            "NVDA": "Nvidia Inc.",
            "NKE": "Nike",
            "PINS": "Pinterest Inc."
        ]
        let symbol = map.keys.map{$0}
        userDefaults.setValue(symbol, forKey: Constants.watchListKey)
        
        for(symboll, name) in map {
            userDefaults.set(name, forKey: symboll)
        }
    }

}

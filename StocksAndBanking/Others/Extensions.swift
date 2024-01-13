//
//  Extensions.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import Foundation
import UIKit

//MARK: - Notification

extension Notification.Name {
    ///Notification for when symbol gets added to watchlist
    static let didAddToWatchList = Notification.Name("didAddToWatchList")
}

// NumberFormatter

extension NumberFormatter {
    ///Formatter for percent style
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    ///Formatter for decimal style
    static let numberFormatter: NumberFormatter = {
       let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
       return formatter
    }()
}
//ImageView

extension UIImageView{
    ///Sets image from remote url
    ///-Parameter url: URL to fetch from

    func setImage(with url: URL?){
        guard let url = url else{
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let task = URLSession.shared.dataTask(with: url){ [weak self] data, _, error in
                guard let data = data, error == nil else{
                    return
                }
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}

//MARK: -String

extension String{
    ///Create string from time interval
    ///-Parameter timeInterval: TimeInterval since 1970
    ///-Returns: Formatted string
    static func string(from timeInterval: TimeInterval) -> String {
     let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
        
   /*     let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        // Uygulama diline göre tarih ve saat bilgisini al
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        // Alternatif olarak sadece tarih bilgisini almak için:
        // dateFormatter.dateStyle = .medium
        // dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: date)
    */
    }
    
    ///Percentage formatted string
    ///- Parameter double: Double to format
    ///- Returns: String in percent format
    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentFormatter
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    ///Format number to string
    ///- Parameter number: Number to format
    ///- Returns: Formatted string
    static func formatted(number: Double) -> String{
        let formatted = NumberFormatter.numberFormatter
        return formatted.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

//MARK: - Dateformatter

extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "YYYY-MM-dd"
        return dateFormatter
    }()
    
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        //Uygulama diline göre tarih bilgisini al
        formatter.dateStyle = .medium
        return formatter
    }()
}

//MARK: - Add Subviews

extension UIView{
    func addSubviews(_views: UIView...){
        _views.forEach{
            addSubview($0)
        }
    }
}

//MARK: - Framing

extension UIView{
    //with of view
    var width: CGFloat{
        frame.size.width
    }
    
    //height of view
    var height: CGFloat{
        frame.size.height
    }
    
    //left edge of view
    var left: CGFloat{
        frame.origin.x
    }
    
    // right edge of view
    var right: CGFloat{
        left + width
    }
    
    //top edge of view
    var top: CGFloat{
        frame.origin.y
    }
    
    //bottom edge of view
    var bottom: CGFloat{
        top + height
    }
}

//MARK: - CandleStick Sorting
/*
extension Array where Element == CandleStick {
    func getPercentage() -> Double {
        // Dizinin ilk elemanının tarihini al
        let latestDate = self[0].date
        // Dizinin ilk elemanının kapanış fiyatını al
        guard let latestClose = self.first?.close,
              // Dizideki ilk öğeyi bul ve tarihleri karşılaştırarak aynı gün olmayanı seç
              let priorClose = self.first(where: {
                  !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
              })?.close else {
            // Eğer kapanış fiyatları alınamazsa veya tarih bulunamazsa 0 döndür
            return 0
        }
        // Kapanış fiyatları arasındaki yüzde değişimi hesapla
        let diff = 1 - (priorClose/latestClose)
        return diff
    }
}
*/

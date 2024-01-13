//
//  NewsStoryTableViewCell.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import UIKit
import SDWebImage

class NewsStoryTableViewCell: UITableViewCell {
    
    static let identifier = "NewsStoryTableViewCell"
    
    static let preferedHeight: CGFloat = 140
    
    struct ViewModel{
        let source: String
        let headline: String
        let dataString: String
        let imageUrl: URL?
        
        init(model: NewsStory){
            self.source = model.source
            self.headline = model.headline
            self.dataString = .string(from: model.datetime)
            self.imageUrl = URL(string: model.image)
        }
    }
    
    //Source
    private let sourceLabel: UILabel = {
       let label = UILabel()
        return label
    }()

}

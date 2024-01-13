//
//  WatchListTableViewCell.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import UIKit

protocol WatchListTableViewCellDelegate: AnyObject {
    func didUpdateMaxWidth()
}

class WatchListTableViewCell: UITableViewCell {
    
    static let identifier = "WatchListTableViewCell"
    
    static let prefferedHeight: CGFloat = 60
    
    weak var delagate: WatchListTableViewCellDelegate?
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String // formatted
        let changeColor: UIColor // red or green
        let changePergentage: String // formatted
     //   let chartViewModel: StockChartView.viewModel
    }
    
    //Symbol label
    private let symbolLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    //Company label
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .light)
        return label
    }()
    
    //Price label
    private let priceLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    //Change in Price label
    private let changeLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        label.textColor = .white
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()
    
    //Mini Chart
    private let miniChartView: StockChartView = {
        let chart = StockChartView()
        chart.isUserInteractionEnabled = false
        chart.clipsToBounds = true
        return chart
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.clipsToBounds = true
        
        addSubviews(_views: symbolLabel,
                    nameLabel,
                    miniChartView,
                    priceLabel,
                    changeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        symbolLabel.sizeToFit() // Text label'ın kendisi cell'e sığdırması için
        nameLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()
        
        let yStart: CGFloat = (contentView.height - symbolLabel.height - nameLabel.height)/2
        
        symbolLabel.frame = CGRect(x: separatorInset.left,
                                   y: yStart,
                                   width: symbolLabel.width,
                                   height: symbolLabel.height)
        
        nameLabel.frame = CGRect(x: separatorInset.left,
                                 y: symbolLabel.bottom,
                                 width: symbolLabel.width,
                                 height: symbolLabel.height)
        
        let currentWidth = max(max(priceLabel.width, changeLabel.width),
                               WatchListViewController.maxChangeWidth)
        
        if currentWidth > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currentWidth
            delagate?.didUpdateMaxWidth()
        }
        
        priceLabel.frame = CGRect(x: contentView.width - 10 - currentWidth,
                                  y: (contentView.height - priceLabel.height - changeLabel.height)/2,
                                  width: currentWidth,
                                  height: priceLabel.height)
        
        changeLabel.frame = CGRect(x: contentView.width,
                                   y: priceLabel.bottom,
                                   width: currentWidth,
                                   height: changeLabel.height)
        
        miniChartView.frame = CGRect(x: priceLabel.left - (contentView.width/3) - 5,
                                     y: 6,
                                     width: contentView.width/3,
                                     height: contentView.height-12)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
     //   miniChartView.reset()
    }
    
    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePergentage
        changeLabel.backgroundColor = viewModel.changeColor
        //Configure chart
    //    miniChartView.configure(with: viewModel.chartViewModel)
    }

}

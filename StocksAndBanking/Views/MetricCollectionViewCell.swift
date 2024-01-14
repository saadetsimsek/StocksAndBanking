//
//  MetricCollectionViewCell.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import UIKit

class MetricCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MetricCollectionViewCell"
    
    struct ViewModel{
        let name: String
        let value: String
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        addSubviews(_views: nameLabel, valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        valueLabel.sizeToFit()
        nameLabel.sizeToFit()
        
        nameLabel.frame = CGRect(x: 3,
                                 y: 0,
                                 width: nameLabel.width,
                                 height: contentView.height)
        valueLabel.frame = CGRect(x: nameLabel.right + 3 ,
                                  y: 0,
                                  width: valueLabel.width,
                                  height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        valueLabel.text = nil
    }
    
    func configure(with viewModel: ViewModel){
        nameLabel.text = viewModel.name + ":"
        valueLabel.text = viewModel.value
    }
}

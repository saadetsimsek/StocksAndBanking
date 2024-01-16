//
//  StockDetailHeaderView.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import UIKit

class StockDetailHeaderView: UIView {

    private var metricViewModels: [MetricCollectionViewCell.ViewModel] = []
    
    //Chart View
    private let chartView = StockChartView()
    
    //CollectionView
    private let CollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //register cell
        collectionView.register(MetricCollectionViewCell.self, forCellWithReuseIdentifier: MetricCollectionViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        addSubviews(_views: chartView, CollectionView)
        CollectionView.delegate = self
        CollectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        chartView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: width,
                                 height: height-100)
        CollectionView.frame = CGRect(x: 0,
                                      y: height-100,
                                      width: width,
                                      height: 100)
    }
    
    func configure(chartViewMode: StockChartView.ViewModel,
                   metricViewModels: [MetricCollectionViewCell.ViewModel]){
        //Update chart
        chartView.configure(with: chartViewMode) // şemayı güncelle
        self.metricViewModels = metricViewModels // metrik veri modellerini güncelle
        CollectionView.reloadData() // koleksiyon görünümünü yeniden yükle
    }
    
}

//MARK: - Collection View

extension StockDetailHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = metricViewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MetricCollectionViewCell.identifier, for: indexPath) as? MetricCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/2, height: 100/3)
    }
}

//
//  StockDetailsViewController.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import UIKit
import SafariServices

class StockDetailsViewController: UIViewController {
    
    //Symbol, Company name, Chart data
    
    //MARK: - Properties
    
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    
    //symbol, company name, chart data
    
    
    //MARK: - Properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        tableView.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        return tableView
    }()
    
    private var stories: [NewsStory] = []
    
    private var metrics: Metric?
    
    //MARK: - Init
    
    init(symbol: String, companyName: String, candleStickData: [CandleStick]=[]) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = companyName
        setUpTable()
        setUpCloseButton()
        fetchFinancialData()
        fetchNews()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setUpCloseButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(didTapClose))
    }
    
    @objc private func didTapClose(){
        dismiss(animated: true, completion: nil)
    }
    
    private func setUpTable(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: view.width,
                                                         height: (view.width * 0.7) + 100))// tableView üzerine view ekleyerek ekranı bölme
    }
    
    private func fetchFinancialData(){
        let group = DispatchGroup()
        
        if candleStickData.isEmpty{
            group.enter()
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        group.enter()
        
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer{
                group.leave()
            }
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }
    
    private func fetchNews(){
        APICaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.asyncAndWait {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func renderChart(){ // grafik görünümünü oluşturmak ve görüntülemek için kullanılır
        // Chart VM ! FinancialMetricViewModel(s)
        let headerView = StockDetailHeaderView(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: view.width,
                                                             height: (view.width *  0.7) + 100))
        var viewModels = [MetricCollectionViewCell.ViewModel]()
        if let metrics {
            viewModels.append(.init(name: "52W High", value: "\(metrics.the52WeekHigh)"))
            viewModels.append(.init(name: "52L High", value: "\(metrics.the52WeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.the52WeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol.", value: "\(metrics.the10DayAverageTradingVolume)"))
        }
        
        //Configure
        let change = candleStickData.getPercentage()
            headerView.configure(
                chartViewMode: .init(
                    data: candleStickData.reversed().map {$0.close},
                    showLegend: true,
                    showAxis: true,
                    fillColor: change < 0 ? .systemRed : .systemGreen),
                metricViewModels: viewModels
            )
            tableView.tableHeaderView = headerView
        
    }
}
    
    extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return stories.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else {
                fatalError()
            }
            cell.configure(with: .init(model: stories[indexPath.row]))
            return cell
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return NewsStoryTableViewCell.preferedHeight
        }
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else{
                return nil
            }
            header.delegate = self
            header.configure(with: .init(title: symbol.uppercased(), shouldShowAddButton: !PersistanceManager.shared.watchListContains(symbol: symbol)))
            // Sadece wathlistte zaten yoksa ekle butonu göstermek için persistent managerden fonksiyon yazdık
            return header
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return NewsHeaderView.preferedHeight
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            guard let url = URL(string: stories[indexPath.row].url) else {
                return
            }
            
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
    
    extension StockDetailsViewController: NewsHeaderViewDelegate {
        func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
            
            headerView.button.isHidden = true
            PersistanceManager.shared.addToWatchlist(symbol: symbol, companyName: companyName)
            
            let alert = UIAlertController(title: "Added to your Watchlist",
                                          message: "We've added \(companyName) to your watchlist",
                                          preferredStyle: .alert )
            alert.addAction(UIAlertAction(title: "Dismiss",
                                          style: .cancel,
                                          handler: nil))
            present(alert, animated: true)
        }
        
        
    }


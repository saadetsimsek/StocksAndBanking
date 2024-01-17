//
//  WatchListViewController.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {
    
    private var searchTimer: Timer?
    
    private var panel: FloatingPanelController?
    
    static var maxChangeWidth: CGFloat = 0
    
    ///view Models
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    ///Model
    private var watchlistMap: [String:[CandleStick]] = [:]
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
        return table
    }()
    
    private var observer: NSObjectProtocol?

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        setUpSearchController()
        setUpTableView()
        
        setUpFloatingPanel()
        setUpTitleView()
        setUpObserver()
        fetchWatchlistData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setUpTableView(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: - Private
    
    private func setUpObserver(){
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchList,
                                                          object: nil,
                                                          queue: .main){ [weak self] _ in
            self?.viewModels.removeAll()
            self?.fetchWatchlistData()
            
        }
    }
    
    private func fetchWatchlistData(){
        let symbols = PersistanceManager.shared.watchlist
        
        createPlaceHolderViewModels()
        
        let group = DispatchGroup()
        
        for symbol in symbols where watchlistMap[symbol] == nil {
            group.enter()
            
            //Fetch market data per symbol
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        group.notify(queue: .main){ [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    private func createPlaceHolderViewModels(){
        let symbols = PersistanceManager.shared.watchlist
        symbols.forEach{ item in
            viewModels.append(.init(symbol: item,
                                    companyName: UserDefaults.standard.string(forKey: item) ?? "company",
                                    price: "0.00",
                                    changeColor: .systemGreen,
                                    changePercentage: "0.00",
                                    chartViewModel: .init(data: [],
                                                          showLegend: false,
                                                          showAxis: false,
                                                          fillColor: .clear)))
            
        }
        self.viewModels = viewModels.sorted(by: { $0.symbol < $1.symbol})
        tableView.reloadData()
    }
    
    private func createViewModels(){
        var viewModels = [WatchListTableViewCell.ViewModel]()
        
        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = candleSticks.getPercentage()
            
            viewModels.append(.init(symbol: symbol,
                                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                                    price: getLatestClosingPrice(from: candleSticks),
                                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                                    changePercentage: .percentage(from: changePercentage),
                                    chartViewModel: .init(data: candleSticks.reversed().map{$0.close},
                                                          showLegend: false,
                                                          showAxis: false,
                                                          fillColor: changePercentage < 0 ? .systemRed: .systemGreen)))
        }
        //Watchlisti alfabetik sıralamak için
        self.viewModels = viewModels.sorted(by: {$0.symbol < $1.symbol})
    }
    
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else{
            return ""
        }
        return .formatted(number: closingPrice)
    }
    
    private func setUpFloatingPanel(){
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.tableView)
    }
    
    private func setUpTitleView(){
        let titleView = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: view.width,
                                             height: navigationController?.navigationBar.height ?? 100))
        let label = UILabel(frame: CGRect(x: 10,
                                          y: 0,
                                          width: titleView.width-20,
                                          height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 40, weight: .medium)
        titleView.addSubview(label)
        
        navigationItem.titleView = titleView
    }
    
    private func setUpSearchController(){
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self // kullanıcının klavyede bir tuşa bastığıı anlıyoruz(her basışında bu fonksiyon çağrılır)
        navigationItem.searchController = searchVC
    }

}

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
                let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        //Optimize to reduce number of searches for when user stops typing
        
        //Reset timer
        searchTimer?.invalidate()
        
        //Kick off new timer
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3,
                                           repeats: false,
                                           block: { _ in
            //Call API to search
            APICaller.shared.search(query: query){ result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async{
                        resultsVC.update(with: response.result)
                    }
                case .failure(let error):
                    DispatchQueue.main.async{
                        resultsVC.update(with: [])
                    }
                    print(error)
                }
            }
        })
        //update results controller
    }
    
}
extension WatchListViewController: SearchResultsViewControllerDelegate{
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()//sonuçlara tıklayınca klavyenin kapanması için
        
        //present stock details for given selection
        HapticsManager.shared.vibrateForSelection()
        
        let vc = StockDetailsViewController(symbol: searchResult.displaySymbol,
                                            companyName: searchResult.description)
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true)
    }
}

extension WatchListViewController: FloatingPanelControllerDelegate{
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        //flating panel'i yukarı kaldırınca asıl VC deki title gitmesi için
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else {
            fatalError()
        }
        cell.delagate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.prefferedHeight
    }
    
    //Swipe to delete
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            //Update persistance
            PersistanceManager.shared.removeFromWatchlist(symbol: viewModels[indexPath.row].symbol)
            
            //Update viewModels
            viewModels.remove(at: indexPath.row)
            
            //Delete Row
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            tableView.endUpdates()
        }
    }
    
    //Delete Done
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Open details for selection
        HapticsManager.shared.vibrateForSelection()
        
        let viewModel = viewModels[indexPath.row]
        
        let vc = StockDetailsViewController(symbol: viewModel.symbol,
                                            companyName: viewModel.companyName,
                                            candleStickData: watchlistMap[viewModel.symbol] ?? [])
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
}
extension WatchListViewController: WatchListTableViewCellDelegate {
    func didUpdateMaxWidth() {
        //Optimize: Only refresh rows prior to current row that changes the max width
        tableView.reloadData()
    }
}

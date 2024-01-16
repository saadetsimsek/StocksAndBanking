//
//  SearchResultsViewController.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult)
}

class SearchResultsViewController: UIViewController {
    
    private var results: [SearchResult] = []
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        //register cell
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        view.backgroundColor = .systemBackground
        
       
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setUpTable(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func update(with results: [SearchResult]){
        self.results = results
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
    }

}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
        let model = results[indexPath.row]
        cell.textLabel?.text = model.displaySymbol
        cell.detailTextLabel?.text = model.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = results[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchResultsViewControllerDidSelect(searchResult: model)
    }
}

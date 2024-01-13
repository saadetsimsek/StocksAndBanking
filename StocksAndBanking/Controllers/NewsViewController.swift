//
//  NewsViewController.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    
    enum Typee {
        case topStories
        case company(symbol: String)
        
        var title: String{
            switch self{
            case .topStories:
                return "Top Stories"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    //MARK: - Properties
    
    private var stories = [NewsStory]()
    
    private let type: Typee
    
    let tableView: UITableView = {
       let tableView = UITableView()
        tableView.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        tableView.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    init(type: Typee){
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTable()
        
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
    }
    
    //MARK: - Private
    
    private func setUpTable(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func open(url: URL){
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }


}
extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else {
            fatalError()
        }
        cell.textLabel?.text = "yaa"
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableCell(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.prefedHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferedHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //open news Story
        
        let story = stories[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentFailedToOpenAlert()
            return
        }
     //   open(url: url)
    }
    
    private func presentFailedToOpenAlert(){
        let alert = UIAlertController(title: "Unable to open",
                                      message: "We are unable to open this article",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
    }

}

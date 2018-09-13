//
//  TransactionsHistoryViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

protocol TransactionsHistoryDelegate: class {
    func didFinishLoadingData()
    func didNotLoadData()
    func couldNotLoadMoreData()
    func showMACHCardInformation()
}

class TransactionsHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!

    let cellIdentifier = "TransactionsCell"
    let footerIdentifier = "footer"

    // MARK: - Variables
    weak var delegate: TransactionsHistoryDelegate?

    //Each time the date or the filter is updated we inform the presenter about that
    var dateFilter: Date? {
        didSet {
            presenter?.dateFilter = dateFilter
        }
    }
    var filter: TransactionsFilter? {
        didSet {
             presenter?.transactionsFilter = filter
        }
    }
    var presenter: TransactionsHistoryPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "\(TransactionsViewCell.self)", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.register(UINib(nibName: "\(TransactionsFooterViewCell.self)", bundle: nil), forCellReuseIdentifier: footerIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65.0
    }

    @IBAction func machCardMoreInformationTapped(_ sender: Any) {
        self.delegate?.showMACHCardInformation()
    }
}
extension TransactionsHistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.transactionsCount() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let presenter = self.presenter else {
            //By this point the presenter has to be initialized
            fatalError()
        }
        if indexPath.row < presenter.transactionsCount() - 1 {
            let genericCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            guard let transactionCell = genericCell as? TransactionsViewCell else { return genericCell }
            guard let model = presenter.transaction(at: indexPath.row) else { return transactionCell }
            transactionCell.initialize(with: model, evenRow: indexPath.row.isEven)
            return transactionCell
        } else {
            let genericCell = tableView.dequeueReusableCell(withIdentifier: footerIdentifier, for: indexPath)
            guard let footerCell = genericCell as? TransactionsFooterViewCell else { return genericCell }
            footerCell.initialize(with: presenter.getFooterViewModel(), isEven: indexPath.row.isEven)
            footerCell.delegate = self
            return footerCell
        }
    }

}

extension TransactionsHistoryViewController: TransactionsHistoryViewProtocol {

    func didFetchTransactions() {
        tableView.reloadData()
        delegate?.didFinishLoadingData()
    }

    func didNotFetchTransactions() {
        tableView.reloadData()
        delegate?.didNotLoadData()
    }

    func showTableViewBackground(with flag: Bool, message: String) {
        if flag {
            if let emptyTableView = NoTransactionsView.instanceFromNib() {
                emptyTableView.setlabel(with: message)
                tableView.backgroundView = emptyTableView
            }
        } else {
            tableView.backgroundView = nil
        }
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    func couldNotFetchMoreData() {
        delegate?.couldNotLoadMoreData()
    }
    
    func showHeaderView() {
        self.tableView?.tableHeaderView = headerView
    }
    
    func hideHeaderView() {
        self.tableView?.tableHeaderView = nil
    }
}

extension TransactionsHistoryViewController: TransactionsFooterDelegate {
    func didPressLoadMore() {
        //Ask the presenter to load the next pages
        presenter?.loadNextPages()
    }
}

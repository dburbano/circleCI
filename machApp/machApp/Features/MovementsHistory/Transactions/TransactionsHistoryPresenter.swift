//
//  TransactionsHistoryPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class TransactionsHistoryPresenter: TransactionsHistoryPresenterProtocol {
    
    let numberOfPagesToLoad = 3
    
    weak var view: TransactionsHistoryViewProtocol?
    var repository: TransactionsHistoryRepositoryProtocol?
    
    var dateFilter: Date? {
        didSet {
            if oldValue != nil {
                repository?.cancelOperations()
            }
            //We use DispatchQueue.main.asyncin order to avoid "Simultaneous access error"
            DispatchQueue.main.async {[weak self] in
                guard let weakSelf = self else { return }
                weakSelf.restartVariables()
                weakSelf.fetchTransactions(with: weakSelf.dateFilter, transactionsFilter: weakSelf.transactionsFilter)
                weakSelf.view?.showTableViewBackground(with: false, message: "")
            }
        }
    }

    var transactionsFilter: TransactionsFilter? {
        didSet {
            //Every time the filter changes, we need to reset the list
            filteredTransactions = [TransactionModel]()
            filterTransactions()
        }
    }
    var transactions: [TransactionModel]?
    
    //Pagination variables
    var nextPage: String?
    var lastID: String = ""
    var initID: String = ""
    var backgroundLoadPages: Int = 3
    
    //The purpose of this array is to have transactions's filtered elements, so we do not need the call the repo everytime the filter changes.
    var filteredTransactions: [TransactionModel] = [TransactionModel]()
    
    required init(repository: TransactionsHistoryRepositoryProtocol?) {
        self.repository = repository
    }
    
    func set(view: TransactionsHistoryViewProtocol) {
        self.view = view
    }
    
    func transactionsCount() -> Int {
        //We need to update the table's background view, since every time the user changes month we need to show it of hide it depending on whether there are transactions or not.
        updateTableBackgroundView()
        
        let next = nextPage != nil
        let empty = filteredTransactions.isEmpty
        
        /*
         We have 2 case scenarios:
            1.There are no more pages to load AND there are no transactions
                return 0 since there's nothing to show
            2.Else
                return transactions + 1 
         */
        
        if !next && empty {
            return 0
        } else {
            return filteredTransactions.count + 1
        }
    }
    
    func transaction(at row: Int) -> HistoryViewModel? {
        return HistoryViewModel(with: filteredTransactions[row])
    }
    
    func getFooterViewModel() -> TransactionFooterViewModel? {
        //If there are transactions, then show the footer
        if let last = transactions?.last {
            //Here the catch is that if there are more pages, show the label "Cargar Más". Otherwise, do not show it.
            let state: FooterState = nextPage != nil ? .moreTransactionsAvailable : .noMoreTransactionsAvailable
            return TransactionFooterViewModel(date: last.transactionDate, state: state)
        } else {
            //If there are no more transactions do not show it. FYI if the state is .noMoreTransactionsAvailable, then the footer is not going to be shown.
            return TransactionFooterViewModel(date: Date(), state: .noMoreTransactionsAvailable)
        }
    }
    
    func loadNextPages() {
        backgroundLoadPages += numberOfPagesToLoad
        backgroundFetch()
    }
    
    private func fetch(with flag: Bool, date: Date, filter: TransactionsFilter, page: String) {
        repository?.fetchTransactionsPaginated(with: date,
                                               page: page,
                                               lastID: lastID,
                                               initID: initID,
                                               onSuccess: {[weak self] historyModel in
                                                //Update presenter info
                                                self?.updateVariables(with: historyModel, appendFlag: true)
                                                /*
                                                 We need to make a couple of validations.
                                                 If self?.nextPage != nil that means there's stil another page to be fetched.
                                                 If flag = true that means we can fetch another page, since we are fetching 3 pages every time the user taps on "load more"
                                                 So the catch here is that both of these conditions have to be met in order to fetch more pages from the back-end.
                                                 */
                                                if flag && self?.nextPage != nil {
                                                    self?.backgroundFetch()
                                                    
                                                } else {
                                                    if filter != .allMovements {
                                                        self?.filterTransactions()
                                                    } else {
                                                        self?.view?.didFetchTransactions()
                                                    }
                                                    
                                                }
            }, onFailure: { [weak self] in
                guard let intPage = Int(page) else { return }
                
                /*
                 The logic here is the following:
                 If page is > 1, that means we've been able to fetch something so we can reload the table and show whatever we have.
                 If page <= 1, that means we havent loaded anything, so we need to show the banner "Ups something happened..."
                 */
                if intPage > 1 {
                    self?.view?.couldNotFetchMoreData()
                    self?.view?.reloadTable()
                } else {
                    self?.view?.didNotFetchTransactions()
                }
        })
    }
    
    private func backgroundFetch() {
        guard let date = dateFilter,
            let transactionsFilter = transactionsFilter,
            let page = nextPage,
            let intPage = Int(page) else { return }
        fetch(with: intPage < backgroundLoadPages, date: date, filter: transactionsFilter, page: page)
    }
    
    /*
     The logic is the following:
     If the date is changed, we have to fetch the data from the endpoint
     If the filter changed we need to filter the array we have, transactions, and assing such data in filteredTransactions
     If the date is changed AND the filter != .allMovements we have to fetch the data from the endpoint and filter it
     Therefore we have 2 methods. One to fetch data and another to filter
     */
    private func fetchTransactions(with dateFilter: Date?, transactionsFilter: TransactionsFilter?) {
        //Clear table while we load the history
        if let transactions = self.transactions, !transactions.isEmpty {
            self.transactions = []
            filteredTransactions = []
            view?.reloadTable()
        }
        
        guard let date = dateFilter else { return }
        repository?.fetchTransactions(with: date, onSuccess: {[weak self] historyModel in
            //Update presenter info
            self?.updateVariables(with: historyModel, appendFlag: false)
            if self?.nextPage != nil {
                self?.backgroundFetch()
            } else {
                //If there's only one page available for the month the user just selected, then we need to check if there's a filter. 
                if transactionsFilter != .allMovements {
                    self?.filterTransactions()
                } else {
                    self?.view?.didFetchTransactions()
                }
                
            }
            }, onFailure: { [weak self] in
                self?.transactions = []
                self?.filteredTransactions = []
                self?.view?.reloadTable()
                self?.lastID = ""
                self?.initID = ""
                self?.nextPage = nil
                self?.view?.didNotFetchTransactions()
        })
    }
    
    private func filterTransactions() {
        //Date is unwrapped just to use it in analytics
        guard let transactions = transactions, let _ = dateFilter, let transactionsFilter = transactionsFilter
            else { return }
        
        filteredTransactions = transactionsFilter == .allMovements ? transactions : transactions.filter({
            $0.transactionFilterType == transactionsFilter.mapIntoHistoryFilter()
        })
        
        //This is just to avoid the simultaneous access error
        DispatchQueue.main.async {[weak self] in
            self?.view?.didFetchTransactions()
            self?.updateHeaderView()
        }
    }

    
    private func updateVariables(with historyModel: HistoryModel, appendFlag: Bool) {
        //Update pagination variables
        nextPage = historyModel.page.next
        lastID = historyModel.lastID
        initID = historyModel.initID
        
        //Update data source
        if appendFlag {
            transactions?.append(contentsOf: historyModel.array)
            filteredTransactions.append(contentsOf: historyModel.array)
        } else {
            transactions = historyModel.array
            filteredTransactions = historyModel.array
        }
    }
    
    //The purpose of this method is to tell the VC to show or not to show the tableview background.
    private func updateTableBackgroundView() {
        //If there are more pages available to fetch from the server, hide the table's background view.
        if nextPage != nil || transactions == nil {
            view?.showTableViewBackground(with: false, message: "")
        } else {
           
            if let filter = transactionsFilter {
                //IF there are transactions in the filtered array, hide the table's background. Otherwise, show it.
                if !filteredTransactions.isEmpty {
                    view?.showTableViewBackground(with: false, message: "")
                } else {
                    switch filter {
                    case .allMovements:
                        view?.showTableViewBackground(with: true, message: "Buu. Este mes no hiciste nada divertido con nosotros 😒")
                    case .moneyRecharge:
                        view?.showTableViewBackground(with: true, message: "No cargaste tu cuenta MACH este mes 💰")
                    case .moneyWithdrawl:
                        view?.showTableViewBackground(with: true, message: "No hiciste retiros este mes 🤑")
                    case .receivedPayments:
                        view?.showTableViewBackground(with: true, message: "No recibiste ningún pago este mes 😢")
                    case .sentPayments:
                        view?.showTableViewBackground(with: true, message: "No le pagaste a nadie este mes 😅")
                    case .machCard:
                        view?.showTableViewBackground(with: true, message: "No hiciste compras con tu tarjeta MACH este mes 💳" )
                    }
                }
            }
        }
    }
    
    private func updateHeaderView() {
        if let filter = transactionsFilter {
            switch filter {
            case .allMovements, .machCard:
                self.view?.showHeaderView()
            default:
                self.view?.hideHeaderView()
            }
        }
    }
    
    private func restartVariables() {
        nextPage = nil
        lastID = ""
        initID = ""
        backgroundLoadPages = 3
    }
}

//
//  TransactionsHistoryContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

enum TransactionsFilter: String {
    case allMovements = "Todos los movimientos"
    case machCard = "Tarjeta MACH"
    case receivedPayments = "Pagos recibidos"
    case sentPayments = "Pagos hechos"
    case moneyRecharge = "Recargas de dinero"
    case moneyWithdrawl = "Retiros de dinero"

    static func getCase(with index: Int) -> TransactionsFilter {
        switch index {
        case 0:
            return .allMovements
        case 1:
            return .machCard
        case 2:
            return .receivedPayments
        case 3:
            return .sentPayments
        case 4:
            return .moneyRecharge
        default:
            return .moneyWithdrawl
        }
    }
    
    static func getIndex(with filterCase: TransactionsFilter) -> Int {
        switch filterCase {
        case .allMovements:
            return 0
        case .machCard:
            return 1
        case .receivedPayments:
            return 2
        case .sentPayments:
            return 3
        case .moneyRecharge:
            return 4
        case .moneyWithdrawl:
            return 5
        }
    }
    
    static func getAnalyticsString(with filterCase: TransactionsFilter) -> String {
        switch filterCase {
        case .allMovements:
            return "Todos"
        case .receivedPayments:
            return "PagosDe"
        case .sentPayments:
            return "PagosA"
        case .moneyRecharge:
            return "Recarga"
        case .moneyWithdrawl:
            return "Retiro"
        case .machCard:
            return "TarjetaMACH"
        }
    }
    
    func mapIntoHistoryFilter() -> TransactionFilterType? {
        switch self {
        case .allMovements:
            return nil
        case .machCard:
            return TransactionFilterType.machCard
        case .receivedPayments:
            return TransactionFilterType.paymentReceived
        case .sentPayments:
            return TransactionFilterType.paymentSent
        case .moneyRecharge:
            return TransactionFilterType.cashIn
        case .moneyWithdrawl:
            return TransactionFilterType.cashout
        }
    }
    
    static let allValues = [allMovements, machCard, receivedPayments, sentPayments, moneyRecharge, moneyWithdrawl]
}

protocol TransactionsHistoryViewProtocol: class {
    func didFetchTransactions()
    func didNotFetchTransactions()
    func showTableViewBackground(with flag: Bool, message: String)
    func reloadTable()
    func couldNotFetchMoreData()
    func hideHeaderView()
    func showHeaderView()
}

protocol TransactionsHistoryPresenterProtocol: BasePresenterProtocol {
    var dateFilter: Date? { get set }
    var transactionsFilter: TransactionsFilter? { get set }
    func set(view: TransactionsHistoryViewProtocol)
    func transactionsCount() -> Int
    func transaction(at row: Int) -> HistoryViewModel?
    func getFooterViewModel() -> TransactionFooterViewModel?
    func loadNextPages()
}

protocol TransactionsHistoryRepositoryProtocol {
    func fetchTransactions(with date: Date,
                           onSuccess: @escaping (HistoryModel) -> Void,
                           onFailure: @escaping () -> Void)
    
    //swiftlint:disable:next function_parameter_count
    func fetchTransactionsPaginated(with date: Date,
                                    page: String,
                                    lastID: String,
                                    initID: String,
                                    onSuccess: @escaping (HistoryModel) -> Void,
                                    onFailure: @escaping () -> Void)
    func cancelOperations()
}

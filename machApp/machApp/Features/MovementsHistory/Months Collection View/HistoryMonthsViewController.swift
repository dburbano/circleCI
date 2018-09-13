//
//  HistoryMonthsViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

protocol HistoryMonthsDelegate: class {
    func didSelect(date: Date)
    func couldntLoadDates()
}

class HistoryMonthsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    let cellIdentifier: String = "MonthCell"
    var presenter: HistoryMonthsPresenterProtocol?
    weak var delegate: HistoryMonthsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        presenter?.fetchHistoryMonths()
    }

    private func setupCollectionView() {
        collectionView.register(UINib.init(nibName: "\(MonthViewCell.self)", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }
}

extension HistoryMonthsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.elementsCount() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        if let cell = cell as? MonthViewCell, let element = presenter?.element(at: indexPath.row) {
            cell.inittialize(with: element)
        }
        return cell
    }
}

extension HistoryMonthsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MonthViewCell,
        let date = cell.monthDate?.date  else { return }
        delegate?.didSelect(date: date)
    }
}

extension HistoryMonthsViewController: HistoryMonthsViewProtocol {

    func didFetchHistoryMonths() {
        collectionView.reloadData()
        let indexPath = IndexPath.init(row: 0, section: 0)
        //Give the collection view to load itself
        collectionView.performBatchUpdates(nil) {[weak self] (flag) in
            guard let weakSelf = self, flag else { return }
            weakSelf.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            weakSelf.collectionView(weakSelf.collectionView, didSelectItemAt: indexPath)
        }
    }

    func didNotFetchHistoryMonths() {
        delegate?.couldntLoadDates()
    }

    func showNoInternetConnectionError() {}
    func showServerError() {}
}

//
//  PrepaidCardMenuTableViewController.swift
//  machApp
//
//  Created by Lukas Burns on 3/21/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class PrepaidCardMenuTableViewController: UITableViewController {

    var presenter: PrepaidCardMenuTablePresenterProtocol?
    var delegate: PrepaidCardHomeProtocol?
    
    let showCashIn: String = "showCashIn"
    let zendeskArticleName: String = "filter_faqtarjetamach"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter?.set(delegate: delegate!)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showCashIn, let destinationVC = segue.destination.childViewControllers.first as? CashInViewController {
            destinationVC.isBackButtonHidden = false
        }
    }

    // MARK: - Table view data delegate
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = Color.violetBlue
            header.textLabel?.nunitoBoldFont(size: 16.0)
            header.backgroundView?.backgroundColor = UIColor.white
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter?.tableViewDidSelectRow(indexOf: indexPath.row)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}

extension PrepaidCardMenuTableViewController: PrepaidCardMenuTableViewProtocol {
    func showZendeskArticle() {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().mach_card, helpTagAccessed: self.zendeskArticleName).track()
    }

    func showNoInternetConnectionError() {

    }

    func showServerError() {

    }
}

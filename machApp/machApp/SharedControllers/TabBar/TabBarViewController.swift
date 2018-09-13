//
//  TabBarViewController.swift
//  machApp
//
//  Created by lukas burns on 3/10/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import RealmSwift
#if STAGING
    import HockeySDK
#endif
#if DEBUG
    import HockeySDK
#endif

class TabBarViewController: UITabBarController {

    var presenter: TabBarPresenterProtocol?
    var loadingActivityIndicator: UIActivityIndicatorView?

    internal enum TabTag: Int {
        case home = 1
        case request = 2
        case payment = 3
        case card = 4
        case charge = 5
    }

    internal let showPayment = "showPayment"
    internal let showRequest = "showRequest"
    internal let showPrepaidCards = "showPrepaidCards"
    internal let kBarHeight: CGFloat = 49

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        presenter?.getHistory()

        tabBar.layer.shadowRadius = 3.5
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0.0, height: -0.5)
        tabBar.layer.shadowOpacity = 0.2
        tabBar.layer.borderWidth = 0.0
        
        tabBar.shadowImage = UIImage(color: UIColor.clear)
        tabBar.backgroundImage = UIImage(color: Color.winterWhite)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.showBadgeOnCardIcon()
    }

    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.selectedViewController
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showPayment {
            if let destinationController = (segue.destination as? UINavigationController)?.viewControllers[0] as? SelectUsersViewController {
                destinationController.transactionMode = TransactionMode.payment
                destinationController.viewMode = .normalTransaction
            }
        } else if segue.identifier == showRequest {
            if let destinationController = (segue.destination as? UINavigationController)?.viewControllers[0] as? SelectUsersViewController {
                destinationController.transactionMode = TransactionMode.request
                if let presenter = presenter, !presenter.areThereTransactions() {
                    destinationController.transactionMode = .machRequest
                    destinationController.viewMode = .chargeMach
                } else {
                    destinationController.viewMode = .normalTransaction
                }
            }
        }
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let selectedTag = TabTag(rawValue: item.tag) {
            switch selectedTag {
            case .request:
                performSegue(withIdentifier: showRequest, sender: self)
            case .payment:
                performSegue(withIdentifier: showPayment, sender: self)
            case .card:
                guard self.selectedIndex != TabTag.card.rawValue - 1 else { return }
                AccountManager.sharedInstance.setUserHasAccessedPrepaidCard(accessed: true)
                presenter?.getCreditCard()
            default:
                break
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            #if STAGING
                BITHockeyManager.shared().feedbackManager.showFeedbackComposeViewWithGeneratedScreenshot()
            #elseif DEBUG
                BITHockeyManager.shared().feedbackManager.showFeedbackComposeViewWithGeneratedScreenshot()
            #endif
        }
    }

    func selectTab(tag: TabTag) {
        self.selectedIndex = tag.rawValue - 1
    }
    
    func addActivityIndicator(to viewController: UIViewController) {
        
        loadingActivityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        loadingActivityIndicator?.startAnimating()
        guard let loadingIndicator = loadingActivityIndicator else { return }
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingIndicator.color = Color.greyishBrown.withAlphaComponent(0.7)
        loadingIndicator.backgroundColor = UIColor.clear
        view.addSubview(loadingIndicator)
        // Tricky way of getting the third tab's view
        guard let items = tabBar.items?[TabTag.card.rawValue - 1].value(forKey: "view") as? UIView else { return }
        loadingIndicator.centerXAnchor.constraint(equalTo: items.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: items.centerYAnchor, constant: -5.0).isActive = true
        loadingIndicator.widthAnchor.constraint(equalTo: items.widthAnchor).isActive = true
        loadingIndicator.heightAnchor.constraint(equalTo: items.heightAnchor).isActive = true
        let transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        loadingIndicator.transform = transform
        loadingIndicator.layoutIfNeeded()
    }
}

extension TabBarViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is TransactionNavigationViewController || viewController is PrepaidCardNavigationViewController {
            return false
        }
        return true
    }
}

extension TabBarViewController: TabBarViewProtocol {

    func navigateToPrepaidCards(with cards: [PrepaidCard]) {
        if let prepaidCardViewController = self.viewControllers?.get(at: 3) as? PrepaidCardNavigationViewController {
            prepaidCardViewController.prepaidCards = cards
            self.selectedViewController = prepaidCardViewController
            self.tabBar.isHidden = false
            print("Navigating to Prepaid Card from TabBar")
        }
    }
    
    func navigateToStartAuthenticationProcess() {
        let storyboard = UIStoryboard(name: "AuthenticationProcess", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "StartAuthenticationProcessViewController") as? StartAuthenticationProcessViewController {
            viewController.goal = AuthenticationGoal.prepaidCard
            viewController.authenticationDelegate = self.presenter
            self.presentVC(viewController)
        }
    }
    
    func showServerError() {
        ToastManager.sharedInstance.show(withText: NSLocalizedString("unkwnown-error-message", comment: ""))
    }

    func showLoadingIndicator(with hiddenFlag: Bool) {
        hideBadgeIconToItem(item: 3)
        if hiddenFlag {
            guard let selectedVC = selectedViewController as? UINavigationController,
                let rootVC = selectedVC.visibleViewController else { return }
            tabBar.items?[3].image = UIImage(color: UIColor.clear)
            addActivityIndicator(to: rootVC)

        } else {
            if let loadingIndicator = loadingActivityIndicator {
                loadingIndicator.removeFromSuperview()
                tabBar.items?[3].image = #imageLiteral(resourceName: "iconFinoVisa")
            }
        }
    }
    
    func showBadgeOnCardIcon() {
        
        guard !doesCardExist() else { return }
        
        if !AccountManager.sharedInstance.userHasAccessedPrepaidCard() {
            self.showBadgeIconToItem(item: 3)
        } else {
            self.hideBadgeIconToItem(item: 3)
        }
    }
    
    func doesCardExist() -> Bool {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            if realm.objects(PrepaidCard.self).filter("state = %@", PrepaidCardState.active.rawValue).first != nil {
                return true
            }
            return false
        } catch {
            return false
        }
    }

    func showBadgeIconToItem(item: Int) {
        tabBar.items?[item].badgeValue = "!"
    }
    
    func hideBadgeIconToItem(item: Int) {
        tabBar.items?[item].badgeValue = nil
    }
    
    func dismissAuthenticationProcess() {
        self.dismiss(animated: true, completion: nil)
    }
}

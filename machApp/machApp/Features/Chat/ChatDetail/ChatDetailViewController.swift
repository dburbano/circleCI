//
//  ChatDetailViewController.swift
//  machApp
//
//  Created by lukas burns on 4/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class ChatDetailViewController: BaseViewController {

    // MARK: - Constants
    let showSelectAmount: String = "showSelectAmount"
    let showSelectInteraction: String = "showSelectInteractions"
    let showReminderInformation: String = "showReminderInformation"

    let paymentReceivedCellIdentifier: String = "PaymentReceivedCell"
    let paymentSentCellIdentifier: String = "PaymentSentCell"
    let requestReceivedCellIdentifier: String = "RequestReceivedCell"
    let requestSentCellIdentifier: String = "RequestSentCell"
    let machMessageReceivedCellIdentifier: String = "MachMessageReceivedCell"
    let headerCell: String = "SectionHeader"
    let showConfirmationDialogue: String = "showConfirmationDialogue"
    let unwindPay: String = "unwindPay"
    let unwindCancel: String = "unwindCancel"

    var loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    // MARK: - Variables
    var presenter: ChatDetailPresenterProtocol?
    var groupViewModel: GroupViewModel? {
        didSet {
            // This method's purpose is to update the content of this view. It is used in class Navigator, so please DO NOT ERASE IT. 
            if oldValue != nil {
                presenter?.setGroupViewModel(groupViewModel)
                setTitle()
            }
        }
    }
    var indexPathCardSelected: IndexPath?

    // MARK: - Outlets
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var footerChargeButton: UIButton!
    @IBOutlet weak var footerPayButton: UIButton!
    @IBOutlet weak var footerSeparatorView: UIView!
    
    var locationPermissionView: PermissionView?

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.presenter?.setGroupViewModel(groupViewModel)
        // We apply this rotation to the table view so elements are populated from bottom to top.
        setupView()
        presenter?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.topContainerView.setMachGradient(includesStatusBar: true, navigationBar: nil, withRoundedBottomCorners: true, withShadow: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    func setupView() {
        setupTableView()
        setTitle()
    }

    func setupTableView() {
        transactionsTableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        transactionsTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        transactionsTableView.register(UINib(nibName: "PaymentReceivedTableViewCell", bundle: nil), forCellReuseIdentifier: paymentReceivedCellIdentifier)
        transactionsTableView.register(UINib(nibName: "PaymentSentTableViewCell", bundle: nil), forCellReuseIdentifier: paymentSentCellIdentifier)
        transactionsTableView.register(UINib(nibName: "RequestReceivedTableViewCell", bundle: nil), forCellReuseIdentifier: requestReceivedCellIdentifier)
        transactionsTableView.register(UINib(nibName: "RequestSentTableViewCell", bundle: nil), forCellReuseIdentifier: requestSentCellIdentifier)
        transactionsTableView.register(UINib(nibName: "MachMessageReceivedTableViewCell", bundle: nil), forCellReuseIdentifier: machMessageReceivedCellIdentifier)
        transactionsTableView.register(UINib(nibName: "CenteredTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: headerCell)

        transactionsTableView.rowHeight = UITableViewAutomaticDimension
        transactionsTableView.estimatedRowHeight = 300
        self.transactionsTableView.tableFooterView = loadingIndicator
        loadingIndicator.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: transactionsTableView.bounds.width, height: CGFloat(44))
    }

    func setTitle() {
        self.userNameLabel.text = self.presenter?.getGroupName()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter?.markChatMessagesAsSeen()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSelectAmount, let destinationViewController = (segue.destination as? UINavigationController)?.viewControllers[0] as? SelectAmountViewController, let transactionMode = sender as? TransactionMode {
            destinationViewController.transactionMode = transactionMode
            destinationViewController.userAmountViewModels = self.presenter?.getUserAmountViewModels()
        } else if segue.identifier == showSelectInteraction, let destinationViewController = segue.destination as? InteractionViewController,
            let indexPath = sender as? IndexPath, let transactionViewModel = self.presenter?.getChatMessage(indexPath: indexPath)?.chatMessageViewModel as? TransactionViewModel {
            destinationViewController.transactionIndexPathInChat = indexPath
            destinationViewController.interactionSelectedDelegate = self
            switch transactionViewModel.getTransactionType() {
            case .paymentReceived:
                destinationViewController.interactionType = InteractionType.paymentReactionInteraction
            case .requestReceived:
                destinationViewController.interactionType = InteractionType.requestRejectionInteraction
            case .requestSent:
                switch transactionViewModel.getTransactionStatus() {
                case .completed:
                    destinationViewController.interactionType = InteractionType.paymentReactionInteraction
                case .pending:
                    destinationViewController.interactionType = InteractionType.requestReminderInteraction
                default:
                    break
                }
            default:
                destinationViewController.interactionType = nil
            }
        } else if segue.identifier == showConfirmationDialogue,
            let destinationViewController = segue.destination as? UnknownContactViewController,
            let data = sender as? String {
            destinationViewController.phoneNumber = data
        }
    }

    // MARK: - Actions
    @IBAction func unwindToChatDetail(segue: UIStoryboardSegue) {
        if segue.identifier == unwindPay {
            if let indexPath = self.indexPathCardSelected {
                self.presenter?.acceptRequest(indexPath: indexPath)
            }
        }
    }
    @IBAction func newRequestPressed(_ sender: Any) {
        self.presenter?.createNewRequest()
    }
    
    @IBAction func newPaymentPressed(_ sender: Any) {
        self.presenter?.createNewPayment()
    }

    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        _ = UnwindScaleSegue(identifier: unwindSegue.identifier, source: unwindSegue.source, destination: unwindSegue.destination)
    }

}

extension ChatDetailViewController: ChatDetailViewProtocol {

    internal func updateChatMessages(scrollToBottom: Bool) {
        transactionsTableView.reloadData()
        DispatchQueue.main.async(execute: { [weak self] in
            if scrollToBottom {
                self?.presenter?.scrollToLastChatMessage(animated: true)
            }
        })
    }

    internal func scrollToChatMessage(at indexPath: IndexPath, animated: Bool) {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.transactionsTableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        })
    }

    internal func updateChatMessageAt(indexPath: IndexPath) {
        self.transactionsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }

    internal func showRejectionConfirmationAlert(groupName: String, amount: Int, onAccepted: @escaping() -> Void, onCancelled: @escaping() -> Void) {
        self.showAlert(title: "Confirmación", message: "Deseas rechazar el cobro de \(groupName) por \(amount.toCurrency())", onAccepted: onAccepted, onCancelled: onCancelled)
    }

    internal func showCancelationConfirmationAlert(groupName: String, amount: Int, onAccepted: @escaping() -> Void, onCancelled: @escaping() -> Void) {
        self.showAlert(title: "Confirmación", message: "Deseas descartar el cobro a \(groupName) por \(amount.toCurrency())", onAccepted: onAccepted, onCancelled: onCancelled)
    }

    internal func presentPasscode(title: String, onSuccess: @escaping () -> Void) {
        guard let passcodeViewController = UIStoryboard(name: "Passcode", bundle: nil).instantiateViewController(withIdentifier: "PasscodeViewController") as? PasscodeViewController else { return }
        passcodeViewController.successCallback = onSuccess
        passcodeViewController.setPasscode(passcodeMode: .transactionMode, title: title, optionText: "Cancelar")
        self.presentVC(passcodeViewController)
    }

    internal func navigateToNewTransaction(transactionMode: TransactionMode) {
        self.performSegue(withIdentifier: showSelectAmount, sender: transactionMode)
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    internal func showActivityIndicator() {
        loadingIndicator.startAnimating()
        self.transactionsTableView.tableFooterView?.isHidden = false
    }

    internal func hideActivityIndicator() {
        loadingIndicator.stopAnimating()
        self.transactionsTableView.tableFooterView?.isHidden = true
    }

    internal func blockActionsForTransactionReceived(at indexPath: IndexPath) {
        let transaction = self.transactionsTableView.cellForRow(at: indexPath) as? RequestReceivedTableViewCell
        transaction?.blockActions()

    }

    internal func unblockActionsForTransactionReceived(at indexPath: IndexPath) {
        let transaction = self.transactionsTableView.cellForRow(at: indexPath) as? RequestReceivedTableViewCell
        transaction?.unblockActions()
    }

    internal func blockActionsForTransactionSent(at indexPath: IndexPath) {
        let transaction = self.transactionsTableView.cellForRow(at: indexPath) as? RequestSentTableViewCell
        transaction?.blockActions()
    }

    internal func unblockActionsForTransactionSent(at indexPath: IndexPath) {
        let transaction = self.transactionsTableView.cellForRow(at: indexPath) as? RequestSentTableViewCell
        transaction?.unblockActions()
    }

    internal func hideMoreOptions() {
        footerChargeButton.isHidden = true
        footerPayButton.isHidden = true
        footerSeparatorView.isHidden = true
    }

    internal func showInsufficientBalanceError() {
        self.showErrorMessage(title: "Error", message: "Saldo insuficiente", completion: nil)
    }

    internal func showReminderInformationView() {
        self.performSegue(withIdentifier: self.showReminderInformation, sender: self)
    }

    func showTooManyReminderAttemptsError(maximumReminders: Int) {
        self.showToastWithText(text: "Ya enviaste el máximo de \(maximumReminders) recordatorios")
    }

    func showTooFrequentReminderErrror(remindersUsed: Int, maximumReminders: Int) {
        self.showToastWithText(text: "Aún no pasan 24 hrs. para usar el siguiente recordatorio ⏰")
    }

    func showSelectInteractionView(for indexPath: IndexPath) {
       self.performSegue(withIdentifier: self.showSelectInteraction, sender: indexPath)
    }

    func showGenericError(with message: String) {
        super.showToastWithText(text: message)
    }

    func showBlockedAction(with text: String) {
        let vc = SmyteBlockedActionViewController()
        vc.message = text
        presentVC(vc)
    }
}

extension ChatDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            self.presenter?.userScrolledToTopOfChat()
        }
    }

    // In this function we transform each cell upside down because of table rotation.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let chatMessageTuple = self.presenter?.getChatMessage(indexPath: indexPath) {
            if let transactionViewModel = chatMessageTuple.chatMessageViewModel as? TransactionViewModel {
                switch transactionViewModel.getTransactionType() {
                case .paymentSent:
                    //swiftlint:disable:next force_cast
                    let cell = tableView.dequeueReusableCell(withIdentifier: paymentSentCellIdentifier, for: indexPath) as! PaymentSentTableViewCell
                    cell.setupCellWith(transactionViewModel: transactionViewModel)
                    transformCell(cell)
                    return cell
                case .paymentReceived:
                    //swiftlint:disable:next force_cast
                    let cell = tableView.dequeueReusableCell(withIdentifier: paymentReceivedCellIdentifier, for: indexPath) as! PaymentReceivedTableViewCell
                    cell.setupCellWith(transactionViewModel: transactionViewModel)
                    cell.interactionDelegate = self
                    transformCell(cell)
                    return cell
                case .requestReceived:
                    //swiftlint:disable:next force_cast
                    let cell = tableView.dequeueReusableCell(withIdentifier: requestReceivedCellIdentifier, for: indexPath) as! RequestReceivedTableViewCell
                    cell.setupCellWith(transactionViewModel: transactionViewModel)
                    cell.delegate = self
                    transformCell(cell)
                    return cell
                case .requestSent:
                    //swiftlint:disable:next force_cast
                    let cell = tableView.dequeueReusableCell(withIdentifier: requestSentCellIdentifier, for: indexPath) as! RequestSentTableViewCell
                    cell.setupCellWith(transactionViewModel: transactionViewModel, tooltipFlag: chatMessageTuple.tooltipFlag)
                    cell.delegate = self
                    cell.openInteractionsDelegate = self
                    transformCell(cell)
                    return cell
                default:
                    break
                }
            } else if let machMessageViewModel = chatMessageTuple.chatMessageViewModel as? MachMessageViewModel {
                //swiftlint:disable:next force_cast
                let cell = tableView.dequeueReusableCell(withIdentifier: machMessageReceivedCellIdentifier, for: indexPath) as! MachMessageReceivedTableViewCell
                cell.setupCellWith(machMessageViewModel: machMessageViewModel)
                transformCell(cell)
                return cell
            }
        }
        return UITableViewCell()
    }

    private func transformCell(_ cell: UITableViewCell) {
        cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter?.getNumberOfChatMessagesForSection(section) ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.presenter?.getNumberOfSections() ?? 0
    }

}

extension ChatDetailViewController: UITableViewDelegate {

    // We us a footer instead of a header for the sections because table is rotated upside down
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let title = self.presenter?.getTitleForChatMessageSection(section)
        let cell = self.transactionsTableView.dequeueReusableHeaderFooterView(withIdentifier: headerCell)
        // swiftlint:disable:next force_cast
        let header = cell as! CenteredTableSectionHeader
        header.titleLabel.text = title
        // we transform this header upside down because of the table transformation.
        cell?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        cell?.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
}

extension ChatDetailViewController: RequestReceivedDelegate {

    func requestAccepted(cell: RequestReceivedTableViewCell) {
        guard let indexPath = self.transactionsTableView.indexPath(for: cell) else { return }
        guard let groupViewModel = groupViewModel else { return }
        if groupViewModel.isInContacts() {
            self.presenter?.acceptRequest(indexPath: indexPath)
        } else {
            self.indexPathCardSelected = indexPath
            performSegue(
                withIdentifier: self.showConfirmationDialogue,
                sender: self.groupViewModel?.users.first?.firstNameToShow
            )

        }
    }

    func requestRejected(cell: RequestReceivedTableViewCell) {
        guard let indexPath = self.transactionsTableView.indexPath(for: cell) else { return }
        self.performSegue(withIdentifier: self.showSelectInteraction, sender: indexPath)
    }
}

extension ChatDetailViewController: RequestSentDelegate {

    func requestCanceled(cell: RequestSentTableViewCell) {
        guard let indexPath = self.transactionsTableView.indexPath(for: cell) else { return }
        self.presenter?.cancelRequest(indexPath: indexPath)
    }
}

extension ChatDetailViewController: OpenInteractionsDelegate {
    func reactTo(cell: PaymentReceivedTableViewCell) {
        guard let indexPath = self.transactionsTableView.indexPath(for: cell) else { return }
        self.performSegue(withIdentifier: self.showSelectInteraction, sender: indexPath)
    }

    func remindTo(cell: RequestSentTableViewCell) {
       guard let indexPath = self.transactionsTableView.indexPath(for: cell) else { return }
       self.presenter?.remindButtonSelected(at: indexPath)
    }

    func reactTo(requestCell: RequestSentTableViewCell) {
        guard let indexPath = self.transactionsTableView.indexPath(for: requestCell) else { return }
        self.performSegue(withIdentifier: self.showSelectInteraction, sender: indexPath)
    }
}

extension ChatDetailViewController: InteractionSelectedDelegate {

    func reminderSelected(interactionViewModel: InteractionViewModel, transactionIndexPath: IndexPath?) {
        guard let transactionIndexPath = transactionIndexPath else { return }
        self.presenter?.remindRequest(indexPath: transactionIndexPath, interactionViewModel: interactionViewModel)
    }

    func rejectionSelected(interactionViewModel: InteractionViewModel, transactionIndexPath: IndexPath?) {
        guard let transactionIndexPath = transactionIndexPath else { return }
        self.presenter?.rejectRequest(indexPath: transactionIndexPath, interactionViewModel: interactionViewModel)
    }

    func reactionSelected(interactionViewModel: InteractionViewModel, transactionIndexPath: IndexPath?) {
        guard let transactionIndexPath = transactionIndexPath else { return }
        self.presenter?.reactToTransaction(indexPath: transactionIndexPath, interactionViewModel: interactionViewModel)
    }
}

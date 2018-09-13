//
//  Injections.swift
//  machApp
//
//  Created by lukas burns on 3/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

// swiftlint:disable function_body_length

import Foundation
import Swinject
import SwinjectStoryboard

extension SwinjectStoryboard {

    class func setup() {
        defaultContainer.register(APIServiceProtocol.self) { _ in AlamofireNetworkLayer.sharedInstance }.inObjectScope(.container)

        // MARK: TabBar
        defaultContainer.register(TabBarRepositoryProtocol.self) { resource in
            TabBarRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: TabErrorParser())
        }

        defaultContainer.register(TabBarPresenterProtocol.self) {resource in
            TabBarPresenter(repository: resource.resolve(TabBarRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(TabBarViewController.self) { resource, controller in
            controller.presenter = resource.resolve(TabBarPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Register Device

        defaultContainer.register(RegisterDeviceRepositoryProtocol.self) {resource in
            RegisterDeviceRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: RegisterDeviceErrorParser())
        }

        defaultContainer.register(RegisterDevicePresenterProtocol.self) {resource in
            RegisterDevicePresenter(repository:resource.resolve(RegisterDeviceRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(RegisterDeviceViewController.self) { resource, controller in
            controller.presenter = resource.resolve(RegisterDevicePresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Verify User

        defaultContainer.register(VerifyUserRepositoryProtocol.self) {resource in
            VerifyUserRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: VerifyUserErrorParser())
        }

        defaultContainer.register(VerifyUserPresenterProtocol.self) {resource in
            VerifyUserPresenter(repository:resource.resolve(VerifyUserRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(VerifyUserViewController.self) { resource, controller in
            controller.presenter = resource.resolve(VerifyUserPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Register PhoneNumber

        defaultContainer.register(RegisterPhoneNumberRepositoryProcotol.self) {resource in
            RegisterPhoneNumberRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: RegisterPhoneNumberErrorParser())
        }

        defaultContainer.register(RegisterPhoneNumberPresenterProtocol.self) {resource in
            RegisterPhoneNumberPresenter(repository:resource.resolve(RegisterPhoneNumberRepositoryProcotol.self))
        }

        defaultContainer.storyboardInitCompleted(RegisterPhoneNumberViewController.self) { resource, controller in
            controller.presenter = resource.resolve(RegisterPhoneNumberPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Validate PhoneNumber

        defaultContainer.register(ValidatePhoneNumberRepositoryProtocol.self) {resource in
            ValidatePhoneNumberRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: ValidatePhoneNumberErrorParser())
        }

        defaultContainer.register(ValidatePhoneNumberPresenterProtocol.self) {resource in
            ValidatePhoneNumberPresenter(repository:resource.resolve(ValidatePhoneNumberRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(ValidatePhoneNumberViewController.self) { resource, controller in
            controller.presenter = resource.resolve(ValidatePhoneNumberPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: GeneratePinNumber

        defaultContainer.register(GeneratePINNumberRepositoryProtocol.self) {resource in
            GeneratePINNumberRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: GeneratePinNumberErrorParser())
        }

        defaultContainer.register(GeneratePINNUmberPresenterProtocol.self) {resource in
            GeneratePINNumberPresenter(repository:resource.resolve(GeneratePINNumberRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(GeneratePINNumberViewController.self) { resource, controller in
            controller.presenter = resource.resolve(GeneratePINNUmberPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Photo

        defaultContainer.register(PhotoRepositoryProtocol.self) {resource in
            PhotoRepository(apiService:resource.resolve(APIServiceProtocol.self))
        }

        defaultContainer.register(PhotoPresenterProtocol.self) {resource in
            PhotoPresenter(repository:resource.resolve(PhotoRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(PhotoViewController.self) { resource, controller in
            controller.presenter = resource.resolve(PhotoPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Home

        defaultContainer.register(HomeRepositoryProtocol.self) {resource in
            HomeRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: HomeErrorParser())
        }

        defaultContainer.register(HomePresenterProtocol.self) {resource in
            HomePresenter(repository:resource.resolve(HomeRepositoryProtocol.self), permissionManager: PermissionManager.sharedInstance)
        }

        defaultContainer.storyboardInitCompleted(HomeViewController.self) {resource, controller in
            controller.presenter = resource.resolve(HomePresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }
        
        // MARK: Generate Prepaid Card

        defaultContainer.register(GeneratePrepaidCardRepositoryProtocol.self) {resource in
            GeneratePrepaidCardRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: GeneratePrepaidCardErrorParser())
        }

        defaultContainer.register(GeneratePrepaidCardPresenterProtocol.self) {resource in
            GeneratePrepaidCardPresenter(repository: resource.resolve(GeneratePrepaidCardRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(GeneratePrepaidCardViewController.self) { resource, controller in
            controller.presenter = resource.resolve(GeneratePrepaidCardPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Prepaid Card
        
        defaultContainer.register(PrepaidCardRepositoryProtocol.self) {resource in
            PrepaidCardRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: PrepaidCardErrorParser())
        }
        
        defaultContainer.register(PrepaidCardPresenterProtocol.self) {resource in
            PrepaidCardPresenter(repository: resource.resolve(PrepaidCardRepositoryProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(PrepaidCardViewController.self) { resource, controller in
            controller.presenter = resource.resolve(PrepaidCardPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }
        
        // MARK: PrepaidCardInformation
        
        defaultContainer.register(PrepaidCardInformationRepositoryProtocol.self) {resource in
            PrepaidCardInformationRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: PrepaidCardInformationErrorParser())
        }
        
        defaultContainer.register(PrepaidCardInformationPresenterProtocol.self) {resource in
            PrepaidCardInformationPresenter(repository: resource.resolve(PrepaidCardInformationRepositoryProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(PrepaidCardInformationViewController.self) { resource, controller in
            controller.presenter = resource.resolve(PrepaidCardInformationPresenterProtocol.self)
            controller.presenter?.set(view: controller)
        }

        // MARK: Prepaid Card Menu Table

        defaultContainer.register(PrepaidCardMenuTablePresenterProtocol.self) {resource in
            PrepaidCardMenuTablePresenter()
        }

        defaultContainer.storyboardInitCompleted(PrepaidCardMenuTableViewController.self) { resource, controller in
            controller.presenter = resource.resolve(PrepaidCardMenuTablePresenterProtocol.self)
            controller.presenter?.set(view: controller)
        }

        // MARK: Select Users

        defaultContainer.register(SelectUsersRepositoryProtocol.self) {resource in
            SelectUsersRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: SelectUsersErrorParser())
        }

        defaultContainer.register(SelectUsersPresenterProtocol.self) {resource in
            SelectUsersPresenter(repository:resource.resolve(SelectUsersRepositoryProtocol.self), permissionManager: PermissionManager.sharedInstance)
        }

        defaultContainer.storyboardInitCompleted(SelectUsersViewController.self) { resource, controller in
            controller.presenter = resource.resolve(SelectUsersPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: SelectAmount

        defaultContainer.register(SelectAmountRepositoryProtocol.self) {resource in
            SelectAmountRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: SelectAmountErrorParser())
        }

        defaultContainer.register(SelectAmountPresenterProtocol.self) {resource in
            SelectAmountPresenter(repository:resource.resolve(SelectAmountRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(SelectAmountViewController.self) { resource, controller in
            controller.presenter = resource.resolve(SelectAmountPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Execute Transaction

        defaultContainer.register(ExecuteTransactionRepositoryProtocol.self) {resource in
            ExecuteTransactionRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: ExecuteTransactionErrorParser())
        }

        defaultContainer.register(ExecuteTransactionPresenterProtocol.self) {resource in
            ExecuteTransactionPresenter(repository:resource.resolve(ExecuteTransactionRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(ExecuteTransactionViewController.self) { resource, controller in
            controller.presenter = resource.resolve(ExecuteTransactionPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Execute Request Transaction

        defaultContainer.register(ExecuteRequestTransactionRepositoryProtocol.self) {resource in
            ExecuteRequestTransactionRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: ExecuteTransactionErrorParser())
        }

        defaultContainer.register(ExecuteRequestTransactionPresenterProtocol.self) {resource in
            ExecuteRequestTransactionPresenter(repository:resource.resolve(ExecuteRequestTransactionRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(ExecuteRequestTransactionViewController.self) { resource, controller in
            controller.presenter = resource.resolve(ExecuteRequestTransactionPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Cash In
        defaultContainer.register(CashInRepositoryProtocol.self) {resource in
            CashInRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: CashInErrorParser())
        }

        defaultContainer.register(CashInPresenterProtocol.self) {resource in
            CashInPresenter(repository: resource.resolve(CashInRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(CashInViewController.self) { resource, controller in
            controller.presenter = resource.resolve(CashInPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        defaultContainer.register(CashInDetailRepositoryProtocol.self) {resource in
            CashInDetailRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: CashInErrorParser())
        }

        defaultContainer.register(CashInDetailPresenterProtocol.self) {resource in
            CashInDetailPresenter(repository:resource.resolve(CashInDetailRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(CashInDetailViewController.self) { resource, controller in
            controller.presenter = resource.resolve(CashInDetailPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: ChatDetail

        defaultContainer.register(ChatDetailRepositoryProtocol.self) {resource in
            ChatDetailRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: ChatDetailErrorParser())
        }

        defaultContainer.register(ChatDetailPresenterProtocol.self) {resource in
            ChatDetailPresenter(repository:resource.resolve(ChatDetailRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(ChatDetailViewController.self) { resource, controller in
            controller.presenter = resource.resolve(ChatDetailPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Add Credit Card
        defaultContainer.register(AddCreditCardRepositoryProtocol.self) {resource in
            AddCreditCardRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: AddCreditCardErrorParser())
        }

        defaultContainer.register(AddCreditCardPresenterProtocol.self) {resource in
            AddCreditCardPresenter(repository:resource.resolve(AddCreditCardRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(AddCreditCardViewController.self) { resource, controller in
            controller.presenter = resource.resolve(AddCreditCardPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Web View
        defaultContainer.register(WebRepositoryProtocol.self) {resource in
            WebViewRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: WebErrorParser())
        }

        defaultContainer.register(WebPresenterProtocol.self) {resource in
            WebViewPresenter(repository:resource.resolve(WebRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(WebViewController.self) { resource, controller in
            controller.presenter = resource.resolve(WebPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Recharge
        defaultContainer.register(RechargeRepositoryProtocol.self) {resource in
            RechargeRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: RechargeErrorParser())
        }

        defaultContainer.register(RechargePresenterProtocol.self) {resource in
            RechargePresenter(repository:resource.resolve(RechargeRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(RechargeViewController.self) { resource, controller in
            controller.presenter = resource.resolve(RechargePresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Execute Recharge
        defaultContainer.register(ExecuteRechargeRepositoryProtocol.self) {resource in
            ExecuteRechargeRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: ExecuteRechargeErrorParser())
        }

        defaultContainer.register(ExecuteRechargePresenterProtocol.self) {resource in
            ExecuteRechargePresenter(repository:resource.resolve(ExecuteRechargeRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(ExecuteRechargeViewController.self) { resource, controller in
            controller.presenter = resource.resolve(ExecuteRechargePresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Name

        defaultContainer.register(NameRepositoryProtocol.self) {resource in
            NameRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser : RegisterProfileErrorParser())
        }

        defaultContainer.register(NamePresenterProtocol.self) {resource in
            NamePresenter(repository:resource.resolve(NameRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(NameViewController.self) { resource, controller in
            controller.presenter = resource.resolve(NamePresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: AnswerSecurityQuestions

        defaultContainer.register(AnswerSecurityQuestionsRepositoryProtocol.self) {resource in
            AnswerSecurityQuestionsRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: AnswerSecurityQuestionsErrorParser())
        }

        defaultContainer.register(AnswerSecurityQuestionsPresenterProtocol.self) {resource in
            AnswerSecurityQuestionsPresenter(repository:resource.resolve(AnswerSecurityQuestionsRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(AnswerSecurityQuestionsPageViewController.self) { resource, controller in
            controller.presenter = resource.resolve(AnswerSecurityQuestionsPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: StartSecurityQuesitons

        defaultContainer.register(StartSecurityQuestionsRepositoryProtocol.self) {resource in
            StartSecurityQuestionsRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: StartSecurityQuestionsErrorParser())
        }

        defaultContainer.register(StartSecurityQuestionsPresenterProtocol.self) {resource in
            StartSecurityQuestionsPresenter(repository:resource.resolve(StartSecurityQuestionsRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(StartSecurityQuestionsViewController.self) { resource, controller in
            controller.presenter = resource.resolve(StartSecurityQuestionsPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Identity Recovery Result

        defaultContainer.register(IdentityRecoveryResultRepositoryProtocol.self) {resource in
            IdentityRecoveryResultRepository(apiService:resource.resolve(APIServiceProtocol.self))
        }

        defaultContainer.register(IdentityRecoveryResultPresenterProtocol.self) {resource in
            IdentityRecoveryResultPresenter(repository:resource.resolve(IdentityRecoveryResultRepositoryProtocol.self))
        }
        

        //MARK: Email challenge
        defaultContainer.register(EmailChallengeRepositoryProtocol.self) {resource in
            EmailChallengeRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: EmailChallengerErrorParser())
        }
        
        
        defaultContainer.register(EmailChallengePresenterProtocol.self) { resource in
            EmailChallengePresenter(repository:resource.resolve(EmailChallengeRepositoryProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(EmailChallengeViewController.self) { resource, controller in
            controller.presenter = resource.resolve(EmailChallengePresenterProtocol.self)
            controller.presenter?.view = controller
        }

        defaultContainer.storyboardInitCompleted(IdentityRecoveryResultViewController.self) { resource, controller in
            controller.presenter = resource.resolve(IdentityRecoveryResultPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: More

        defaultContainer.register(MoreRepositoryProtocol.self) {resource in
            MoreRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: MoreErrorParser())
        }

        defaultContainer.register(MorePresenterProtocol.self) {resource in
            MorePresenter(repository:resource.resolve(MoreRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(MoreViewController.self) { resource, controller in
            controller.presenter = resource.resolve(MorePresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: More Table

        defaultContainer.register(MoreTableRepositoryProtocol.self) {resource in
            MoreTableRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: MoreTableErrorParser())
        }

        defaultContainer.register(MoreTablePresenterProtocol.self) { resource in
            MoreTablePresenter(repository: resource.resolve(MoreTableRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(MoreTableViewController.self) { r, c in
            c.presenter = r.resolve(MoreTablePresenterProtocol.self)!
            c.presenter.view = c
        }
        
        // MARK: Withdraw
        
        defaultContainer.register(WithdrawRepositoryProtocol.self) {resource in
            WithdrawRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: WithdrawErrorParser())
        }
        
        defaultContainer.register(WithdrawPresenterProtocol.self) {resource in
            WithdrawPresenter(repository: resource.resolve(WithdrawRepositoryProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(WithdrawViewController.self) { resource, controller in
            controller.presenter = resource.resolve(WithdrawPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: WithdrawTEF

        defaultContainer.register(WithdrawTEFRepositoryProtocol.self) {resource in
            WithdrawTEFRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: WithdrawTEFErrorParser())
        }

        defaultContainer.register(WithdrawTEFPresenterProtocol.self) {resource in
            WithdrawTEFPresenter(repository:resource.resolve(WithdrawTEFRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(WithdrawTEFViewController.self) { resource, controller in
            controller.presenter = resource.resolve(WithdrawTEFPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }
        
        // MARK: WithdrawATM
        
        defaultContainer.register(WithdrawATMRepositoryProtocol.self) {resource in
            WithdrawATMRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: WithdrawATMErrorParser())
        }
        
        defaultContainer.register(WithdrawATMPresenterProtocol.self) {resource in
            WithdrawATMPresenter(repository:resource.resolve(WithdrawATMRepositoryProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(WithdrawATMViewController.self) { resource, controller in
            controller.presenter = resource.resolve(WithdrawATMPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }
        
        // MARK: Withdraw saved account
        
        defaultContainer.register(WithdrawTEFSavedAccountRepositoryProtocol.self) {resource in
            WithdrawTEFSavedAccountRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: WithdrawTEFSavedAccountErrorParser())
        }
        
        defaultContainer.register(WithdrawTEFSavedAccountPresenterProtocol.self) {resource in
            WithdrawTEFSavedAccountPresenter(repository: resource.resolve(WithdrawTEFSavedAccountRepositoryProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(WithdrawTEFSavedAccountViewController.self) { resource, controller in
            controller.presenter = resource.resolve(WithdrawTEFSavedAccountPresenterProtocol.self)
            controller.presenter?.view = controller
        }
        
        // MARK: WithdrawATMDetail
        
        defaultContainer.register(WithdrawATMDetailRepositoryProtocol.self) {resource in
            WithdrawATMDetailRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: WithdrawATMDetailErrorParser())
        }
        
        defaultContainer.register(WithdrawATMDetailPresenterProtocol.self) {resource in
            WithdrawATMDetailPresenter(repository: resource.resolve(WithdrawATMDetailRepositoryProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(WithdrawATMDetailViewController.self) { resource, controller in
            controller.presenter = resource.resolve(WithdrawATMDetailPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Withdraw Remove Cashout Confirm

        defaultContainer.register(WithdrawRemoveCashoutConfirmRepositoryProtocol.self) {resource in
            WithdrawRemoveCashoutConfirmRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: WithdrawRemoveChasoutConfirmErrorParser())
        }

        defaultContainer.register(WithdrawRemoveCashoutConfirmPresenterProtocol.self) {resource in
            WithdrawRemoveCashoutConfirmPresenter(repository:resource.resolve(WithdrawRemoveCashoutConfirmRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(WithdrawRemoveCashoutConfirmViewController.self) { resource, controller in
            controller.presenter = resource.resolve(WithdrawRemoveCashoutConfirmPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Taxes

        defaultContainer.register(TaxesRepositoryProtocol.self) {resource in
            TaxesRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: VerifyUserErrorParser())
        }

        defaultContainer.register(TaxesPresenterProtocol.self) {resource in
            TaxesPresenter(repository: resource.resolve(TaxesRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(TaxesViewController.self) { resource, controller in
            controller.presenter = resource.resolve(TaxesPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Add Taxable Country

        defaultContainer.register(AddTaxableCountryRepositoryProtocol.self) {_ in
            AddTaxableCountryRepository()
        }

        defaultContainer.register(AddTaxableCountryPresenterProtocol.self) {resource in
            AddTaxableCountryPresenter(repository:resource.resolve(AddTaxableCountryRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(AddTaxableCountryViewController.self) { resource, controller in
            controller.presenter = resource.resolve(AddTaxableCountryPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Accept Terms and Conditions

        defaultContainer.register(AcceptTermsAndConditionsRepositoryProtocol.self) {resource in
            AcceptTermsAndConditionsRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: AcceptTermsAndConditionsErrorParser())
        }

        defaultContainer.register(AcceptTermsAndConditionsPresenterProtocol.self) { resource in
            AcceptTermsAndConditionsPresenter(repository: resource.resolve(AcceptTermsAndConditionsRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(AcceptTermsAndConditionsViewController.self) { resource, controller in
            controller.presenter = resource.resolve(AcceptTermsAndConditionsPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Terms And Conditions Details

        defaultContainer.register(TermsAndConditionsDetailsRepositoryProtocol.self) {resource in
            TermsAndConditionsDetailsRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: TermsAndConditionsDetailsErrorParser() )
        }

        defaultContainer.register(TermsAndConditionsDetailsPresenterProtocol.self) {resource in
            TermsAndConditionsDetailsPresenter(repository:resource.resolve(TermsAndConditionsDetailsRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(TermsAndConditionsDetailsViewController.self) { resource, controller in
            controller.presenter = resource.resolve(TermsAndConditionsDetailsPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Legal

        defaultContainer.register(LegalRepositoryProtocol.self) {resource in
            LegalRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: LegalErrorParser())
        }

        defaultContainer.register(LegalPresenterProtocol.self) {resource in
            LegalPresenter(repository:resource.resolve(LegalRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(LegalViewController.self) { resource, controller in
            controller.presenter = resource.resolve(LegalPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Profile

        defaultContainer.register(ProfileRepositoryProtocol.self) {resource in
            ProfileRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: ProfileErrorParser())
        }

        defaultContainer.register(ProfilePresenterProtocol.self) {resource in
            ProfilePresenter(repository:resource.resolve(ProfileRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(ProfileController.self) { resource, controller in
            controller.presenter = resource.resolve(ProfilePresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: Reactions

        defaultContainer.register(InteractionRepositoryProtocol.self) {resource in
            InteractionRepository(apiService:resource.resolve(APIServiceProtocol.self), errorParser: InteractionErrorParser())
        }

        defaultContainer.register(InteractionPresenterProtocol.self) {resource in
            InteractionPresenter(repository:resource.resolve(InteractionRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(InteractionViewController.self) { resource, controller in
            controller.presenter = resource.resolve(InteractionPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: History

        defaultContainer.register(HistoryRepositoryProtocol.self) {resource in
            HistoryRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: ErrorParser())
        }

        defaultContainer.register(HistoryPresenterProtocol.self) {resource in
            HistoryPresenter(repository: resource.resolve(HistoryRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(HistoryViewController.self) { resource, controller in
            controller.presenter = resource.resolve(HistoryPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: History months

        defaultContainer.register(HistoryMonthsRepositoryProtocol.self) {resource in
            HistoryMonthsRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: ErrorParser())
        }

        defaultContainer.register(HistoryMonthsPresenterProtocol.self) {resource in
            HistoryMonthsPresenter(repository: resource.resolve(HistoryMonthsRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(HistoryMonthsViewController.self) { resource, controller in
            controller.presenter = resource.resolve(HistoryMonthsPresenterProtocol.self)
            controller.presenter?.set(view: controller)
        }

        // Transactions history

        defaultContainer.register(TransactionsHistoryRepositoryProtocol.self) {resource in
            TransactionsHistoryRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: ErrorParser())
        }

        defaultContainer.register(TransactionsHistoryPresenterProtocol.self) {resource in
            TransactionsHistoryPresenter(repository: resource.resolve(TransactionsHistoryRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(TransactionsHistoryViewController.self) { resource, controller in
            controller.presenter = resource.resolve(TransactionsHistoryPresenterProtocol.self)
            controller.presenter?.set(view: controller)
        }

        // MARK: Passcode

        defaultContainer.register(PasscodeRepositoryProcotol.self) {resource in
            PasscodeRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: PasscodeErrorParser())
        }

        defaultContainer.register(PasscodePresenterProtocol.self) {resource in
            PasscodePresenter(repository: resource.resolve(PasscodeRepositoryProcotol.self))
        }

        defaultContainer.storyboardInitCompleted(PasscodeViewController.self) {resource, controller in
            controller.presenter = resource.resolve(PasscodePresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }
        
        // MARK: TEF Validation Instruction

        defaultContainer.register(TEFValidationInstructionRepositoryProtocol.self) {resource in
            TEFValidationInstructionRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: TEFValidationInstructionErrorParser())
        }

        defaultContainer.register(TEFValidationInstructionPresenterProtocol.self) {resource in
            TEFValidationInstructionPresenter(repository: resource.resolve(TEFValidationInstructionRepositoryProtocol.self))
        }
    
        defaultContainer.storyboardInitCompleted(TEFValidationInstructionViewController.self) { resource, controller in
            controller.presenter = resource.resolve(TEFValidationInstructionPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: TEF Validation Deposit
        
        defaultContainer.register(TEFValidationDepositRepositoryProtocol.self) {resource in
            TEFValidationDepositRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: TEFValidationDepositErrorParser())
        }
        
        defaultContainer.register(TEFValidationDepositPresenterProtocol.self) {resource in
            TEFValidationDepositPresenter(repository: resource.resolve(TEFValidationDepositRepositoryProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(TEFValidationDepositViewController.self) { resource, controller in
            controller.presenter = resource.resolve(TEFValidationDepositPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }

        // MARK: TEF Validation Amount

        defaultContainer.register(TEFValidationAmountRepositoryProtocol.self) {resource in
            TEFValidationAmountRepository(
                apiService: resource.resolve(APIServiceProtocol.self),
                errorParser: TEFValidationAmountErrorParser()
            )
        }

        defaultContainer.register(TEFValidationAmountPresenterProtocol.self) {resource in
            TEFValidationAmountPresenter(
                repository: resource.resolve(TEFValidationAmountRepositoryProtocol.self)
            )
        }

        defaultContainer.storyboardInitCompleted(TEFValidationAmountViewController.self) { resource, controller in
            controller.presenter = resource.resolve(
                TEFValidationAmountPresenterProtocol.self
            )
            controller.presenter?.setView(view: controller)
        }
        
        // MARK: Security Process
        
        defaultContainer.register(SecurityProcessRepositoryProtocol.self) {resource in
            SecurityProcessRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: SecurityProcessErrorParser())
        }
        
        defaultContainer.register(SecurityProcessPresenterProtocol.self) {resource in
            SecurityProcessPresenter(repository: resource.resolve(SecurityProcessRepositoryProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(SecurityProcessViewController.self) { resource, controller in
            controller.presenter = resource.resolve(SecurityProcessPresenterProtocol.self)
            controller.presenter?.setView(view: controller)
        }
        
        // MARK: Recover Account
        
        defaultContainer.register(RecoverAccountRepositoryProtocol.self) {resource in
            RecoverAccountRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: RecoverAccountErrorParser())
        }
        
        defaultContainer.register(RecoverAccountPresenterProtocol.self) {resource in
            RecoverAccountPresenter(repository: resource.resolve(RecoverAccountRepositoryProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(RecoverAccountViewController.self) { resource, controller in
            controller.presenter = resource.resolve(RecoverAccountPresenterProtocol.self)
            controller.presenter?.set(view: controller)
        }
        
        // MARK: RecoverAccountSuccessViewController
        
        defaultContainer.register(RecoverAccountSuccesssPresenterProtocol.self) { _ in
            RecoverAccountSuccesssPresenter()
        }
        
        defaultContainer.storyboardInitCompleted(RecoverAccountSuccessViewController.self) { resource, controller in
            controller.presenter = resource.resolve(RecoverAccountSuccesssPresenterProtocol.self)
            controller.presenter?.view = controller
        }
        
        // MARK: CreateAccount

        defaultContainer.register(CreateAccountRepositoryProtocol.self) {resource in
            CreateAccountRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: CreateAccountErrorParser())
        }

        defaultContainer.register(CreateAccountPresenterProtocol.self) {resource in
            CreateAccountPresenter(repository: resource.resolve(CreateAccountRepositoryProtocol.self))
        }

        defaultContainer.storyboardInitCompleted(CreateAccountViewController.self) { resource, controller in
            controller.presenter = resource.resolve(CreateAccountPresenterProtocol.self)
            controller.presenter?.set(view: controller)
        }

        // MARK: Storyboard

        defaultContainer.storyboardInitCompleted(RegisterNavigationViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(SwipeNavigationController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(TransactionNavigationViewController.self) { _, _ in
        }
        
        // MARK: StartAuthenticationProcess
       
        defaultContainer.register(StartAuthenticationProcessRepositoryProtocol.self) {resource in
            StartAuthenticationProcessRepository(apiService: resource.resolve(APIServiceProtocol.self), errorParser: StartAuthenticationProcessErrorParser())
        }

        defaultContainer.register(CreateAccountPresenterProtocol.self) {resource in
            CreateAccountPresenter(repository: resource.resolve(CreateAccountRepositoryProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(StartAuthenticationProcessViewController.self) { resource, controller in
            controller.presenter = resource.resolve(StartAuthenticationProcessPresenterProtocol.self)
            controller.presenter?.set(view: controller)
        }
        
        defaultContainer.register(StartAuthenticationProcessPresenterProtocol.self) {resource in
            StartAuthenticationProcessPresenter(repository: resource.resolve(StartAuthenticationProcessRepositoryProtocol.self))
        }
    }
}


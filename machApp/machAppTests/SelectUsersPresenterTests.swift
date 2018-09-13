////
////  SelectUsersTests.swift
////  machApp
////
////  Created by lukas burns on 6/6/17.
////  Copyright © 2017 Sismo. All rights reserved.
////
//
//import XCTest
//@testable import machApp
//
//class SelectUsersPresenterTests: XCTestCase {
//    var mockView: MockSelectUsersView!
//    var mockRepositorySuccess: MockSelectUsersRepositorySuccess!
//    var mockRepositoryFailure: MockSelectUsersRepositoryFailure!
//
//    override func setUp() {
//        super.setUp()
//        mockView = MockSelectUsersView()
//        mockRepositorySuccess = MockSelectUsersRepositorySuccess()
//        mockRepositoryFailure = MockSelectUsersRepositoryFailure()
//    }
//
//    override func tearDown() {
//        super.tearDown()
//        mockView = nil
//        mockRepositorySuccess = nil
//        mockRepositoryFailure = nil
//    }
//
//    func test_setTransactionMode_withPayment_paymentTransactionCorrectlySet() {
//        // Arrange
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: MockPermissionManager.sharedInstance)
//        let transactionMode = TransactionMode.payment
//        // Act
//        sut.setTransactionMode(transactionMode)
//        // Assert
//        XCTAssert(transactionMode == sut.transactionMode, "transaction mode is not equal to payment ")
//    }
//
//    func test_setTransactionMode_withRequest_requestTransactionCorrectlySet() {
//        // Arrange
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: MockPermissionManager.sharedInstance)
//        let transactionMode = TransactionMode.request
//        // Act
//        sut.setTransactionMode(transactionMode)
//        // Assert
//        XCTAssert(transactionMode == sut.transactionMode, "transaction mode is not equal to request ")
//    }
//
//    func test_loadUsers_contactPermissionNotGranted_callsViewAskForPermission() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        stubPermissionManager.stub(callIdentifier: "isContactsPermissionGranted()", yield: false)
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//        // Act
//        sut.loadUsers()
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "askForContactsPermission"), "Ask for permission was not called when contact permission not granted")
//    }
//
////    func test_loadUsers_repositoryFailure_callsShowError() {
////        // Arrange
////        let stubPermissionManager = MockPermissionManager()
////        stubPermissionManager.stub(callIdentifier: "isContactsPermissionGranted()", yield: true)
////        let sut = SelectUsersPresenter(repository: mockRepositoryFailure, permissionManager: stubPermissionManager)
////        sut.setView(view: mockView)
////
////        // Act
////        sut.loadUsers()
////
////        // Assert
////        XCTAssertTrue(mockView.wasCalled(callIdentifier: "showError(_:title:message:onAccepted)"), "show error in view is not called when repository fails")
////    }
//
//    func test_getUser_atIndexPath_returnsCorrectUser() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        let originalUser = SelectUserViewModel(user: User(firstName: "test", lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let sectionKey = "test"
//        let userSectionTitles = [sectionKey]
//        var usersDictionary: [String: [SelectUserViewModel]] = [:]
//        usersDictionary[sectionKey] = [originalUser]
//        sut.usersSectionTitles = userSectionTitles
//        sut.usersDictionary = usersDictionary
//        let indexPath = IndexPath(item: 0, section: 0)
//        // Act
//        let obtainedSelectUserViewModel = sut.getUser(for: indexPath)
//        // Assert
//        XCTAssertTrue(originalUser.user == obtainedSelectUserViewModel?.user, "getUsers does not return correct user")
//    }
//
//    func test_getSelectedUsers_usersSelected_areEqual() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        let originalUser = SelectUserViewModel(user: User(firstName: "test", lastName: nil, imageData: nil, phone: nil, images: nil))
//        sut.selectedUsers.append(originalUser)
//        // Act
//        let obtainedUser = sut.getSelectedUsers().first
//        // Assert
//        XCTAssert(originalUser.user == obtainedUser?.user, "getSelectedUsers does not return selected users")
//    }
//
//    func test_getNumberOfUsersForSection_2UsersForSection0_returns2() {
//        // Arrange
//        let expectedNumberOfUsers = 2
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        let firstUser = SelectUserViewModel(user: User(firstName: "test", lastName: nil, imageData: nil, phone: nil, images: nil))
//        let secondUser = SelectUserViewModel(user: User(firstName: "test2", lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let sectionKey = "test"
//        let userSectionTitles = [sectionKey]
//        var usersDictionary: [String: [SelectUserViewModel]] = [:]
//        usersDictionary[sectionKey] = [firstUser]
//        usersDictionary[sectionKey]?.append(secondUser)
//        sut.usersSectionTitles = userSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        // Act
//        let numberOfUsers = sut.getNumberOfUsersForSection(0)
//
//        // Assert
//        XCTAssert(numberOfUsers == expectedNumberOfUsers, "getNumberOfUsers returns incorrect amount")
//    }
//
//    func test_getNumberOfUsersForSection_sectionIndextOutOfRange_returns0() {
//        // Arrange
//        let expectedNumberOfUsers = 0
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//
//        // Act
//        let numberOfusers = sut.getNumberOfUsersForSection(0)
//
//        // Assert
//        XCTAssert(numberOfusers == expectedNumberOfUsers, "getNumberOfUsers returns value distinct than 0 for non exsistent section")
//    }
//
//    func test_getNumberOfUsersForSection_nonExistentSection_returns0() {
//        // Arrange
//        let expectedNumberOfUsers = 0
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//
//        let sectionKey = "test"
//        let userSectionTitles = [sectionKey]
//        let usersDictionary: [String: [SelectUserViewModel]] = [:]
//        sut.usersSectionTitles = userSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        // Act
//        let numberOfusers = sut.getNumberOfUsersForSection(0)
//
//        // Assert
//        XCTAssert(numberOfusers == expectedNumberOfUsers, "getNumberOfUsers returns value distinct than 0 for non exsistent section")
//    }
//
//    func test_getNumberOfSections_2sections_returns2() {
//        // Arrange
//        let expectedNumberOfSections = 2
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//
//        let firstSectionKey = "test"
//        let secondSectionKey = "test2"
//        let userSectionTitles = [firstSectionKey, secondSectionKey]
//        sut.usersSectionTitles = userSectionTitles
//
//        // Act
//        let numberOfSections = sut.getNumberOfSections()
//
//        // Assert
//        XCTAssert(expectedNumberOfSections == numberOfSections, "getNumberOfSections returns incorrect number")
//    }
//
//    func test_getTitleForUserSection_titleTestForSection0_returnsTest() {
//        // Arrange
//        let expectedSectionTitle = "test"
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//
//        let userSectionTitles = [expectedSectionTitle]
//        sut.usersSectionTitles = userSectionTitles
//
//        // Act
//        let sectionTitle = sut.getTitleForUserSection(0)
//
//        // Assert
//        XCTAssert(expectedSectionTitle == sectionTitle, "getTitleForUserSection doesnt return correct title")
//    }
//
//    func test_getUserIndexTitles_3Titles_returnsCorrectTitles() {
//        // Arrange
//        let expectedUserIndexTitles = ["A", "B", "C"]
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//
//        sut.userIndexTitles = expectedUserIndexTitles
//
//        // Act
//        let userIndexTitles = sut.getUserIndexTitles()
//
//        // Assert
//        XCTAssert(expectedUserIndexTitles == userIndexTitles!, "getUserIndexTitles returns incorrect titles")
//    }
//
//    func test_getSectionForIndexTitle_titleTestAtFirstSection_returns0() {
//        // Arrange
//        let expectedSection = 0
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//
//        let sectionTitle = "test"
//        let userSectionTitles = [sectionTitle]
//        sut.usersSectionTitles = userSectionTitles
//
//        // Act
//        let section = sut.getSectionForIndexTitle(sectionTitle)
//
//        // Assert
//        XCTAssert(expectedSection == section, "getSectionForIndexTitle returns incorrect section")
//    }
//
//    func test_getSectionForIndexTitle_unexistentTitle_returnsNegative1() {
//        // Arrange
//        let expectedSection = -1
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//
//        let sectionTitle = "test"
//        let userSectionTitles = [sectionTitle]
//        sut.usersSectionTitles = userSectionTitles
//
//        // Act
//        let section = sut.getSectionForIndexTitle("nonExistent")
//
//        // Assert
//        XCTAssert(expectedSection == section, "getSectionForIndexTitle returns incorrect section")
//    }
//
//    func test_inputSearchTest_called_removePlaceholderCalledAtView() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        // Act
//        sut.inputSearchText("")
//
//        // Assert
//        XCTAssert(mockView.wasCalled(callIdentifier: "removePlaceholder"), "input searchTest doesnt call removePlaceholder")
//    }
//
//    func test_inputSearchText_noResultsFound_callsInsertPlaceHolderAtView() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        // Act
//        sut.inputSearchText("a")
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "insertPlaceholder"), "insert place holder not called when result not found")
//    }
//
//    func test_inputSearchTest_called_updateCalledAtView() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        // Act
//        sut.inputSearchText("")
//
//        // Assert
//        XCTAssert(mockView.wasCalled(callIdentifier: "updateUsers"), "input searchTest doesnt call update users")
//    }
//
//    func test_searchButtonClicked_called_serchBarResignFirstResponderCalledAtView() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        // Act
//        sut.searchButtonClicked()
//
//        // Assert
//        XCTAssert(mockView.wasCalled(callIdentifier: "searchBarResignFirstResponder"), "input searchTest doesnt call searchBarResignFirstResponder")
//    }
//
//    func test_getSelectedUser_atIndex0_returnsCorrectSelectedUser() {
//        // Arrange
//        let expectedUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        let selectedUsers = [expectedUser]
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        let selectedUser = sut.getSelectedUser(for: IndexPath(row: 0, section: 0))
//
//        // Assert
//        XCTAssert(selectedUser!.user == expectedUser.user, "getSelectedUser for index returns incorrect user")
//    }
//
//    func test_userSelected_userAlreadySelected_removesCorrectUserFromSelectedUsers() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        let selectedUsers = [firstUser]
//        sut.selectedUsers = selectedUsers
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        firstUser.isSelected = true
//
//        // Act
//        sut.userSelected(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssert(sut.selectedUsers.first?.user != firstUser.user, "userSelected doesnt remove already selected user from selected user list")
//    }
//
//    func test_userSelected_userAlreadySelected_setIsUserSelectedFalse() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        let selectedUsers = [firstUser]
//        sut.selectedUsers = selectedUsers
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        firstUser.isSelected = true
//
//        // Act
//        sut.userSelected(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssert(firstUser.isSelected == false, "userSelected doesnt set selected user to false if already selected")
//    }
//
//    func test_userSelected_userNotSelected_userIsAddedToSelectedUsers() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        firstUser.isSelected = false
//
//        // Act
//        sut.userSelected(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssert(sut.selectedUsers.first?.user == firstUser.user, "userSelected is not added to selected users if user is not selected")
//    }
//
//    func test_userSelected_userNotSelected_setIsUserSelectedToTrue() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        let selectedUsers: [SelectUserViewModel] = []
//        sut.selectedUsers = selectedUsers
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        // Act
//        sut.userSelected(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssert(firstUser.isSelected == true, "userSelected doesnt set selected user to true if not selected")
//    }
//
//    func test_userSelected_emptySelectedUsers_callsUpdateUsers() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        firstUser.isSelected = true
//
//        // Act
//        sut.userSelected(at: IndexPath(row: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "updateUsers"), "userSelected doesn't called updatedUsers when selected users are empty")
//    }
//
//    func test_userSelectedNonemptySelectedUsers_callsUpdateUsers() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        firstUser.isSelected = false
//
//        // Act
//        sut.userSelected(at: IndexPath(row: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "updateUsers"), "userSelected doesn't called updatedUsers when selected users are not empty")
//    }
//
//    func test_userSelected_emptySelectedUsers_callsUpdateSelectedUsers() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        firstUser.isSelected = true
//
//        // Act
//        sut.userSelected(at: IndexPath(row: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "updateSelectedUsers"), "userSelected doesn't call updateSelectedUsers view when selected users are empty")
//    }
//
//    func test_userSelected_nonEmptySelectedUsers_callsUpdateSelectedUsers() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        firstUser.isSelected = true
//
//        // Act
//        sut.userSelected(at: IndexPath(row: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "updateSelectedUsers"), "userSelected doesn't call updateSelectedUsers view when selected users are not empty")
//    }
//
//    func test_userSelected_nonEmptyUsersSelected_hidesContinueButton() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        firstUser.isSelected = true
//
//        // Act
//        sut.userSelected(at: IndexPath(row: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "hideContinueButton"), "userSelected doesn't hide continue Button when selected users are empty")
//    }
//
//    func test_userSelected_emptyUsersSelected_hidesNumberOfSelectedUsersLabel() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        firstUser.isSelected = true
//
//        // Act
//        sut.userSelected(at: IndexPath(row: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "hideNumberOfSelectedUsersLabel"), "userSelected doesn't hide number of selected users label when selected users are empty")
//    }
//
//    func test_userSelected_nonEmptyUsersSelected_showsNumberOfSelectedUsersLabel() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        firstUser.isSelected = false
//
//        // Act
//        sut.userSelected(at: IndexPath(row: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "showNumberOfSelectedUsersLabel(_:)"), "userSelected doesn't show number of selected users label when selected users are not empty")
//    }
//
//    func test_userSelected_nonEmptyUsersSelected_showsUserSelectedView() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        firstUser.isSelected = false
//
//        // Act
//        sut.userSelected(at: IndexPath(row: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "showUsersSelectedView"), "userSelected doesn't show usersSelected view when selected users are not empty")
//    }
//
//    func test_userSelected_nonEmptyUsersSelected_showsContinueButton() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser]]
//
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//
//        firstUser.isSelected = false
//
//        // Act
//        sut.userSelected(at: IndexPath(row: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "showContinueButton"), "userSelected doesn't show continue Button when selected users are not empty")
//    }
//
//    func test_selectedUserRemoved_firsUserIsRemoved_setUserIsSelectedToFalse() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//        let selectedUsers = [firstUser]
//        firstUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.selectedUserRemoved(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssertFalse(firstUser.isSelected, "selectedUserRemoved doesnt set user is selected to false")
//    }
//
//    func test_selectedUserRemoved_nonEmptySelectedUsers_removesCorrectUserFromSelectedUsers() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//        let selectedUsers = [firstUser]
//        firstUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.selectedUserRemoved(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(sut.selectedUsers.isEmpty, "selectedUserRemoved doesnt remove user from selected users")
//    }
//
//    func test_selectedUserRemoved_selectedUsersEmpty_callsHideUsersSelectedView() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//        let selectedUsers = [firstUser]
//        firstUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.selectedUserRemoved(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "hideUsersSelectedView"), "selectedUserRemoved doesnt call hideUsersSelectedView when selectedUsers are empty")
//    }
//
//    func test_selectedUserRemoved_selectedUsersEmpty_callsHideContinueButton() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//        let selectedUsers = [firstUser]
//        firstUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.selectedUserRemoved(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "hideContinueButton"), "selectedUserRemoved doesnt call hideContinueButton when selectedUsers are empty")
//    }
//
//    func test_selectedUserRemoved_selectedUsersEmpty_callsHideNumberOfSelectedUsersLabel() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//        let selectedUsers = [firstUser]
//        firstUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.selectedUserRemoved(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "hideContinueButton"), "selectedUserRemoved doesnt call hideSelectedUsersLabel when selectedUsers are empty")
//    }
//
//    func test_selectedUserRemoved_selectedUsersNotEmpty_callsShowUsersSelectedView() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//        let secondUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let selectedUsers = [firstUser, secondUser]
//        firstUser.isSelected = true
//        secondUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.selectedUserRemoved(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "showUsersSelectedView"), "selectedUserRemoved doesnt call hideUsersSelectedView when selectedUsers are empty")
//    }
//
//    func test_selectedUserRemoved_selectedUsersNotEmpty_showsHideContinueButton() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//        let secondUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let selectedUsers = [firstUser, secondUser]
//        firstUser.isSelected = true
//        secondUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.selectedUserRemoved(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "showContinueButton"), "selectedUserRemoved doesnt call showContinueButton when selectedUsers are empty")
//    }
//
//    func test_selectedUserRemoved_selectedUsersNotEmpty_callsShowNumberOfSelectedUsersLabel() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//        let secondUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let selectedUsers = [firstUser, secondUser]
//        firstUser.isSelected = true
//        secondUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.selectedUserRemoved(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "showNumberOfSelectedUsersLabel(_:)"), "selectedUserRemoved doesnt call showSelectedUsersLabel when selectedUsers are empty")
//    }
//
//    func test_selectedUserRemoved_selectedUsersEmpty_callsUpdateUsers() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let selectedUsers = [firstUser]
//        firstUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.selectedUserRemoved(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "updateUsers"), "selectedUserRemoved doesnt call updateUsers when selectedUsers are empty")
//    }
//
//    func test_selectedUserRemoved_selectedUsersEmpty_callsUpdateSelectedUsers() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let selectedUsers = [firstUser]
//        firstUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.selectedUserRemoved(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "updateSelectedUsers"), "selectedUserRemoved doesnt call updateSelectedUsers when selectedUsers are empty")
//    }
//
//    func test_selectedUserRemoved_selectedUsersNotEmpty_callsUpdateUsers() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//        let secondUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let selectedUsers = [firstUser, secondUser]
//        firstUser.isSelected = true
//        secondUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.selectedUserRemoved(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "updateUsers"), "selectedUserRemoved doesnt call updateUsers when selectedUsers are empty")
//    }
//
//    func test_selectedUserRemoved_selectedUsersNotEmpty_callsUpdateSelectedUsers() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//        let secondUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let selectedUsers = [firstUser, secondUser]
//        firstUser.isSelected = true
//        secondUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.selectedUserRemoved(at: IndexPath(item: 0, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "updateSelectedUsers"), "selectedUserRemoved doesnt call updateSelectedUsers when selectedUsers are empty")
//    }
//
//    func test_backButtonPressed_emptySelectedUsers_callsGoBackToHome() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        // Act
//        sut.backButtonPressed()
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "goBackToHome"), "backButtonPressed with empty selectedUsers doesn't call back to home")
//    }
//
//    func test_backButtonPressed_paymentWithNonEmptySelectedUsers_callsShowConfirmationAlert() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//        sut.transactionMode = TransactionMode.payment
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let selectedUsers = [firstUser]
//        firstUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.backButtonPressed()
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "showConfirmationAlert(_:title:message:onAccepted:onCancelled)"), "backButtonPressed with non empty selectedUsers doesn't call show confirmation alert")
//    }
//
//    func test_backButtonPressed_requestWithNonEmptySelectedUsers_callsShowConfirmationAlert() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//        sut.transactionMode = TransactionMode.request
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let selectedUsers = [firstUser]
//        firstUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.backButtonPressed()
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "showConfirmationAlert(_:title:message:onAccepted:onCancelled)"), "backButtonPressed with non empty selectedUsers doesn't call show confirmation alert")
//    }
//
//    func test_backButtonPressed_paymentOnAcceptedConfirmationAlert_callsGoBackToHome() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//        sut.transactionMode = TransactionMode.payment
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let selectedUsers = [firstUser]
//        firstUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.backButtonPressed()
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "showConfirmationAlert(_:title:message:onAccepted:onCancelled)"), "backButtonPressed with non empty selectedUsers doesn't call show confirmation alert")
//    }
//
//    func test_backButtonPressed_requestOnAcceptedConfirmationAlert_callsGoBackToHome() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//        sut.transactionMode = TransactionMode.request
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let selectedUsers = [firstUser]
//        firstUser.isSelected = true
//
//        sut.selectedUsers = selectedUsers
//
//        // Act
//        sut.backButtonPressed()
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "showConfirmationAlert(_:title:message:onAccepted:onCancelled)"), "backButtonPressed with non empty selectedUsers doesn't call show confirmation alert")
//    }
//
////    func test_navigateToAmount_paymentWith1User_callsVanigateToSelectAmount() {
////        // Arrange
////        let stubPermissionManager = MockPermissionManager()
////        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
////        sut.setView(view: mockView)
////        sut.transactionMode = TransactionMode.payment
////
////        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
////
////        let selectedUsers = [firstUser]
////        sut.selectedUsers = selectedUsers
////
////        // Act
////        sut.navigateToAmount()
////
////        // Assert
////        XCTAssertTrue(mockView.wasCalled(callIdentifier: "navigateToSelectAmount"), "navigateToAmount doesnt call navigateToSelectAmount in view")
////    }
//
////    func test_navigateToAmount_requestWith1User_callsNanigateToSelectAmount() {
////        // Arrange
////        let stubPermissionManager = MockPermissionManager()
////        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
////        sut.setView(view: mockView)
////        sut.transactionMode = TransactionMode.request
////
////        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
////
////        let selectedUsers = [firstUser]
////        sut.selectedUsers = selectedUsers
////
////        // Act
////        sut.navigateToAmount()
////
////        // Assert
////        XCTAssertTrue(mockView.wasCalled(callIdentifier: "navigateToSelectAmount"), "navigateToAmount doesnt call navigateToSelectAmount in view")
////    }
//
//    func test_selectUser_secondUserSelected_callsShowUserCountError() {
//        // Arrange
//        let stubPermissionManager = MockPermissionManager()
//        let sut = SelectUsersPresenter(repository: mockRepositorySuccess, permissionManager: stubPermissionManager)
//        sut.setView(view: mockView)
//
//        let firstUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//        let secondUser = SelectUserViewModel(user: User(firstName: nil, lastName: nil, imageData: nil, phone: nil, images: nil))
//
//        let usersSectionTitles = ["test"]
//        let usersDictionary = ["test": [firstUser, secondUser]]
//
//        sut.usersSectionTitles = usersSectionTitles
//        sut.usersDictionary = usersDictionary
//        sut.selectedUsers = [firstUser]
//
//        firstUser.isSelected = true
//
//        // Act
//        sut.userSelected(at: IndexPath(row: 1, section: 0))
//
//        // Assert
//        XCTAssertTrue(mockView.wasCalled(callIdentifier: "showIncorrectNumberOfUsersError"), "second user selected doesn't show error")
//    }
//
//}

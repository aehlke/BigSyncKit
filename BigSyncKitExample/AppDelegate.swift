//
//  AppDelegate.swift
//  SyncKitCoreDataExample
//
//  Created by Manuel Entrena on 08/06/2019.
//  Copyright © 2019 Manuel Entrena. All rights reserved.
//

import UIKit
import RealmSwift
import BigSyncKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var realm: Realm!
    var settingsManager = SettingsManager()
    var settingsViewController: SettingsViewController?
    
    var synchronizer: CloudKitSynchronizer?
    lazy var sharedSynchronizer = CloudKitSynchronizer.sharedSynchronizer(containerName: CKContainer.default().containerIdentifier!, configuration: self.realmConfiguration)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        settingsManager.delegate = self
        loadRealm()
        
        guard let containerIdentifier = CKContainer.default().containerIdentifier else { return true }
        CKContainer(identifier: containerIdentifier).accountStatus { [weak self] (status, error) in
            guard let self = self else { return }
            
            switch status {
            case .available:
                self.synchronizer?.cancelSubscriptionForChangesInDatabase(completion: nil)
                self.loadSyncKit()
                self.synchronizer?.subscribeForChangesInDatabase(completion: nil)
                
                self.loadPrivateModule()
                self.loadSharedModule()
                self.loadSettingsModule()
            case .noAccount, .restricted, .couldNotDetermine:
                break
            @unknown default:
                break
            }
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        sharedSynchronizer.synchronize(completion: nil)
    }
    
    func loadSyncKit() {
        guard let containerIdentifier = CKContainer.default().containerIdentifier else { return }
        
        synchronizer = CloudKitSynchronizer.privateSynchronizer(
            containerName: containerIdentifier,
            configuration: self.realmConfiguration,
            recordZoneID: CKRecordZone.ID(zoneName: "QSCloudKitCustomZoneName", ownerName: CKCurrentUserDefaultName))
    }
    
    func loadPrivateModule() {
        let tabBarController: UITabBarController! = window?.rootViewController as? UITabBarController
        let navigationController: UINavigationController! = tabBarController.viewControllers?[0] as? UINavigationController
        let employeeWireframe = RealmEmployeeWireframe(navigationController: navigationController,
                                                          realm: realm)
        let companyWireframe = RealmCompanyWireframe(navigationController: navigationController,
                                                         realm: realm,
                                                         employeeWireframe: employeeWireframe,
                                                         synchronizer: synchronizer,
                                                         settingsManager: settingsManager)
        companyWireframe.show()
    }
    
    func loadSharedModule() {
        let tabBarController: UITabBarController! = window?.rootViewController as? UITabBarController
        let sharedNavigationController: UINavigationController! = tabBarController.viewControllers?[1] as? UINavigationController
        let realmSharedWireframe = RealmSharedCompanyWireframe(navigationController: sharedNavigationController,
                                                               synchronizer: sharedSynchronizer,
                                                               settingsManager: settingsManager)
        realmSharedWireframe.show()
    }
    
    func loadSettingsModule() {
        let tabBarController: UITabBarController! = window?.rootViewController as? UITabBarController
        let settingsNavigationController: UINavigationController! = tabBarController.viewControllers?[2] as? UINavigationController
        settingsViewController = settingsNavigationController.topViewController as? SettingsViewController
        settingsViewController?.settingsManager = settingsManager
        settingsViewController?.privateSynchronizer = synchronizer
    }

    // MARK: - Core Data stack
    
    func loadRealm() {
        realm = try! Realm(configuration: realmConfiguration)
    }
    
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let container = CKContainer(identifier: cloudKitShareMetadata.containerIdentifier)
        let acceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        acceptSharesOperation.qualityOfService = .userInteractive
        acceptSharesOperation.acceptSharesCompletionBlock = { [weak self] error in
            if let error = error {
                let alertController = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            } else {
                self?.sharedSynchronizer.synchronize(completion: nil)
            }
        }
        container.add(acceptSharesOperation)
    }
    
    lazy var realmConfiguration: Realm.Configuration = {
        var configuration = Realm.Configuration()
        configuration.schemaVersion = 1
        configuration.migrationBlock = { migration, oldSchemaVersion in
            
            if (oldSchemaVersion < 1) {
            }
        }
        
        configuration.objectTypes = [QSCompany.self, QSEmployee.self]
        return configuration
    }()
}

extension AppDelegate: SettingsManagerDelegate {
    func didSetSyncEnabled(value: Bool) {
        if value == false {
            synchronizer?.eraseLocalMetadata()
            synchronizer = nil
            settingsViewController?.privateSynchronizer = nil
            loadPrivateModule()
            
        } else {
            connectSyncKit()
        }
    }
    
    func connectSyncKit() {
        let alertController = UIAlertController(title: "Connecting CloudKit", message: "Would you like to bring existing data into CloudKit?", preferredStyle: .alert)
        let keepData = UIAlertAction(title: "Keep existing data", style: .default) { (_) in
            self.createNewSynchronizer()
        }
        
        let removeData = UIAlertAction(title: "No", style: .destructive) { (_) in
            let interactor = RealmCompanyInteractor(realm: self.realm,
                                                    shareController: nil)
            interactor.load()
            interactor.deleteAll()
            self.createNewSynchronizer()
        }
        alertController.addAction(keepData)
        alertController.addAction(removeData)
        settingsViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func createNewSynchronizer() {
        loadSyncKit()
        settingsViewController?.privateSynchronizer = synchronizer
        loadPrivateModule()
    }
}

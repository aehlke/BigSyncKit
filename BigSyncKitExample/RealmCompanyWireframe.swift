//
//  RealmCompanyWireframe.swift
//  SyncKitRealmSwiftExample
//
//  Created by Manuel Entrena on 26/06/2019.
//  Copyright © 2019 Manuel Entrena. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import BigSyncKit

class RealmCompanyWireframe: CompanyWireframe {
    
    let navigationController: UINavigationController
    let realm: Realm
    let employeeWireframe: EmployeeWireframe
    let synchronizer: CloudKitSynchronizer?
    let settingsManager: SettingsManager
    init(navigationController: UINavigationController, realm: Realm, employeeWireframe: EmployeeWireframe, synchronizer: CloudKitSynchronizer?, settingsManager: SettingsManager) {
        self.navigationController = navigationController
        self.realm = realm
        self.employeeWireframe = employeeWireframe
        self.synchronizer = synchronizer
        self.settingsManager = settingsManager
    }
    
    func show() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Company") as! CompanyViewController
        #if USE_INT_KEY
        let interactor = RealmCompanyInteractor_Int(realm: realm, shareController: synchronizer)
        #else
        let interactor = RealmCompanyInteractor(realm: realm, shareController: synchronizer)
        #endif
        let presenter = DefaultCompanyPresenter(view: viewController,
                                                interactor: interactor,
                                                wireframe: self,
                                                synchronizer: synchronizer,
                                                canEdit: true,
                                                settingsManager: settingsManager)
        viewController.presenter = presenter
        interactor.delegate = presenter
        navigationController.viewControllers = [viewController]
    }
    
    func show(company: Company, canEdit: Bool) {
        employeeWireframe.show(company: company, canEdit: canEdit)
    }
}

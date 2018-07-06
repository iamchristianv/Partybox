//
//  StartPartyViewController.swift
//  Partybox
//
//  Created by Christian Villa on 10/28/17.
//  Copyright © 2017 Christian Villa. All rights reserved.
//

import UIKit

class StartPartyViewController: UIViewController {
    
    // MARK: - Instance Properties

    private var store: Store!

    private var party: Party!
    
    private var contentView: StartPartyView!

    // MARK: - Construction Functions

    static func construct(store: Store) -> StartPartyViewController {
        let controller = StartPartyViewController()
        controller.store = store
        controller.party = nil
        controller.contentView = StartPartyView.construct(delegate: controller)
        return controller
    }
    
    // MARK: - View Controller Functions
    
    override func loadView() {
        self.view = self.contentView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupViewController()
    }
    
    // MARK: - Setup Functions
    
    private func setupViewController() {
        UIApplication.shared.statusBarStyle = .lightContent
        self.edgesForExtendedLayout = []
        self.showNavigationBar()
        self.setNavigationBarTitle("Start Party")
        self.setNavigationBarLeftButton(title: "cancel", target: self, action: #selector(cancelButtonPressed))
        self.setNavigationBarBackgroundColor(Partybox.color.red)
    }
    
    // MARK: - Navigation Bar Functions
    
    @objc private func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension StartPartyViewController: StartPartyViewDelegate {

    internal func startPartyView(_ view: StartPartyView, startButtonPressed: Bool) {
        let partyNameHasErrors = self.contentView.partyNameHasErrors()
        let userNameHasErrors = self.contentView.userNameHasErrors()

        if partyNameHasErrors || userNameHasErrors {
            return
        }

        self.party = Party.construct(partyName: self.contentView.partyName(), userName: self.contentView.userName())

        self.contentView.startAnimatingStartButton()

        self.party.initialize(callback: {
            (error) in

            if let error = error {
                let subject = "Uh oh"
                let message = error
                let action = "Okay"
                self.showAlert(subject: subject, message: message, action: action, handler: nil)
                return
            }

            self.party.enter(callback: {
                (error) in

                if let error = error {
                    let subject = "Uh oh"
                    let message = error
                    let action = "Okay"
                    self.showAlert(subject: subject, message: message, action: action, handler: nil)
                    return
                }

                let rootViewController = PartyViewController.construct(store: self.store, party: self.party, delegate: self)
                let navigationController = UINavigationController(rootViewController: rootViewController)
                self.present(navigationController, animated: true, completion: nil)
            })
        })
    }

}

extension StartPartyViewController: PartyViewControllerDelegate {

    internal func partyViewController(_ controller: PartyViewController, userKicked: Bool) {
        let subject = "Oh no"
        let message = "You were kicked from the party"
        let action = "Okay"
        self.showAlert(subject: subject, message: message, action: action, handler: nil)
    }

}

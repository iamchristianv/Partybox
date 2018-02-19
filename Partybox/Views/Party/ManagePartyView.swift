//
//  ManagePartyView.swift
//  Partybox
//
//  Created by Christian Villa on 2/17/18.
//  Copyright © 2018 Christian Villa. All rights reserved.
//

import UIKit

protocol ManagePartyViewDelegate {
    
    // MARK: - Manage Party View Delegate Functions
    
    func managePartyView(_ managePartyView: ManagePartyView, saveButtonPressed: Bool)
    
}

class ManagePartyView: UIView {
    
    // MARK: - Instance Properties
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.register(ManagePartyTableViewCell.self, forCellReuseIdentifier: ManagePartyTableViewCell.identifier)
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    
    lazy var saveButton: ActivityButton = {
        let saveButton = ActivityButton()
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleFont(UIFont.avenirNextMediumName, size: 22)
        saveButton.setBackgroundColor(UIColor.Partybox.green)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        return saveButton
    }()
    
    var contentCell: ManagePartyTableViewCell!
    
    // MARK: - Initialization Functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Functions
    
    func setupSubviews() {
        self.addSubview(self.tableView)
        self.addSubview(self.saveButton)
        
        self.tableView.snp.remakeConstraints({
            (make) in
            
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.saveButton.snp.top).offset(-32)
        })
        
        self.saveButton.snp.remakeConstraints({
            (make) in
            
            make.width.equalTo(220)
            make.height.equalTo(55)
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.tableView.snp.bottom).offset(32)
            make.bottom.equalTo(self.snp.bottom).offset(-32)
        })
    }
    
    // MARK: - Action Functions
    
    func reloadTable() {
        self.tableView.reloadData()
    }
    
    @objc func saveButtonPressed() {
        
    }

}

extension ManagePartyView: UITableViewDelegate {
    
    // MARK: - Table View Delegate Functions
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.contentCell.hideKeyboard()
    }
    
}

extension ManagePartyView: UITableViewDataSource {
    
    // MARK: - Table View Data Source Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = self.tableView.dequeueReusableCell(withIdentifier: ManagePartyTableViewCell.identifier)
        self.contentCell = tableViewCell as! ManagePartyTableViewCell
        self.contentCell.setPartyName(Party.details.name)
        return self.contentCell
    }
    
}

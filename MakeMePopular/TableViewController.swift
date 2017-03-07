//
//  TableViewController.swift
//  MakeMePopular
//
//  Created by Mac on 17/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, SectionHeaderViewDelegate{
    
    let SectionHeaderViewIdentifier = "SectionHeaderViewIdentifier"
    
    var sectionInfoArray: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sectionHeaderNib: UINib = UINib(nibName: "SectionHeaderView", bundle: nil)
        self.tableView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: SectionHeaderViewIdentifier)
        
        // you can change section height based on your needs
        self.tableView.sectionHeaderHeight = 30
        
        // You should set up your SectionInfo here
        var firstSection: SectionInfo = SectionInfo(itemsInSection: ["1","2"], sectionTitle: "firstSection")
        var secondSection: SectionInfo = SectionInfo(itemsInSection: ["4","3","5"], sectionTitle: "secondSection")
        sectionInfoArray.addObjects(from: [firstSection, secondSection])
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionInfoArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sectionInfoArray.count > 0 {
            var sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
            if sectionInfo.open {
                return sectionInfo.open ? sectionInfo.itemsInSection.count:0
            }
        }
        return 0
    }
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView: SectionHeaderView! = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderViewIdentifier) as! SectionHeaderView
        var sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
        
        sectionHeaderView.titleLabel.text = sectionInfo.sectionTitle
        sectionHeaderView.section = section
        sectionHeaderView.delegate = self
        let backGroundView = UIView()
        // you can customize the background color of the header here
        backGroundView.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1)
        sectionHeaderView.backgroundView = backGroundView
        return sectionHeaderView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell? ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        
       
        
        return cell
    }
    
    
    
    
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionOpened: Int) {
        var sectionInfo: SectionInfo = sectionInfoArray[sectionOpened] as! SectionInfo
        var countOfRowsToInsert = sectionInfo.itemsInSection.count
        sectionInfo.open = true
        
        var indexPathToInsert: NSMutableArray = NSMutableArray()
        for i in 0..<countOfRowsToInsert {
            indexPathToInsert.add(NSIndexPath(row: i, section: sectionOpened))
        }
        self.tableView.insertRows(at: indexPathToInsert as [AnyObject] as [AnyObject] as! [IndexPath], with: .top)
    }
    
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionClosed: Int) {
        var sectionInfo: SectionInfo = sectionInfoArray[sectionClosed] as! SectionInfo
        var countOfRowsToDelete = sectionInfo.itemsInSection.count
        sectionInfo.open = false
        if countOfRowsToDelete > 0 {
            var indexPathToDelete: NSMutableArray = NSMutableArray()
            for i in 0..<countOfRowsToDelete {
                indexPathToDelete.add(NSIndexPath(row: i, section: sectionClosed))
            }
            self.tableView.deleteRows(at: indexPathToDelete as [AnyObject] as [AnyObject] as! [IndexPath], with: .top)
        }
    }
}

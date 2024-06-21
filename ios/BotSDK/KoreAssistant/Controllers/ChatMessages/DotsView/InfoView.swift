//
//  InfoView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 30/09/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit
protocol InfoViewDelegate {
    func infoTableViewSelectRow(text:String)
    func hideInfoView()
}
class InfoView: UIView, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    var viewDelegate: InfoViewDelegate?
    var tableView: UITableView!
    let infoArray = ["About Bot","Go to Help Center","View all FAQs"]
    var tapToDismissGestureRecognizer: UITapGestureRecognizer!
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    fileprivate func setupViews() {
        //self.backgroundColor = UIColor.init(hexString: "#f8f9fc")
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.layer.cornerRadius = 10.0
        self.tableView.layer.masksToBounds = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.addSubview(self.tableView)
        self.tableView.tableFooterView = UIView()
        let bundle = KREResourceLoader.shared.resourceBundle()
        self.tableView.register(UINib(nibName: "InfoTableviewCell", bundle: bundle), forCellReuseIdentifier: "InfoTableviewCell")
        
        let views: [String: UIView] = ["tableView": tableView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-95-[tableView(132)]", options: [], metrics: nil, views: views))
       
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[tableView(177)]-55-|", options: [], metrics: nil, views: views))
        
        
        self.tapToDismissGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(InfoView.HideView(_:)))
        self.tapToDismissGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapToDismissGestureRecognizer)
    }
    @objc func HideView(_ gesture: UITapGestureRecognizer) {
        viewDelegate?.hideInfoView()
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.tableView) == true {
            return false
        }
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 44
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : InfoTableviewCell = self.tableView.dequeueReusableCell(withIdentifier: "InfoTableviewCell") as! InfoTableviewCell
        cell.backgroundColor = UIColor.white
        cell.selectionStyle = .none
        cell.textLbl.text = infoArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       viewDelegate?.infoTableViewSelectRow(text: infoArray[indexPath.row])
   }
}

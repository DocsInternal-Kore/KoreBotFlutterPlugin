//
//  TimeSlotViewController.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 19/12/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
protocol timeSlotDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}
class TimeSlotViewController: UIViewController {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var viewDelegate: timeSlotDelegate?
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bgV: UIView!
    var dataString: String!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dateTextLbl: UILabel!
    var selectedIndex = NSMutableArray()
    var selectedIndexValues = NSMutableArray()
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var underToplineLbl: UILabel!
    var slotsArray = [Any]()
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet var editImgV: UIImageView!
    @IBOutlet weak var calenderView: UIView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var confirmBtn: UIButton!
    var selectedDate = ""
    var selectedTime = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        calenderView.isHidden = true
        
        underToplineLbl.layer.cornerRadius = 3.0
        underToplineLbl.clipsToBounds = true
        
        // Do any additional setup after loading the view.
        dateLbl.font = UIFont(name: mediumCustomFont, size: 12.0)
        dateLbl.textColor = .black
        dateTextLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        dateTextLbl.textColor = themeColor
        titleLbl.font = UIFont(name: semiBoldCustomFont, size: 16.0)
        titleLbl.textColor = .black
        continueBtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        continueBtn.titleLabel?.textColor = UIColor.white
        continueBtn.backgroundColor = themeColor
        continueBtn.layer.cornerRadius = 4.0
        continueBtn.clipsToBounds = true
        collectionview.register(UINib.init(nibName: "TimeSlotCell", bundle: bundle), forCellWithReuseIdentifier: "TimeSlotCell")
        
        let bgImage = UIImage(named: "otpVBg", in: bundle, compatibleWith: nil)
        let tintedBgImage = bgImage?.withRenderingMode(.alwaysTemplate)
        editBtn.setImage(tintedBgImage, for: .normal)
        editBtn.tintColor = BubbleViewLeftTint
        
        let editImage = UIImage(named: "editTimes", in: bundle, compatibleWith: nil)
        let editTintedImage = editImage?.withRenderingMode(.alwaysTemplate)
        editImgV.image = editTintedImage
        editImgV.tintColor = themeColor
        
        if #available(iOS 11.0, *) {
            self.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
        }
        
        confirmBtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        confirmBtn.titleLabel?.textColor = UIColor.white
        confirmBtn.backgroundColor = themeColor
        confirmBtn.layer.cornerRadius = 4.0
        confirmBtn.clipsToBounds = true
        
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.backgroundColor = .white
            datePicker.sizeToFit()
        }
        datePicker.addTarget(self, action: #selector(CalenderViewController.datePickerChanged(datePicker:)), for: UIControl.Event.valueChanged)
        
        getData()
    }

    // MARK: init
    init(dataString: String) {
        super.init(nibName: "TimeSlotViewController", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidAppear(_ animated: Bool) {

    }
    @IBAction func closeBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        self.viewDelegate?.optionsButtonTapNewAction(text: "cancel", payload: "cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapsOnEditBtnAction(_ sender: UIButton) {
        if !calenderView.isHidden{
            //editBtn.isSelected = false
            calenderView.isHidden = true
        }else{
            //editBtn.isSelected = true
            calenderView.isHidden = false
        }
        
    }
    @IBAction func continueBtnAct(_ sender: Any) {
        if selectedTime != ""{
            self.dismiss(animated: true, completion: nil)
            viewDelegate?.optionsButtonTapNewAction(text: "\(selectedDate), \(selectedTime)", payload: "\(selectedDate), \(selectedTime)")
        }
        
    }
    @IBAction func tapsBtnConfimBtnAct(_ sender: Any) {
        selectDate(datePicker: datePicker)
        calenderView.isHidden = true
        
        selectedTime = ""
        selectedIndex = []
        selectedIndexValues = []
        for _ in 0..<slotsArray.count{
            selectedIndex.add(1000)
            selectedIndexValues.add("")
        }
        collectionview.reloadData()
    }
    
    @objc func datePickerChanged(datePicker:UIDatePicker){
       //selectDate(datePicker: datePicker)
    }
    func selectDate(datePicker:UIDatePicker){
        //let dayOfweek = datePicker.date.dayOfWeek()! as String
        let year = datePicker.date.year()! as String
        let day = datePicker.date.day()! as String
        let monthName = datePicker.date.monthName()! as String
        selectedDate = "\(day) \(monthName) \(year)"
        dateTextLbl.text = selectedDate
            
    }
    
    func getData(){
        let jsonDic: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        print(jsonDic)
        let buttons = jsonDic["buttons"] as? NSArray
        if buttons?.count == 0{
            continueBtn.isHidden = true
        }else{
            let btnDetails = buttons?[0] as? [String: Any]
            let btnTitle = btnDetails!["title"] as? String
            continueBtn.setTitle(btnTitle, for: .normal)
        }
        
        let slot_heading = jsonDic["slot_heading"] as? String
        let dateformat: String = jsonDic["format"] as? String  ?? "MM-dd-yyyy"
        var formtter: String?
        formtter = dateformat.replacingOccurrences(of: "D", with: "d")
        formtter = formtter!.replacingOccurrences(of: "Y", with: "y")
        
        if let endDateDic = jsonDic["endDate"] as? [String: Any]{
            let in_calendar_format = endDateDic["in_calendar_format"] as? String
            let showDate = endDateDic["showDate"] as? String
            dateTextLbl.text = showDate
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = formtter
            let endDate: NSDate? = dateFormatter.date(from: in_calendar_format!) as NSDate?
            //let startDateNew = (dateFormatter.string(from: fromDate! as Date))
            //print(startDateNew)
            datePicker.setDate(Date(), animated: true)
            datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -99, to: Date())
            datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: endDate! as Date)
            selectDate(datePicker: datePicker)
        }
        titleLbl.text = slot_heading
        slotsArray = jsonDic["slots"] as? [Any] ?? []
        
        selectedIndex = []
        selectedIndexValues = []
        
        for _ in 0..<slotsArray.count{
            selectedIndex.add(1000)
            selectedIndexValues.add("")
        }
        collectionview.reloadData()
    }

}

extension TimeSlotViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slotsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TimeSlotCell = collectionview.dequeueReusableCell(withReuseIdentifier: "TimeSlotCell", for: indexPath) as! TimeSlotCell
        cell.titleLbl.text = "\(slotsArray[indexPath.item])"//"9 AM-10 Am"
        cell.bgV.layer.cornerRadius = 6.0
        cell.bgV.clipsToBounds = true
        
        if selectedIndex[indexPath.item] as! Int == indexPath.item{
            cell.titleLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
            cell.bgV.layer.borderWidth = 2.0
            cell.bgV.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
        }else{
            cell.titleLbl.font = UIFont(name: regularCustomFont, size: 14.0)
            cell.bgV.layer.borderWidth = 1.0
            cell.bgV.layer.borderColor = UIColor.init(hexString: "#D7D7D7").cgColor
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: Multiple Items Selection
        selectedTime = "\(slotsArray[indexPath.item])"
        
        // MARK: Single Item Selection
        for i in 0..<slotsArray.count{
            selectedIndex.replaceObject(at: i, with: 1000)
            selectedIndexValues.replaceObject(at: indexPath.item, with: "")
        }
        selectedIndex.replaceObject(at: indexPath.item, with: indexPath.item)
        selectedIndexValues.replaceObject(at: indexPath.item, with: "\(slotsArray[indexPath.item])")
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.size.width - 72) / 2, height: 54)
        }
}

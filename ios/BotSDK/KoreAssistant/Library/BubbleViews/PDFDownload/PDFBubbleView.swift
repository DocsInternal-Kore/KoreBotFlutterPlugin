//
//  PDFBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 10/11/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class PDFBubbleView: BubbleView {
    public var maskview: UIView!
    var cardView: UIView!
    var tableView: UITableView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 80.0
    let cellIdentifier = "PdfDownloadCell"
    public var linkAction: ((_ text: String?) -> Void)!
    var pdfDownloadArray = [ComponentElements]()
    
    
    var tileBgv: UIView!
    var titleLbl: KREAttributedTextView!
    
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
    }
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.layer.rasterizationScale =  UIScreen.main.scale
        cardView.layer.shadowColor = UIColor.clear.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shouldRasterize = true
        cardView.layer.cornerRadius = 10.0
        cardView.backgroundColor =  BubbleViewLeftTint
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
    }
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 10.0
        self.tileBgv.layer.borderColor = UIColor.lightGray.cgColor
        self.tileBgv.clipsToBounds = true
        self.tileBgv.layer.borderWidth = 0.0
        self.cardView.addSubview(self.tileBgv)
        self.tileBgv.backgroundColor = BubbleViewLeftTint
        if #available(iOS 11.0, *) {
            //self.tileBgv.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 0)
        } else {
            // Fallback on earlier versions
        }
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.cardView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        let bundle = KREResourceLoader.shared.resourceBundle()
        self.tableView.register(UINib(nibName: cellIdentifier, bundle: bundle), forCellReuseIdentifier: cellIdentifier)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        if history{
            self.maskview.isHidden = true
        }else{
            self.maskview.isHidden = true
        }
        
        maskview.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        let listViews: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-0-[tableView]-10-|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tableView]-10-|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: listViews))
        
        self.titleLbl = KREAttributedTextView(frame: CGRect.zero)
        self.titleLbl.textColor = Common.UIColorRGB(0x484848)
        self.titleLbl.mentionTextColor = .white
        self.titleLbl.hashtagTextColor = .white
        self.titleLbl.linkTextColor = .white
        self.titleLbl.font = UIFont(name: mediumCustomFont, size: 14.0)
        self.titleLbl.backgroundColor = .clear
        self.titleLbl.isEditable = false
        self.titleLbl.isScrollEnabled = false
        self.titleLbl.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.titleLbl.linkTextColor = BubbleViewBotChatTextColor
        self.titleLbl.tintColor = BubbleViewBotChatTextColor
        self.tileBgv.addSubview(self.titleLbl)
 
        let subView: [String: UIView] = ["titleLbl": titleLbl]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl(>=21)]-16-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl]-16-|", options: [], metrics: nil, views: subView))
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                      let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                    return
                }
                self.titleLbl.setHTMLString(allItems.text ?? "", withWidth: kMaxTextWidth)
                pdfDownloadArray = allItems.elements ?? []
                tableView.reloadData()
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font?.pointSize ?? 0.0 {
            textSize.height = self.titleLbl.font?.pointSize ?? 0.0
        }
        
        var tableViewHeight = 0.0
        for i in 0..<pdfDownloadArray.count{
            //if pdfDownloadArray.count > 2{
                if i == pdfDownloadArray.count - 1{
                    tableViewHeight += 100.0
                }else{
                    tableViewHeight += 70.0
                }
            //}else{
                //tableViewHeight += 100.0
           // }
            
            
        }
        return CGSize(width: 0.0, height:  CGFloat(tableViewHeight) + textSize.height + 32)
    }
    

    @objc fileprivate func downloadButtonAction(_ sender: AnyObject!) {
        
        //        let pdf = pdfDownloadArray[sender.tag]
        //        if pdf.elementType == "url"{
        //            if pdf.elementUrl != nil{
        //                self.linkAction(pdf.elementUrl)
        //            }
        //        }
        
        let indexPath = IndexPath(row: pdfDownloadArray.count - 1, section: 0)
        if let cell = self.tableView.cellForRow(at: indexPath) as? PdfDownloadCell {
            cell.activityView.isHidden = false
            cell.activityView.startAnimating()
            cell.downloadBtn.isHidden = true
        }
                
                if (components.count > 0) {
                    let component: KREComponent = components.firstObject as! KREComponent
                    if (component.componentDesc != nil) {
                        let jsonString = component.componentDesc
                        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                        print(jsonObject)
                        if let elements = jsonObject["elements"] as? NSArray{
                            if elements.count > 0{
                                let pdfDetails = elements[0] as? AnyObject
                                let url = pdfDetails?["url"] as? String
                                let myString = (pdfDetails?["title"] as? String ?? "download")
                                let removeSpaceStr =  myString.replacingOccurrences(of: " ", with: "")
                                let date: Date = Date()
                                let timeStamp: Int?
                                timeStamp = Int(date.timeIntervalSince1970)
                                let title = "\(removeSpaceStr)\(timeStamp ?? 0).pdf"
                                let pdfType = pdfDetails?["pdfType"] as? Int
                                let type = pdfDetails?["type"] as? String
                                let fileFormat = pdfDetails?["format"] as? String
                                let header = pdfDetails?["header"] as? [String:Any]
                                var body = pdfDetails?["body"] as? [String:Any] //body
                                body?["format"] = fileFormat
//                                 let alreadyDownload = pdfFileAlreadySaved(fileName: "\(title)")
//                                if alreadyDownload{
//                                    showSavedPdf(fileName: "\(title)")
//                                }else{
                                //if pdfType == 1 || pdfType != nil{
                                    CallingApiBase64PDF(url: url ?? "", title: title, type: type ?? "POST" , fileFormat: fileFormat ?? "", header: header ?? [:], body: body ?? [:])
//                                }else{
//                                    self.downloadPDFApiCalling(url: url ?? "", title: title, type: type ?? "" , fileFormat: fileFormat ?? "", header: header ?? [:], body: body ?? [:])
//                                }
                                
//                                }
                            }
                        }
                        
                    }
                    
                }
            }
            
            func pdfFileAlreadySaved(fileName:String)-> Bool {
                var status = false
                if #available(iOS 10.0, *) {
                    do {
                        let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                        let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                        for url in contents {
                            if url.description.contains("\(fileName)") {
                                status = true
                            }
                        }
                    } catch {
                        print("could not locate pdf file !!!!!!!")
                    }
                }
                return status
            }


            func showSavedPdf(fileName:String) {
                if #available(iOS 10.0, *) {
                    do {
                        let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                        let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                        for url in contents {
                            if url.description.contains("\(fileName)") {
                                // its your file! do what you want with it!
                                print("Got it \(url)")
                                NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: "\(url)")
                            }
                        }
                    } catch {
                        print("could not locate pdf file !!!!!!!")
                    }
                }
            }
            
            func downloadPDFApiCalling(url: String, title: String, type: String, fileFormat: String, header: [String: Any], body: [String: Any]) {
                
                let urlString = url
                _ = URL(string: urlString)
                let fileName = String(title) as NSString
                // Create destination URL
                let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
                let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)")
                //Create URL to the source file you want to download
                let fileURL = URL(string: urlString)
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
                var request = URLRequest(url:fileURL!)
//                let authStr = header["Authorization"] as! String
//                let xReqwithStr = header["X-Requested-With"] as! String
//                request.setValue(authStr, forHTTPHeaderField: "Authorization")
//                request.setValue(xReqwithStr, forHTTPHeaderField: "X-Requested-With")
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let convertedHerader  = header.compactMapValues { $0 as? String }
                request.allHTTPHeaderFields = convertedHerader
                
                request.httpMethod = type
                let jsonDic = body
                
                var theJSONData = NSData()
                do {
                    theJSONData = try JSONSerialization.data(withJSONObject: jsonDic, options: JSONSerialization.WritingOptions()) as NSData
                } catch {
                    // completion(String())
                    print("JSOn DIC Error")
                }
                
                request.httpBody = theJSONData as Data
                
                let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        // Success 404
                        
                        let urlContents = try? String(contentsOf: tempLocalUrl, encoding: String.Encoding.utf8)
                        //print(urlContents)
                        let jsonObject: [String: Any] = Utilities.jsonObjectFromString(jsonString: urlContents ?? "") as? [String : Any] ?? [:]
                        //print(jsonObject["errorMessage"])
                        let errorMessage = jsonObject["errorMessage"] ?? "Unable to Download PDF"
                        //print("Status code: \(response) \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200 {
                            print("Successfully downloaded. Status code: \(statusCode)")
                            
                            do {
                                try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                                do {
                                    //Show UIActivityViewController to save the downloaded file
                                    let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                                    for indexx in 0..<contents.count {
                                        if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
                                            DispatchQueue.main.async {
                                                // Run UI Updates
                                                //self.maskview.isHidden = false
                                                let indexPath = IndexPath(row: self.pdfDownloadArray.count - 1, section: 0)
                                                if let cell = self.tableView.cellForRow(at: indexPath) as? PdfDownloadCell {
                                                cell.activityView.isHidden = true
                                                cell.activityView.stopAnimating()
                                                cell.downloadBtn.isHidden = false
                                                }
                                                
                                                NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: title)
                                                
                                            }
                                        }
                                    }
                                }
                                catch (let err) {
                                    print("error: \(err)")
                                    DispatchQueue.main.async {
                                        let indexPath = IndexPath(row: self.pdfDownloadArray.count - 1, section: 0)
                                        if let cell = self.tableView.cellForRow(at: indexPath) as? PdfDownloadCell {
                                        cell.activityView.isHidden = true
                                        cell.activityView.stopAnimating()
                                        cell.downloadBtn.isHidden = false
                                        }
                                    }
                                }
                            } catch (let writeError) {
                                print("Error creating a file \(destinationFileUrl) : \(writeError)")
                                DispatchQueue.main.async {
                                    let indexPath = IndexPath(row: self.pdfDownloadArray.count - 1, section: 0)
                                    if let cell = self.tableView.cellForRow(at: indexPath) as? PdfDownloadCell {
                                    cell.activityView.isHidden = true
                                    cell.activityView.stopAnimating()
                                    cell.downloadBtn.isHidden = false
                                    }
                                }
                            }
                            
                        }else{
                            DispatchQueue.main.async {
                                let indexPath = IndexPath(row: self.pdfDownloadArray.count - 1, section: 0)
                                if let cell = self.tableView.cellForRow(at: indexPath) as? PdfDownloadCell {
                                cell.activityView.isHidden = true
                                cell.activityView.stopAnimating()
                                cell.downloadBtn.isHidden = false
                                    if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 404{
                                        NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewErrorNotification), object: errorMessage)
                                    }
                                    if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 500{
                                        NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewErrorNotification), object: errorMessage)
                                    }
                                    if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 401{
                                        NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewErrorNotification), object: errorMessage)
                                    }
                                    if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 400{
                                        NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewErrorNotification), object: errorMessage)
                                    }
                                }
                            }
                        }
                       
                    } else {
                        print("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "")")
                    }
                }
                task.resume()
                
            }
    
    
    func CallingApiBase64PDF(url: String, title: String, type: String, fileFormat: String, header: [String: Any], body: [String: Any]) {
       
        let urlString = url
        _ = URL(string: urlString)
        let fileName = String(title) as NSString
        // Create destination URL
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        _ = documentsUrl.appendingPathComponent("\(fileName)")
        //Create URL to the source file you want to download
        let fileURL = URL(string: urlString)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        var request = URLRequest(url:fileURL!)
        let authStr = header["Authorization"] as? String ?? ""
        let xReqwithStr = header["X-Requested-With"] as? String ?? ""
        request.setValue(authStr, forHTTPHeaderField: "Authorization")
        request.setValue(xReqwithStr, forHTTPHeaderField: "X-Requested-With")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = type
        let jsonDic = body
        
        var theJSONData = NSData()
        do {
            theJSONData = try JSONSerialization.data(withJSONObject: jsonDic, options: JSONSerialization.WritingOptions()) as NSData
        } catch {
            // completion(String())
            print("JSOn DIC Error")
        }
        
        request.httpBody = theJSONData as Data
          session.dataTask(with: request) { (data, response, error) in
              if let response = response {
                  print(response)
              }
              if let data = data {
                  do {
                      let jsonDic = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                   if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                       if statusCode != 200 {
                           let errorMessage = jsonDic?["errorMessage"] as? String
                        DispatchQueue.main.async {
                            let indexPath = IndexPath(row: self.pdfDownloadArray.count - 1, section: 0)
                            if let cell = self.tableView.cellForRow(at: indexPath) as? PdfDownloadCell {
                            cell.activityView.isHidden = true
                            cell.activityView.stopAnimating()
                            cell.downloadBtn.isHidden = false
                                NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewErrorNotification), object: errorMessage ?? "")
                                print(errorMessage ?? "")
                            }
                        }
                        
                       }
                   }
                   if let responseDic = jsonDic,
                      let responseStatus = responseDic["status"] as? String {
                       if responseStatus == "success"{
                           let data = responseDic["data"] as? String
                            let fileData = data
                           if let base64str = fileData{
                               self.saveBase64StringToPDF(base64str, fileName: title)
                           }
                       }else{
                        DispatchQueue.main.async {
                            let indexPath = IndexPath(row: self.pdfDownloadArray.count - 1, section: 0)
                            if let cell = self.tableView.cellForRow(at: indexPath) as? PdfDownloadCell {
                            cell.activityView.isHidden = true
                            cell.activityView.stopAnimating()
                            cell.downloadBtn.isHidden = false
                                NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewErrorNotification), object: "please try again later")
                            }
                        }
                       }
                    
                     }
                  } catch {
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: self.pdfDownloadArray.count - 1, section: 0)
                        if let cell = self.tableView.cellForRow(at: indexPath) as? PdfDownloadCell {
                        cell.activityView.isHidden = true
                        cell.activityView.stopAnimating()
                        cell.downloadBtn.isHidden = false
                            NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewErrorNotification), object: "please try again later")
                        }
                    }
                      print(error)
                  }
              }
          }.resume()
}
   
   func saveBase64StringToPDF(_ base64String: String, fileName: String) {
       guard
           var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last,
           let convertedData = Data(base64Encoded: base64String)
           else {
           //handle error when getting documents URL
           return
       }
       //name your file however you prefer
       documentsURL.appendPathComponent(fileName)

       do {
           try convertedData.write(to: documentsURL)
       } catch {
           //handle write error here
       }
       print(documentsURL)
       
       if #available(iOS 10.0, *) {
           do {
               let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
               let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
               for url in contents {
                   if url.description.contains("\(fileName)") {
                       // its your file! do what you want with it!
                       let contents  = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                       for indexx in 0..<contents.count {
                           if contents[indexx].lastPathComponent == url.lastPathComponent {
                               DispatchQueue.main.async {
                                // Run UI Updates
                                //self.maskview.isHidden = false
                                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
                                    let indexPath = IndexPath(row: self.pdfDownloadArray.count - 1, section: 0)
                                    if let cell = self.tableView.cellForRow(at: indexPath) as? PdfDownloadCell {
                                    cell.activityView.isHidden = true
                                    cell.activityView.stopAnimating()
                                    cell.downloadBtn.isHidden = false
                                    }
                                    //NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: fileName)
                                    NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: "Show")
                                }
                            }
                           }
                       }
                   }
               }
           } catch {
               print("could not locate pdf file !!!!!!!")
           }
       }
   }
    
    
    
        }

extension PDFBubbleView: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        //if pdfDownloadArray.count > 2{
            if indexPath.row == pdfDownloadArray.count - 1 {
                return 100
            }else{
                return 70
            }
//        }else{
//            return 100
//        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //if pdfDownloadArray.count > 2{
            if indexPath.row == pdfDownloadArray.count - 1 {
                return 100
            }else{
                return 70
            }
//        }else{
//            return 100
//        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pdfDownloadArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : PdfDownloadCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! PdfDownloadCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let pdf = pdfDownloadArray[indexPath.row]
        cell.titleLbl.text = pdf.title
        cell.titleLbl.textColor = .black
        cell.titleLbl.font =  UIFont(name: regularCustomFont, size: 14.0)
        cell.downloadBtn.tag = indexPath.row
        cell.downloadBtn.addTarget(self, action: #selector(self.downloadButtonAction(_:)), for: .touchUpInside)
        
        if indexPath.row == pdfDownloadArray.count - 1 {
            //this is the last row in section.
            cell.downloadBtnheightConstraint.constant = 30.0
        }else{
            cell.downloadBtnheightConstraint.constant = 0.0
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

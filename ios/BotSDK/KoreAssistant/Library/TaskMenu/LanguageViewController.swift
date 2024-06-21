//
//  LanguageViewController.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 29/09/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
protocol LanguageChangeDelegate {
    func languageChange(text:String)
}
class LanguageViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var engBtn: UIButton!
    @IBOutlet var arabicBtn: UIButton!
    var viewDelegate: LanguageChangeDelegate?
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var darkView: UIView!
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subView.layer.cornerRadius = 18.0
        subView.clipsToBounds = true
        // Do any additional setup after loading the view.
        self.engBtn.titleLabel?.font = UIFont(name: regularCustomFont, size: 14.0)
        self.arabicBtn.titleLabel?.font = UIFont(name: regularCustomFont, size: 14.0)

        engBtn.layer.cornerRadius = 4.0
        engBtn.layer.borderWidth = 1.0
        engBtn.layer.borderColor = themeColor.cgColor
        engBtn.clipsToBounds = true
        engBtn.backgroundColor = themeColor
        engBtn.setTitle("Continue in English", for: .normal)

        arabicBtn.layer.cornerRadius = 4.0
        arabicBtn.layer.borderWidth = 1.0
        arabicBtn.layer.borderColor = themeColor.cgColor
        arabicBtn.clipsToBounds = true
        arabicBtn.backgroundColor = themeColor
        arabicBtn.setTitle("تغيير اللغة إلى العربية", for: .normal)
        self.engBtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        if preferredLanguage == preferred_language_Type{
            arabicBtn.layer.borderWidth = 0.0
            arabicBtn.backgroundColor = themeColor
            arabicBtn.setTitleColor(.white, for: .normal)
            engBtn.layer.borderWidth = 1.0
            engBtn.backgroundColor = .clear
            engBtn.setTitleColor(themeColor, for: .normal)

            subView.semanticContentAttribute = .forceRightToLeft
            titleLabel.textAlignment = .right
            titleLabel.text = "Virtual Assistant Language"//"لغة المساعد الظاهري"
        }else{
            engBtn.layer.borderWidth = 0.0
            engBtn.backgroundColor = themeColor
            engBtn.setTitleColor(.white, for: .normal)

            arabicBtn.layer.borderWidth = 1.0
            arabicBtn.backgroundColor = .clear
            arabicBtn.setTitleColor(themeColor, for: .normal)

           subView.semanticContentAttribute = .forceLeftToRight
           titleLabel.textAlignment = .left
            titleLabel.text = "Virtual Assistant Language"
        }
        
        self.tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(dismissVC(_:)))
        self.darkView.addGestureRecognizer(tapGesture)
    }

    @objc func dismissVC(_ gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    public init() {
        super.init(nibName: "LanguageViewController", bundle: Bundle(for: LanguageViewController.self))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func tapsOnCloseBtnAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapsOnEngLishBtn(_ sender: Any) {
        self.viewDelegate?.languageChange(text: "cheat lang en")
        preferredLanguage = "EN"
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapsOnArabicBtn(_ sender: Any) {
        self.viewDelegate?.languageChange(text: "cheat lang ar")
        preferredLanguage = "AR"
        self.dismiss(animated: true, completion: nil)
    }

}

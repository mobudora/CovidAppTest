//
//  BeforeCovidViewController.swift
//  covidNow
//
//  Created by 新久保龍之介 on 2022/03/01.
//

import UIKit

class BeforeCovidViewController: UIViewController {
    
    let colors = Colors()
    var goHealthButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "コロナ予防"
        goHealthButton = UIBarButtonItem(title: "Covidチェック", style: .plain, target: self, action: #selector(goHealthCheck))
        navigationItem.rightBarButtonItem = goHealthButton
        
        view.backgroundColor = .systemGroupedBackground

        let resultButton = UIButton(type: .system)
        resultButton.frame = CGRect(x: 0, y: 820, width: 200, height: 40)
        resultButton.titleLabel?.font = .systemFont(ofSize: 20)
        resultButton.layer.cornerRadius = 5
        resultButton.layer.shadowColor = UIColor.black.cgColor
        resultButton.layer.shadowOpacity = 0.3
        //影のぼかしの強さ
        resultButton.layer.shadowRadius = 4
        //widthが大きいと右にheightは下に影が伸びる
        resultButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        resultButton.setTitle("診断完了", for: .normal)
        resultButton.setTitleColor(colors.darkGray, for: .normal)
        resultButton.backgroundColor = colors.blownGray
        view.addSubview(resultButton)
        
    }
    
    @objc func goHealthCheck(sender: UIButton)
    {
        let nextVc = HealthViewController()
        self.navigationController?.pushViewController(nextVc, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

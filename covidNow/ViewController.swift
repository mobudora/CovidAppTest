//
//  ViewController.swift
//  covidNow
//
//  Created by 新久保龍之介 on 2022/02/14.
//

import UIKit
import PKHUD

class ViewController: UIViewController {
    
    let colors = Colors()
    var goChatButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpGradation()
        setUpContent()
    }

    func setUpContent()
    {
        let contentView = UIView()
        contentView.frame.size = CGSize(width: view.frame.size.width, height: 340)
        contentView.center = CGPoint(x: view.center.x, y: view.center.y)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 30
        //shadowOffset = CGSize(width: 大きければ大きほど右に動く, height: 大きければ大きいほど下に動く)
        contentView.layer.shadowOffset = CGSize(width: 2, height: 2)
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOpacity = 0.5
        view.addSubview(contentView)
        
        view.backgroundColor = .systemGray6
        
        let labelFont = UIFont.systemFont(ofSize: 15, weight: .heavy)
        let size = CGSize(width: 150, height: 50)
        let color = colors.darkGray
        let leftx = view.frame.size.width * 0.33
        let rightx = view.frame.size.width * 0.80
        //yは左上起点の位置　親の要素に表示される→parentViewがcontentViewだから、contentViewに表示される
        setUpLabel("Covid in Japan", size: CGSize(width: 180, height: 35), centerX: view.center.x-20, y: -60, font: .systemFont(ofSize: 25, weight: .heavy), color: .white, contentView)
        setUpLabel("PCR数", size: size, centerX: leftx, y: 20, font: labelFont, color: color, contentView)
        setUpLabel("感染者数", size: size, centerX: rightx, y: 20, font: labelFont, color: color, contentView)
        setUpLabel("入院者数", size: size, centerX: leftx, y: 120, font: labelFont, color: color, contentView)
        setUpLabel("重症者数", size: size, centerX: rightx, y: 120, font: labelFont, color: color, contentView)
        setUpLabel("死者数", size: size, centerX: leftx, y: 220, font: labelFont, color: color, contentView)
        setUpLabel("退院者数", size: size, centerX: rightx, y: 220, font: labelFont, color: color, contentView)
        
        let height = view.frame.size.height / 2
        //健康管理ボタン
        setUpButton(title: "コロナ予防", size: size, y: height + 190, color: colors.darkGray, parentView: view).addTarget(self, action: #selector(goBeforeCovid), for: .touchDown)
        setUpButton(title: "コロナグラフ", size: size, y: height + 250, color: colors.darkGray, parentView: view).addTarget(self, action: #selector(goChart), for: .touchDown)
//        setUpButton(title: "コロナになったら", size: size, y: height + 310, color: colors.darkGray, parentView: view)
        //.addTarget(self, action:　関数名, for:　タイミング)メソッドでボタンを押した時に呼び出す関数を指定や押したときか離すときかの指定もできるselectorで呼び出される関数には@objcと書かなければいけない.touchDownは押したとき
        //チャットボタンに遷移するボタン
        title = "統計"
        //戻るボタンの文字を消す
        self.navigationItem.backButtonDisplayMode = .minimal
        //イメージ変数
        let goChatImage = UIImage(named: "bubble-chat")
        //UIBarButtonItemの宣言をしたbutton変数に特徴を書く。
        goChatButton = UIBarButtonItem(image: goChatImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(chatAction))
        navigationItem.rightBarButtonItem = goChatButton
        //リロードボタン
        reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadAction))
        navigationItem.leftBarButtonItem = reloadButton
        //ウイルス画像配置
        //イメージをそのまま表示するにはインスタンス化
        let imageView = UIImageView()
        //画像を代入
        let image = UIImage(named: "virus")
        imageView.image = image
        //x: view.frame.size.widthで画面外に最初配置しておく
        imageView.frame = CGRect(x: view.frame.size.width, y: -65, width: 50, height: 50)
        contentView.addSubview(imageView)
        UIView.animate(withDuration: 1.5, delay: 0.5, options: [.curveEaseIn],
            animations:
            {
                //x:-100移動させる画面右外から
                imageView.frame = CGRect(x: self.view.frame.size.width-100, y:-65, width: 50, height: 50)
                imageView.transform = CGAffineTransform(rotationAngle: -90)
            }, completion: nil)
        
        //APIの実装
        setUpAPI(parentView: contentView)
    }
    
    func setUpAPI(parentView: UIView)
    {
        //データを表示するためのUILabel()を定義
        let pcr = UILabel()
        let positive = UILabel()
        let hospitalize = UILabel()
        let severe = UILabel()
        let death = UILabel()
        let discharge = UILabel()
        
        let size = CGSize(width: 200, height: 40)
        let leftX = view.frame.size.width * 0.38
        let rightX = view.frame.size.width * 0.85
        let font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        let color = colors.darkGray
        
        setUpAPILabel(pcr, size: size, centerX: leftX, y: 60, font: font, color: color, parentView)
        setUpAPILabel(positive, size: size, centerX: rightX, y: 60, font: font, color: color, parentView)
        setUpAPILabel(hospitalize, size: size, centerX: leftX, y: 160, font: font, color: color, parentView)
        setUpAPILabel(severe, size: size, centerX: rightX, y: 160, font: font, color: color, parentView)
        setUpAPILabel(death, size: size, centerX: leftX, y: 260, font: font, color: color, parentView)
        setUpAPILabel(discharge, size: size, centerX: rightX, y: 260, font: font, color: color, parentView)
        
        HUD.show(.progress, onView: view)
        //リクエスト関数の呼び出し
        //resultはデータを格納する引数でどんな名前でも大丈夫。Voidは返り値をAPIファイルからもらっていないため
        CovidAPI.getTotal(completion:
                {(result: CovidInfo.Total) -> Void in
                //表示に関する処理はスレッドの中でもメインスレッドにしなければいけない→DispatchQueue.main.asyncでメインスレッドにする
                DispatchQueue.main.async
                {
                    //データはInt型なのでString型に変換しなければいけない
                    pcr.text = "\(result.pcr)"
                    positive.text = "\(result.positive)"
                    hospitalize.text = "\(result.hospitalize)"
                    severe.text = "\(result.severe)"
                    death.text = "\(result.death)"
                    discharge.text = "\(result.discharge)"
                    HUD.hide()
                }
            })
    }
    
    func setUpAPILabel(_ label: UILabel, size: CGSize, centerX: CGFloat, y: CGFloat, font: UIFont, color: UIColor, _ parentView: UIView)
    {
        label.frame.size = size
        label.center.x = centerX
        label.frame.origin.y = y
        label.font = font
        label.textColor = color
        parentView.addSubview(label)
    }
    
    //関数の後ろに->で呼び出し元setUpImageButton()にUIButtonを返す書き方
//    func setUpImageButton(_ name: String, lx: CGFloat, top: CGFloat, w: CGFloat, h: CGFloat) -> UIButton
//    {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        //ボタンのアイコンを設定にはUIImageメソッドを使う。.setImage(UIImage(named: nameの引数を使うことでファイル名を呼び出し元で書く), for: ボタンの状態)normalで通常状態selectedで選択状態
//        button.setImage(UIImage(named: name), for: .normal)
//        //設定した画像の色を変える
//        button.tintColor = .white
//        view.addSubview(button)
//        //AutoLayoutで指定
//        button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: top).isActive = true
//        button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: lx).isActive = true
//        button.widthAnchor.constraint(equalToConstant: w).isActive = true
//        button.heightAnchor.constraint(equalToConstant: h).isActive = true
//        return button
//    }
    
    @objc func reloadAction()
    {
        //画面更新
        loadView()
        viewDidLoad()
    }
    
    @objc func chatAction()
    {
//        performSegue(withIdentifier: "goChat", sender: nil)
        let goChat = ChatViewController()
        navigationController?.pushViewController(goChat, animated: true)
    }
    
    @objc func goBeforeCovid()
    {
        let nextVc = BeforeCovidViewController()
        self.navigationController?.pushViewController(nextVc, animated: true)
    }
    //県別状況をタップした時に遷移
    @objc func goChart()
    {
        let nextVc = ChartViewController()
        self.navigationController?.pushViewController(nextVc, animated: true)
    }
    
    func setUpButton(title: String, size: CGSize, y: CGFloat, color: UIColor, parentView: UIView) -> UIButton
    {
        //UIButtonのtypeを.systemにしてあげることでボタンとしての機能を持たせる→タップした時に色が明るくなる
        let button = UIButton(type: .system)
        //UIButtonにタイトルをつけるにはsetTitleメソッドを使う　通常は.normal
        button.setTitle(title, for: .normal)
        button.frame = CGRect(x: 0, y: Int(y), width: 150, height: 40)
        button.center.x = parentView.center.x
        button.backgroundColor = colors.whiteGray
        button.layer.cornerRadius = 5
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 5
        button.layer.shadowColor = UIColor.gray.cgColor
        button.center.x = view.center.x
        //文字に特殊な加工をしたい時にNSAttributedStringを使う今回は文字同士の間隔を設定NSAttributedString(string: title, attributes: [NSAttributedString.Key.kern : 間隔])
//        if #available(iOS 14.0, *) {
//            let attributedTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.tracking: 8.0])
//            //上記のattributedTitleを.setAttributedTitle(attributedTitle, for: .normal)で適用させる
//            button.setAttributedTitle(attributedTitle, for: .normal)
//        }
//        } else {
//            let attributedTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.kern : 8.0])
//            button.setAttributedTitle(attributedTitle, for: .normal)
//        }
        //ボタンの色を変えるには.setTitleColor(color, for: .normal)
        button.setTitleColor(color, for: .normal)
        //親要素の上に表示する
        parentView.addSubview(button)
        return button
    }
    
    func setUpLabel(_ text: String, size: CGSize, centerX: CGFloat, y: CGFloat, font: UIFont, color: UIColor, _ parentView: UIView)
    {
        let label = UILabel()
        label.text = text
        label.frame.size = size
        label.center.x = centerX
        label.frame.origin.y = y
        label.font = font
        label.textColor = color
        parentView.addSubview(label)
    }
    
    func setUpGradation()
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height/2)
        //グラデーション設定をしているgradientLayer.colors = [左上colors.blownGray.cgColor,右下colors.whiteGray.cgColor]
        gradientLayer.colors = [colors.blownGray.cgColor,colors.whiteGray.cgColor]
        //左上から
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        //右下へグラデーションをかける
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        //view.layer.insertSublayer(子, at: 階層)atの数字が大きいほど前面にいく
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

//
//  HealthViewController.swift
//  covidNow
//
//  Created by 新久保龍之介 on 2022/02/15.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic

class HealthViewController: UIViewController
{
    //インスタンス化
    let colors = Colors()
    let calendar = FSCalendar()
    var point = 0
    var today = ""

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Covidチェック"

        // Do any additional setup after loading the view.
        //viewの背景色を薄いグレーにする
        view.backgroundColor = .systemGroupedBackground
        //今日の日付を保存
        today = dateFormatter(day: Date())
        //インスタンス化
        let scrollView = UIScrollView()
        //ここで設定するサイズは画面上のどの範囲をスクロールが反応するかにしたいかを決める→今回は全体をスクロール範囲としている
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        //スクロールする量を決めている
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 950)
        //スクロールビューをviewに載せる
        view.addSubview(scrollView)
        
        //カレンダーを表示
        createCalendar(parentView: scrollView)
        
        //診断チェック見出し作り
        let checkLabel = UILabel()
        checkLabel.text = "健康チェック"
        checkLabel.textColor = colors.darkGray
        checkLabel.frame = CGRect(x: 0, y: 340, width: view.frame.size.width, height: 21)
        checkLabel.backgroundColor = colors.whiteGray
        checkLabel.textAlignment = .center
        checkLabel.center.x = view.center.x
        scrollView.addSubview(checkLabel)
        
        let uiView1 = createView(y: 380)
        scrollView.addSubview(uiView1)
        createImage(parentView: uiView1, imageName: "check1")
        createLabel(parentView: uiView1, text: "37.5度以上の熱がある")
        //呼び出す関数を設定するには#selector(関数名)とする
        createUISwitch(parentView: uiView1, action: #selector(switchAction))
        let uiView2 = createView(y: 465)
        scrollView.addSubview(uiView2)
        createImage(parentView: uiView2, imageName: "check2")
        createLabel(parentView: uiView2, text: "のどの痛みがある")
        createUISwitch(parentView: uiView2, action: #selector(switchAction))
        let uiView3 = createView(y: 550)
        scrollView.addSubview(uiView3)
        createImage(parentView: uiView3, imageName: "check3")
        createLabel(parentView: uiView3, text: "匂いを感じない")
        createUISwitch(parentView: uiView3, action: #selector(switchAction))
        let uiView4 = createView(y: 635)
        scrollView.addSubview(uiView4)
        createImage(parentView: uiView4, imageName: "check4")
        createLabel(parentView: uiView4, text: "味が薄く感じる")
        createUISwitch(parentView: uiView4, action: #selector(switchAction))
        let uiView5 = createView(y: 720)
        scrollView.addSubview(uiView5)
        createImage(parentView: uiView5, imageName: "check5")
        createLabel(parentView: uiView5, text: "だるさがある")
        createUISwitch(parentView: uiView5, action: #selector(switchAction))
        
        //診断結果ボタン表示
        createResultButton(parentView: scrollView)
    }
    
    //カレンダーの装飾
    func createCalendar(parentView: UIView)
    {
        calendar.frame = CGRect(x: 20, y: 10, width: view.frame.size.width-40, height: 300)
        //スクロールビューにcalendarを載せる
        parentView.addSubview(calendar)
        calendar.appearance.headerTitleColor = colors.darkGray
        calendar.appearance.weekdayTextColor = colors.darkGray
        calendar.delegate = self
        calendar.dataSource = self
    }
    
    //createView()の上に診断結果ボタンをのせる
    func createResultButton(parentView: UIView)
    {
        let resultButton = UIButton(type: .system)
        resultButton.frame = CGRect(x: 0, y: 820, width: 200, height: 40)
        resultButton.center.x = parentView.center.x
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
        resultButton.addTarget(self, action: #selector(resultButtonAction), for: [.touchUpInside, .touchUpOutside])
        parentView.addSubview(resultButton)
        //今日の日付と照らし合わせて診断結果ボタンが1日1回だけ動作するようにする
        //Key値の値todayの値がnilでなかった場合（診断完了してローカルに保存された後にこの処理をする＝＝nilじゃなくなる今日の日付が入る）
        if UserDefaults.standard.string(forKey: today) != nil
        {
            //ボタンを押せなくする
            resultButton.isEnabled = false
            resultButton.setTitle("診断済み", for: .normal)
            resultButton.backgroundColor = .white
            resultButton.setTitleColor(.gray, for: .normal)
        }
    }
    
    //診断結果ボタンが押されたときの動作
    @objc func resultButtonAction()
    {
        //アラートのポップはUIAlertController。UIAlertController(title: "診断を完了しますか？", message: "診断は1日に1回までです", preferredStyle: .actionSheetで画面下部or.alertで画面中央)
        let alert = UIAlertController(title: "診断を完了しますか？", message: "診断は1日に1回までです", preferredStyle: .actionSheet)
        //ポップにつけるボタンはUIAlertAction。UIAlertAction(title: "完了", style: .defaultでyes用の青いボタン.destructiveで赤いボタン, handler: { action inで引数に関数を埋め込む ここの中にボタンを押した後の処理を書いていく。閉じるだけのキャンセルの処理はnilでOK})
        //yesActionをしたときの処理
        let yesAction = UIAlertAction(title: "完了", style: .default, handler: { action in
            var resultTitle = ""
            var resultMessage = ""
            //pointはグローバル変数のpoint最初に初期化している。クロージャの中(action in...の中)では、クロージャの外部にあるものを参照するときにselfが必要
            if self.point >= 4
            {
                resultTitle = "高"
                resultMessage = "感染している可能性が\n比較的高いです。\nPCR検査をしましょう。"
            }
            else if self.point >= 2
            {
                resultTitle = "中"
                resultMessage = "やや感染している可能性が\nあります。外出は控えましょう。"
            }
            else
            {
                resultTitle = "低"
                resultMessage = "感染している可能性は\n今のところ低いです。\n今後も気をつけましょう"
            }
            //アラートのポップ。完了を押した際に中央(.alert)に出てくる。
            let alert = UIAlertController(title: "感染している可能性「\(resultTitle)」", message: resultMessage, preferredStyle: .alert)
            //アラートを表示する処理present()
            self.present(alert, animated: true, completion: {
                //DispatchQueueはスレッドの切り替えや遅延処理などで使われる。2秒後にアラートを消す処理をしたいから必要
                DispatchQueue.main.asyncAfter(deadline: .now() + 2)
                {
                    //dismissは表示を消す処理
                    self.dismiss(animated: true, completion: nil)
                }
            })
            //診断結果をローカルに保存
            UserDefaults.standard.set(resultTitle, forKey: self.today)
        })
        let noAction = UIAlertAction(title: "キャンセル", style: .destructive, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        //アラートを表示する処理
        present(alert, animated: true, completion: nil)
    }
    
    //引数のUISwitch型はUISwitchのイベント情報を受け取る
    //on offの判断をしている
    @objc func switchAction(sender: UISwitch)
    {
        //UISwitch型のsenderのisOnプロパティ(フィールド)でONかどうかをtrueかfalseでうけとっている
        if sender.isOn
        {
            point += 1
        }
        else
        {
            point -= 1
        }
    }
    
    //Selector型とは関数名を受け取ることができる型
    //createView()の上にボタンスイッチを載せる
    func createUISwitch(parentView: UIView, action: Selector)
    {
        let uiSwitch = UISwitch()
        uiSwitch.frame = CGRect(x: parentView.frame.size.width-60, y: 20, width: 50, height: 30)
        //.addTarget(self, action: Selector型の関数名, for: どんなイベントを発火させるのか？→.valueChangedでon offの切り替えをする)
        uiSwitch.addTarget(self, action: action, for: .valueChanged)
        parentView.addSubview(uiSwitch)
    }
    
    //createView()の上に画像を載せる
    func createImage(parentView: UIView, imageName: String)
    {
        let imageView = UIImageView()
        //UIImageViewのimageプロパティ(フィールド)に代入して使う
        imageView.image = UIImage(named: imageName)
        imageView.frame = CGRect(x: 10, y: 12, width: 40, height: 40)
        parentView.addSubview(imageView)
    }
    
    //createView()の上にテキストラベルを載せる
    func createLabel(parentView: UIView, text: String)
    {
        let label = UILabel()
        label.text = text
        label.frame = CGRect(x: 60, y: 15, width: 200, height: 40)
        parentView.addSubview(label)
    }
    
    //健康診断チェックの下地部分
    func createView(y: CGFloat) -> UIView
    {
        let uiView = UIView()
        uiView.frame = CGRect(x: 20, y: y, width: view.frame.size.width-40, height: 70)
        uiView.backgroundColor = colors.whiteGray
        uiView.layer.cornerRadius = 20
        //shadowColorはCGColor型なので最後に.cgColorを追加している
        uiView.layer.shadowColor = UIColor.black.cgColor
        uiView.layer.shadowOpacity = 0.3
        //影のぼかしの強さ
        uiView.layer.shadowRadius = 4
        //widthが大きいと右にheightは下に影が伸びる
        uiView.layer.shadowOffset = CGSize(width: 0, height: 2)
        return uiView
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
extension HealthViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance
{
    //Delegateで紐づけた関数
    //日付（タイトル）の下に入るサブタイトル部分
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        //診断結果が存在すればresultに代入する
        if let result = UserDefaults.standard.string(forKey: dateFormatter(day: date))
        {
            return result
        }
        //なければ空文字を表示
        return ""
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleDefaultColorFor date: Date) -> UIColor? {
        return .init(red: 0, green: 0, blue: 0, alpha: 0.7)
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor?
    {
        return .clear
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor?
    {
        //Date()は表示すると2020-11-25 08:56:43 +0000のように出力される。一方でdateFormatter()は2020-11-25("yyyy-MM-dd")で表される。よって、==になり今日の日付のマスに処理を反映させることができる。→グローバル変数のtodayにdateFormatter(day: Date())を代入している。
        if dateFormatter(day: date) == today
        {
            return colors.blownGray
        }
        return  .clear
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date) -> CGFloat
    {
        return 0.5
    }
    //日付の色指定
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor?
    {
        //日曜==1か土曜==7かの判定
        if judgeWeekday(date) == 1
        {
            return UIColor(red: 150/255, green: 30/255, blue: 0/255, alpha: 0.9)
        }
        else if judgeWeekday(date) == 7
        {
            return UIColor(red: 0/255, green: 30/255, blue: 150/255, alpha: 0.9)
        }
        //祝日の判定
        if judgeHoliday(date)
        {
            return UIColor(red: 150/255, green: 30/255, blue: 0/255, alpha: 0.9)
        }
        return colors.black
    }
    
    //ロジックのための自作関数
    func dateFormatter(day: Date) -> String
    {
        //日付を取得
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: day)
    }
    //曜日判定(日曜日:1/土曜日:7)
    func judgeWeekday(_ date: Date) -> Int
    {
        //.gregorianはグレゴリオ暦のことで西暦の日付指定
        let calendar = Calendar(identifier: .gregorian)
        //Calendarのcomponent()メソッドは第一引数に「.year」「.month」「.weekday」「.day」を指定して第二引数のfromにData型の値を入れることで日曜日1~土曜日7の値を返してくれる→これで曜日を判定
        return calendar.component(.weekday, from: date)
    }
    func judgeHoliday(_ date: Date) -> Bool
    {
        let calendar = Calendar(identifier: .gregorian)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        //.judgeJapaneseHoliday(year: let year = calendar.component(.year, from: date), month: let month = calendar.component(.month, from: date), day: let day = calendar.component(.day, from: date))取ってきた値を代入している。結果はtrueかfalseなので最後に結果をreturnしている。
        let holiday = CalculateCalendarLogic()
        let judgeHoliday = holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
        return judgeHoliday
    }
}

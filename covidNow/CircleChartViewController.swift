//
//  ChartViewController.swift
//  covidNow
//
//  Created by 新久保龍之介 on 2022/02/15.
//

import UIKit
import Charts

class CircleChartViewController: UIViewController {

    //インスタンス化
    let colors = Colors()
    var prefecture = UILabel()
    var pcr = UILabel()
    var pcrCount = UILabel()
    var cases = UILabel()
    var casesCount = UILabel()
    var deaths = UILabel()
    var deathsCount = UILabel()
    var segment = UISegmentedControl()
    //変数arrayの型を扱うデータが都道府県なので[CovidInfo.Prefecture]にしている
    var array:[CovidInfo.Prefecture] = []
    //チャート表示のため宣言
    var chartView:HorizontalBarChartView!
    //最初の画面の感染者数も表している選択肢を保存するグローバル変数
    var pattern = "cases"
    var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //上部の四角い場所
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
//        //入れた色の分だけ均等にグラデーションがかかる。
//        gradientLayer.colors = [colors.blownGray.cgColor, colors.whiteGray.cgColor,]
//        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        //レイヤーを載せる場合viewには直接載せられない→addSubviewは使えない.insertSublayer(子, at: 階層)
//        view.layer.insertSublayer(gradientLayer, at: 0)
        
        //戻るボタンの実装
        //.systemを指定することでボタンとして簡易的な機能を持たせることができる
//        let backButton = UIButton(type: .system)
//        backButton.frame = CGRect(x: 10, y: 30, width: 100, height: 30)
//        backButton.setTitle("棒グラフ", for: .normal)
//        //ボタンの文字色または、アイコン色
//        backButton.tintColor = colors.darkGray
//        backButton.titleLabel?.font = .systemFont(ofSize: 20)
//        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
//        view.addSubview(backButton)
        
        //検索バーの上の選択ボタン
        self.title = "円グラフ"
        segment = UISegmentedControl(items: ["感染者数", "PCR数", "死者数"])
        segment.frame = CGRect(x: 10, y: 90, width: view.frame.size.width-20, height: 20)
        //デフォルトでどのセグメント状態にするのかを設定する
        segment.selectedSegmentIndex = 0
        //背景色
        segment.selectedSegmentTintColor = colors.blownGray
        //.setTitleTextAttributes( , for: どの状態の時に色が変わるのか設定する)　文字の色を変える
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: colors.darkGray], for: .normal)
        segment.addTarget(self, action: #selector(switchAction), for: .valueChanged)
        view.addSubview(segment)
        
        //検索バーを設置するにはUISearchBar（）を使う(グローバル変数へ変更)
        searchBar.frame = CGRect(x: 10, y: 120, width: view.frame.size.width-20, height: 20)
        searchBar.delegate = self
        //placeholderで薄い説明文を表示させる
        searchBar.placeholder = "都道府県を漢字で入力"
        searchBar.showsCancelButton = true
        searchBar.tintColor = colors.blownGray
        view.addSubview(searchBar)
        
        //viewの上に載せている県のview
        let uiView = UIView()
        uiView.frame = CGRect(x: 10, y: view.frame.size.height-190, width: view.frame.size.width-20, height: 167)
        uiView.layer.cornerRadius = 10
        uiView.backgroundColor = .white
        uiView.layer.shadowColor = colors.black.cgColor
        uiView.layer.shadowOffset = CGSize(width: 0, height: 2)
        uiView.layer.shadowOpacity = 0.4
        uiView.layer.shadowRadius = 10
        view.addSubview(uiView)
        
        //viewの上に載せているviewの上のラベル(県別のコロナ情報)
        bottomLabel(uiView, prefecture, 1, 10, text: "東京", size: 30, weight: .ultraLight, color: colors.black)
        bottomLabel(uiView, pcr, 0.39, 50, text: "PCR数", size: 15, weight: .bold, color: colors.darkGray)
        bottomLabel(uiView, pcrCount, 0.39, 85, text: "2222222", size: 30, weight: .bold, color: colors.blownGray)
        bottomLabel(uiView, cases, 1, 50, text: "感染者数", size: 15, weight: .bold, color: colors.darkGray)
        bottomLabel(uiView, casesCount, 1, 85, text: "22222", size: 30, weight: .bold, color: colors.blownGray)
        bottomLabel(uiView, deaths, 1.61, 50, text: "死者数", size: 15, weight: .bold, color: colors.darkGray)
        bottomLabel(uiView, deathsCount, 1.61, 85, text: "2222", size: 30, weight: .bold, color: colors.blownGray)
        
        //()県別のコロナ情報のデータ反映
        for i in 0..<CovidSingleton.shared.prefecture.count {
            if CovidSingleton.shared.prefecture[i].name_ja == "東京"
            {
                prefecture.text = "\(CovidSingleton.shared.prefecture[i].name_ja)"
                pcrCount.text = "\(CovidSingleton.shared.prefecture[i].pcr)"
                casesCount.text = "\(CovidSingleton.shared.prefecture[i].cases)"
                deathsCount.text = "\(CovidSingleton.shared.prefecture[i].deaths)"
            }
        }

        
        array = CovidSingleton.shared.prefecture
        //都道府県のデータを入れたarrayを昇順にソートしていく
        array.sort(by: {a, b -> Bool in
            if pattern == "pcr"
            {
                return a.pcr > b.pcr
            }
            else if pattern == "deaths"
            {
                return a.deaths > b.deaths
            }
            else
            {
                return a.cases > b.cases
            }
        })
        
        dataSet()

        view.backgroundColor = .systemGroupedBackground
    }
    
    //導入データ詳細セット
    func dataSet()
    {
        var entries: [PieChartDataEntry] = []
        //var set = BarChartDataSet(entries: entries, label:  "")
        if pattern == "cases"
        {
            segment.selectedSegmentIndex = 0
            for i in 0...4
            {
                //表示するための棒グラフのデータy軸PieChartDataEntry(value: Double(array[i].cases)数字, label: array[i].name_ja県名)
                entries += [PieChartDataEntry(value: Double(array[i].cases), label: array[i].name_ja)]
                //set = BarChartDataSet(entries: entries, label: "県別感染者")
            }
        }
        else if pattern == "pcr"
        {
            segment.selectedSegmentIndex = 1
            for i in 0...4
            {
                entries += [PieChartDataEntry(value: Double(array[i].pcr), label: array[i].name_ja)]
                //set = BarChartDataSet(entries: entries, label: "県別PCR数")
            }
        }
        else if pattern == "deaths"
        {
            segment.selectedSegmentIndex = 2
            for i in 0...4
            {
                entries += [PieChartDataEntry(value: Double(array[i].deaths), label: array[i].name_ja)]
                //set = BarChartDataSet(entries: entries, label: "県別死者数")
            }
        }
        //set.colors = [colors.blownGray]
        //set.valueTextColor = colors.darkGray
        //set.highlightColor = colors.whiteGray
        //最後に整形したデータ情報をチャートビューのデータに入れている
        //chartView.data = BarChartData(dataSet: set)
        //view.addSubview(chartView)
        
        let circleView = PieChartView(frame: CGRect(x: 0, y: 150, width: view.frame.size.width, height: view.frame.size.height-350))
        circleView.centerText = "Top5"
        //x軸の反映に2秒かけている
        circleView.animate(xAxisDuration: 2, easingOption: .easeOutExpo)
        let dataSet = PieChartDataSet(entries: entries)
        dataSet.colors = [
            colors.darkGray,colors.whiteGray,colors.pastelPink,colors.blownGray,colors.lightBlown
        ]
        dataSet.valueTextColor = colors.black
        //都道府県のテキストの色
        dataSet.entryLabelColor = colors.black
        //最後に整形したデータ情報をサークルビューのデータに入れている。流れ：entries += [PieChartDataEntry(value: Double(array[i].deaths), label: array[i].name_ja)]→let dataSet = PieChartDataSet(entries: entries)→circleView.data = PieChartData(dataSet: dataSet)
        circleView.data = PieChartData(dataSet: dataSet)
        view.addSubview(circleView)
    }
    
    //UISegmentedControlにすることで引数を受け取れる
    @objc func switchAction(sender: UISegmentedControl)
    {
        //segmentのインデックス番号を取得できる。どの選択肢を選んだのかグローバル変数patterに代入している
        switch sender.selectedSegmentIndex
        {
        case 0:
            pattern = "cases"
        case 1:
            pattern = "pcr"
        case 2:
            pattern = "deaths"
        default:
            break
        }
        //画面の更新にはloadView(),viewDidLoad()で表す。こうすることでライフサイクルが稼働し、再描画する。
        loadView()
        viewDidLoad()
    }
    
//    @objc func backButtonAction()
//    {
//        dismiss(animated: true, completion: nil)
//    }
//    @objc func goCircle()
//    {
//        print("tappedNextButton")
//    }
    
    func bottomLabel(_ parentView: UIView, _ label: UILabel, _ x: CGFloat, _ y: CGFloat, text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor)
    {
        label.text = text
        label.textColor = color
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: size, weight: weight)
        label.frame = CGRect(x: 0, y: y, width: parentView.frame.size.width/3.5, height: 50)
        label.center.x = view.center.x * x-10
        parentView.addSubview(label)
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
//MARK: UISearchBarDelegate
extension CircleChartViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        //編集モードを終了する自動で検索したらキーボードを閉じてくれる
        view.endEditing(true)
        //検索した文字列を合わせるために、whereでフィルタリング。$0は暗黙的に操作するデータの要素を表している。$1と一緒に使われることもあり、その時はもう一つの要素を表す。where: { $0.name_jaでarrayの要素(各都道府県の名前) == searchBar.text(検索バーに入力されたテキスト)}
        if let index = array.firstIndex(where: { $0.name_ja == searchBar.text})
        {
            prefecture.text = "\(array[index].name_ja)"
            pcrCount.text = "\(array[index].pcr)"
            casesCount.text = "\(array[index].cases)"
            deathsCount.text = "\(array[index].deaths)"
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //print("キャンセルボタンがタップ")
        view.endEditing(true)
        //検索をキャンセルしたら検索バーのラベルを空にする
        searchBar.text = ""
    }
}

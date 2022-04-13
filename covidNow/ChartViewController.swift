//
//  ChartViewController.swift
//  covidNow
//
//  Created by 新久保龍之介 on 2022/02/15.
//

import UIKit
import Charts

class ChartViewController: UIViewController {

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
    var goCircleButton: UIBarButtonItem!
    
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
//        //レイヤーを載せる場合viewには直接載せられない→addSubviewは使えない.insertSublayer(子, at: 階層)
//        view.layer.insertSublayer(gradientLayer, at: 0)
        
        //戻るボタンの実装
//        setUpImageButton("back", lx: 10, top: 0, w: 20, h: 20).addTarget(self, action: #selector(backButtonAction), for: .touchDown)
        self.title = "棒グラフ"
        
//        //円グラフへの遷移ボタン
//        setUpImageButton("text", lx: view.frame.size.width-100, top: 0, w: 100, h: 20).addTarget(self, action: #selector(goCircle), for: .touchDown)
        goCircleButton = UIBarButtonItem(title: "円グラフ", style: .plain, target: self, action: #selector(goCircle))
        navigationItem.rightBarButtonItem = goCircleButton
        
        //検索バーの上の選択ボタン
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
        
        //棒グラフの表示
        chartView = HorizontalBarChartView(frame: CGRect(x: 0, y: 160, width: view.frame.size.width, height: view.frame.size.height - 353))
        //yAxisDuration: は横方向に伸びるアニメーションで1秒かけて変化easingOption: はアニメーションの種類
        chartView.animate(yAxisDuration: 1.0, easingOption: .easeOutCirc)
        //x軸のラベルカウント数（横向きにしているので縦軸）
        chartView.xAxis.labelCount = 10
        chartView.xAxis.labelTextColor = colors.darkGray
        chartView.doubleTapToZoomEnabled = false
        chartView.delegate = self
        chartView.pinchZoomEnabled = false
        chartView.leftAxis.labelTextColor = colors.darkGray
        //x軸のグリッド線を消している
        chartView.xAxis.drawGridLinesEnabled = false
        //チャートの説明を消している　trueで表示
        chartView.legend.enabled = true
        //右側の軸を消している今回では下
        chartView.rightAxis.enabled = false
        
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
    
    //上部の戻るボタンと円グラフ遷移ボタン
//    func setUpImageButton(_ name: String, lx: CGFloat, top: CGFloat, w: CGFloat, h: CGFloat) -> UIButton
//    {
//        //戻るボタンと円グラフへ遷移するボタンの宣言
//        let topBackButton: UIBarButtonItem!
//        let goCircleButton: UIBarButtonItem!
//
//        if name == "text"
//        {
//
//            button.setTitleColor(colors.darkGray, for: .normal)
//            button.frame.size = CGSize(width: w, height: h)
//        }
//        else
//        {
//            //ボタンのアイコンを設定にはUIImageメソッドを使う。.setImage(UIImage(named: nameの引数を使うことでファイル名を呼び出し元で書く), for: ボタンの状態)normalで通常状態selectedで選択状態
//            button.setImage(UIImage(named: name), for: .normal)
//            //設定した画像の色を変える
//            button.tintColor = colors.darkGray
//        }
//        button.titleLabel?.adjustsFontSizeToFitWidth = true
//        button.translatesAutoresizingMaskIntoConstraints = false
//        //先に表示してAutoLayout指定
//        view.addSubview(button)
//        //AutoLayoutで指定
//        button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: top).isActive = true
//        button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: lx).isActive = true
//        button.widthAnchor.constraint(equalToConstant: w).isActive = true
//        button.heightAnchor.constraint(equalToConstant: h).isActive = true
//        return button
//    }
    //導入データ詳細セット
    func dataSet()
    {
        //各都道府県の名前データを保持する変数
        var names:[String] = []
        //都道府県名を北海道0から都道府県9まで合計10個の名前を入れる
        for i in 0...9
        {
            names += ["\(self.array[i].name_ja)"]
        }
        //都道府県10個の代入が終わったのでx軸(縦軸)に値を代入していく
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: names)
        //各都道府県のデータの値を保持する
        var entries:[BarChartDataEntry] = []
        //BarChartDataSet(entries: 配列のデータ, label: グラフのタイトル)
        var set = BarChartDataSet(entries: entries, label: "")
        for i in 0...9
        {
            if pattern == "cases"
            {
                segment.selectedSegmentIndex = 0
                //表示するための棒グラフのデータy軸BarChartDataEntry(x: インデックス番号, y: 感染者数)
                entries += [BarChartDataEntry(x: Double(i), y: Double(self.array[i].cases))]
                set = BarChartDataSet(entries: entries, label: "県別感染者")
            }
            else if pattern == "pcr"
            {
                segment.selectedSegmentIndex = 1
                entries += [BarChartDataEntry(x: Double(i), y: Double(self.array[i].pcr))]
                set = BarChartDataSet(entries: entries, label: "県別PCR数")
            }
            else if pattern == "deaths"
            {
                segment.selectedSegmentIndex = 2
                entries += [BarChartDataEntry(x: Double(i), y: Double(self.array[i].deaths))]
                set = BarChartDataSet(entries: entries, label: "県別死者数")
            }
        }
        set.colors = [colors.blownGray]
        set.valueTextColor = colors.darkGray
        set.highlightColor = colors.whiteGray
        //整形したデータ情報をチャートビューのデータに入れている
        chartView.data = BarChartData(dataSet: set)
        view.addSubview(chartView)
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
//        //トップ画面に戻る
//        dismiss(animated: true, completion: nil)
//    }
    @objc func goCircle()
    {
        //次の画面に遷移
        let nextVc = CircleChartViewController()
        self.navigationController?.pushViewController(nextVc, animated: true)
    }
    
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
extension ChartViewController: UISearchBarDelegate
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
//MARK: ChartViewDelegate
extension ChartViewController: ChartViewDelegate
{
    //データをタップした時に発火するのはchartValueSelected
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    {
        if let dataSet = chartView.data?.dataSets[highlight.dataSetIndex]
        {
            let index = dataSet.entryIndex(entry: entry)
            //上記のindexを使って各都道府県のデータが入っているarrayをviewの上に載っているlabelのprefecture.text、、、などに代入している
            prefecture.text = "\(array[index].name_ja)"
            pcrCount.text = "\(array[index].pcr)"
            casesCount.text = "\(array[index].cases)"
            deathsCount.text = "\(array[index].deaths)"
        }
    }
}

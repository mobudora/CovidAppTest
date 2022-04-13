//
//  API.swift
//  covidNow
//
//  Created by 新久保龍之介 on 2022/02/15.
//
//HTTPリクエストをこのファイルでは行なっている。情報をくださいとGETリクエストをおこなっている。
import Foundation
import UIKit
//Color.swiftファイルと同じでクレヨンのように取得するクレヨンを何個も入れることで管理しやすくする。
struct CovidAPI
{
    //staticがあると呼び出す時にCovidAPI().getTotalと記述しないといけないのに対してCovidAPI.getTotalのように呼び出すことができる→
    //インスタンス化はメモリを消費するのでメモリ消費を抑えられるかも？@escapingを使うことでcompletionに渡すデータを関数外でも保持されるようになる
    static func getTotal(completion: @escaping (CovidInfo.Total) -> Void)
    {
        let url = URL(string: "https://covid19-japan-web-api.now.sh/api/v1/total")
        //URLは実際にアクセスができるか保証されていないためオプショナル型→urlの後ろに!をつけてURLは実際にアクセスできるよ！(人間しか判断できない)強制アンラップしているアンラップは箱から取り出すことを言う
        let request = URLRequest(url: url!)
        URLSession.shared.dataTask(with: request)
        {
            //URLSessionの結果を受け取ったデータ→data,response,error
            (data, response, error) in
            //エラーがnilではない＝エラーの時にif内に入る
            if error != nil
            {
                print("error:\(error!.localizedDescription)")
            }
            //右辺がある場合に左辺に代入してif内の処理をする
            if let data = data
            {
                //受け取ったデータをこちらに使いやすいデータ形式に変換(デコード)している　受け取ったdataをCovidInfoのTotal型に変換　try!はエラーの可能性があるデータだがとりあえず実行してねというコード
                let result = try! JSONDecoder().decode(CovidInfo.Total.self, from: data)
                //上で変換したデータを呼び出し元の引数に渡す
                completion(result)
            }
        }.resume()
    }
    //completion: @escaping ([CovidInfo.Prefecture])が配列[]になっているのは47都道府県の複数あるデータを受け取るから。
    static func getPrefecture(completion: @escaping ([CovidInfo.Prefecture]) -> Void)
    {
        let url = URL(string: "https://covid19-japan-web-api.vercel.app/api/v1/prefectures")
        let request = URLRequest(url: url!)
        URLSession.shared.dataTask(with: request)
        {
            (data, response, error) in
            if let data = data {
                let result = try! JSONDecoder().decode([CovidInfo.Prefecture].self, from: data)
                completion(result)
            }
        }.resume()
    }
}

//
//  CovidSingleton.swift
//  covidNow
//
//  Created by 新久保龍之介 on 2022/02/15.
//

import Foundation
//シングルトン→破棄されたり初期化されたりすることなく値を保持し続ける。値を使い回すことができる。
class CovidSingleton
{
    //init(){}は初期化の処理だが、何も書かないことでクラスが初期化されるのを防ぐ
    private init() {}
    static let shared = CovidSingleton()
    var prefecture:[CovidInfo.Prefecture] = []
}

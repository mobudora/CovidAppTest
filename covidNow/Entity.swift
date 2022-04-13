//
//  Entity.swift
//  covidNow
//
//  Created by 新久保龍之介 on 2022/02/15.
//
//データを受け取り、使用したいデータだけを受け皿に抜き取るマッピングをこのファイルでは行なっている。
import Foundation
//Codableはデコードとエンコード機能を持った略称　変換しやすくするために使っている
struct CovidInfo: Codable
{
    struct Total: Codable
    {
        var pcr: Int
        var hospitalize: Int
        var positive: Int
        var severe: Int
        var death: Int
        var discharge: Int
    }
    struct Prefecture: Codable
    {
        var id :Int
        var name_ja: String
        var cases: Int
        var deaths: Int
        var pcr: Int
    }
}

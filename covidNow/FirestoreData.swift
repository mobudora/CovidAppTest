//
//  FirestoreData.swift
//  covidNow
//
//  Created by 新久保龍之介 on 2022/02/17.
//

import Foundation
import MessageKit

struct FirestoreData
{
    //型？で初期値を入れなくても大丈夫な形にする。？はオプショナル型でnilを許容してくれる。
    var date: Date?
    var senderID: String?
    var text: String?
    var userName: String?
}
//SenderTypeはpod installしたMessegeKitから提供されているプロトコル。送信者のIDと名前を持った構造体。MessageKitに従って実装する。
struct Sender: SenderType
{
    //宣言しなければいけない変数
    var senderId: String
    var displayName: String
}
//MessageTypeもプロトコル。
struct Message: MessageType
{
    //宣言しなければいけない変数
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    //MessageKindはenumというパターンでできている。送信するものがテキストなのか写真なのか動画なのかの種類を表す。
    var kind: MessageKind
    
    //private init関数はユーザーから投げられてくる写真や動画、位置情報、テキストメッセージなどを受け取りMessage構造体に橋渡している。
    private init(kind: MessageKind, sender: Sender, messadeId: String, date: Date)
    {
        self.kind = kind
        self.sender = sender
        self.messageId = messadeId
        self.sentDate = date
    }
    //String型のテキストメッセージを送信するパターンの処理。kind: MessageKindがkind: Stringの時。
    init(text: String, sender: Sender, messadeId: String, date: Date)
    {
        self.init(kind: .text(text), sender: sender, messadeId: messadeId, date: date)
    }
    //NSAttributedString型はStringでは困難な装飾などができる→文字の感覚など
    init(attributedText: NSAttributedString, sender: Sender, messadeId: String, date: Date)
    {
        self.init(kind: .attributedText(attributedText), sender: sender, messadeId: messadeId, date: date)
    }
}

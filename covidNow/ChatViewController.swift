//
//  ChatViewController.swift
//  covidNow
//
//  Created by 新久保龍之介 on 2022/02/16.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ChatViewController: MessagesViewController, MessagesDataSource, MessageCellDelegate, MessagesLayoutDelegate,MessagesDisplayDelegate
{
    let colors = Colors()
    //UUIDを代入するための変数
    private var userId = ""
    //FirestoreData.swiftファイルにFirestoreから受け取る日付、名前、メッセージ、固有アイディー保存するためのデータ型を作ったので、そのデータたちを型に持つ空の配列を宣言。これでいつでもデータを代入できる。
    private var firestoreData:[FirestoreData] = []
    //メッセージデータを保存するためのmessages変数を宣言。Message構造体を型に持った配列。
    private var messages: [Message] = []
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //UUID取得　オプショナル型なのでif letで取得できた場合のみ代入できるようにする
        if let uuid = UIDevice.current.identifierForVendor?.uuidString
        {
            userId = uuid
            print(userId)
        }
        //document()と空にすると自動でIDを振ってくれる。
        Firestore.firestore().collection("Messages").document().setData([
            "date": Date(),
            "senderId": "testId",
            "text": "testText",
            "userName": "testName"
        ])
        //Messageコレクションのドキュメントをすべて取得している
        Firestore.firestore().collection("Messages").getDocuments(completion: {
            (document, error) in
            if error != nil{
                //#lineはそのコードが書かれている行数を出力してくれる。デバック時に便利
                print("ChartViewController:Line(\(#line)):error:\(error!)")
            }
            else
            {
                //データにエラーがない場合定数ドキュメントに代入
                if let document = document
                {
                    for i in 0..<document.count
                    {
                        //document.documents[i]で何番目のドキュメントなのか。.get("date")!で指定したデータを受け取る。as! String　as! TimestampはData型で("data": Date())保存してもTimestamp型やString型で帰ってくるので、これは〇〇型で帰ってくるよ！と明示をFirestoreではしなければいけない。
                        //確認用のプリント文。本番はデータを格納する
                        /*print((document.documents[i].get("data")! as! Timestamp).seconds)
                        print(document.documents[i].get("senderId")! as! String)
                        print(document.documents[i].get("text")! as! String)
                        print(document.documents[i].get("userName")! as! String)*/
                        //FirestoreData.swiftファイルへデータを格納するデータたちを読み取る。一時保存用の変数
                        var storeData = FirestoreData()
                        storeData.date = (document.documents[i].get("date")! as! Timestamp).dateValue()
                        storeData.senderID = document.documents[i].get("senderId")! as? String
                        storeData.text = document.documents[i].get("text")! as? String
                        storeData.userName = document.documents[i].get("userName")! as? String
                        //グローバル変数のfirestoreDataに格納。配列に値を格納する時は.append(値)を使う
                        self.firestoreData.append(storeData)
                    }
                }
                self.messages = self.getMessages()
                //messagesCollectionViewはMessageKitから提供されているものでメッセージの描画担当
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
            }
        })
        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        //親クラスのMessagesViewControllerクラスはデフォルトで画面いっぱいに広がっているようになっているので空白をつけることでヘッダー部分になる
        messagesCollectionView.contentInset.top = 70
        
        //上部のナビゲーションバー
        title = "Doctor"
        
//        let uiView = UIView()
//        uiView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
//        view.addSubview(uiView)
//
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 20, weight: .bold)
//        label.textColor = colors.darkGray
//        label.text = "Doctor"
//        label.frame = CGRect(x: 0, y: 20, width: 100, height: 40)
//        label.center.x = view.center.x
//        label.textAlignment = .center
//        uiView.addSubview(label)
//
//        let backButton = UIButton(type: .system)
//        backButton.frame = CGRect(x: 10, y: 30, width: 20, height: 20)
//        backButton.setImage(UIImage(named: "back"), for: .normal)
//        backButton.tintColor = colors.darkGray
//        backButton.titleLabel?.font = .systemFont(ofSize: 20)
//        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
//        uiView.addSubview(backButton)
//
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
//        gradientLayer.colors = [colors.blownGray.cgColor, colors.whiteGray.cgColor,]
//        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
//        uiView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
//    @objc func backButtonAction()
//    {
//        dismiss(animated: true, completion: nil)
//    }
}
extension ChatViewController: InputBarAccessoryViewDelegate
{
    func currentSender() -> SenderType
    {
        return Sender(senderId: userId, displayName: "MyName")
    }
    func otherSender() -> SenderType
    {
        return Sender(senderId: "-1", displayName: "OtherName")
    }
    //メッセージを表示する関数。messages配列に保存されているデータにindexPath.sectionで1つずつアクセスしている。
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType
    {
        return messages[indexPath.section]
    }
    //メッセージの個数を返す関数
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int
    {
        return messages.count
    }
    //firestoreDataからMessageに変換する関数。型をMessageKitでのメッセージ表示に使えるようにする。firestoreDataのtext,date,senderIdを引数で受け取り中で変換している。
    func createMessage(text: String, date: Date, _ senderId: String) -> Message
    {
        let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
        //エルビス演算子「条件　？　A:B」条件がtrueならA。falseならB。自分か自分以外が送信したメッセージなのか判別。
        let sender = (senderId == userId) ? currentSender() : otherSender()
        return Message(attributedText: attributedText, sender: sender as! Sender, messadeId: UUID().uuidString, date: date)
    }
    //messagesにメッセージを代入するためにデータを整頓する関数
    func getMessages() -> [Message]
    {
        var messageArray: [Message] = []
        for i in 0..<firestoreData.count
        {
            //createMessageでfirestoreDataからMessage型に変換して追加(append)をmessageArray
            messageArray.append(createMessage(text: firestoreData[i].text!, date: firestoreData[i].date!, firestoreData[i].senderID!))
        }
        //メッセージを日付順に並び替える
        messageArray.sort(by:
        {
            //配列から要素が二つ渡される。
            a, b -> Bool in
            return a.sentDate < b.sentDate
        })
        return messageArray
    }
    //MARK: MessagesDisplayDelegate
    //MessagesDisplayDelegateのbackgroundColor()は描画の際に発火する関数
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor
    {
        //MessagesDataSOURCEから提供されているisFromCurrentSender(messages:)で自分のものか相手のものか判別してくれる。自分のメッセージならA。相手ならB。
        return isFromCurrentSender(message: message) ? colors.blownGray : colors.pastelPink
    }
    //メッセージ下部に日付を表示する関数
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat
    {
        //初期値ではメッセージの高さが0の高さになっているから16上げて、日付を表示させる。
        return 16
    }
    //メッセージ下部に文字を表示する関数
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString?
    {
        //標準が2022-2-20 22:54:53 +0000なのでデザインをいじっていく。
        let formatter = DateFormatter()
        //22/2/20のようになる
        formatter.dateStyle = .short
        //22:54 PMのようになる
        formatter.timeStyle = .short
        //String型の日付文字列にする。
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    //メッセージアイコン設定関数
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar: Avatar
        avatar = Avatar(image: UIImage(named: isFromCurrentSender(message: message) ? "user": "doctor"))
        avatarView.set(avatar: avatar)
    }
    //メッセージを送信した時に発火する関数inputBar
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String)
    {
        //inputBar.inputTextView.componentsで入力情報にアクセスする。for 定数　in　複数要素とすることで複数要素から1つずつ取り出して定数に代入される。
        for component in inputBar.inputTextView.components
        {
            //右辺がtrueの時のみ定数に代入される。つまり、文字が入力(String型)されたときにだけこの処理をする。
            if let text = component as? String
            {
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
                //MessageKitで表示ができるようにmessageインスタンスを作っている。
                let message = Message(attributedText: attributedText, sender: currentSender() as! Sender, messadeId: UUID().uuidString, date: Date())
                messages.append(message)
                //最新のメッセージなので一番下にセクション番号を指定。順番の設定。
                messagesCollectionView.insertSections([messages.count - 1])
                sendToFirestore(message: text)
            }
        }
        //メッセージの表示処理が終わり次第、入力欄が空になるようになる処理
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToLastItem()
    }
    
    func sendToFirestore(message: String)
    {
        Firestore.firestore().collection("Messages").document().setData([
            "date": Date(),
            "senderId": userId,
            "text": message,
            "userName": userId
            //FirestoreのMessagesコレクションにマージできなかった場合、errが返る。
        ],merge: false)
        {
            err in
            if let err = err
            {
                print("Error writing document: \(err)")
            }
        }
    }
}

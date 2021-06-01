//
//  ViewController.swift
//  WorkBGMClock
//
//  Created by 柴英嗣 on 2021/04/28.
//

import UIKit
import Cartography
import AVFoundation
import MarqueeLabel
import Alamofire
import SwiftyJSON

class ViewController: UIViewController,XMLParserDelegate, UITextFieldDelegate, UIAdaptivePresentationControllerDelegate {
    
    var marqueeLabel = MarqueeLabel()
    var PrefectureArray : [String : String] = ["北海道" : "hokkaido","青森県" : "aomori","岩手県" : "iwate" ,"宮城県" : "miyagi","秋田県" :"akita","山形県" : "yamagata","福島県":"fukushima","茨城県":"ibaraki","栃木県":"tochigi","群馬県":"gunma","埼玉県":"saitama","千葉県":"chiba","東京都":"tokyo","神奈川県":"kanagawa","新潟県":"niigata","富山県":"toyama","石川県":"ishikawa","福井県":"fukui","山梨県":"yamanashi","長野県":"nagano","岐阜県":"gifu","静岡県":"shizuoka","愛知県":"aichi","三重県":"mie","滋賀県":"shiga","京都府":"kyoto","大阪府":"osaka","兵庫県":"hyogo","奈良県":"nara","和歌山県":"wakayama","鳥取県":"tottori","島根県":"shimane","岡山県":"okayama","広島県":"hiroshima","山口県":"yamaguchi","徳島県":"tokushima","香川県":"kagawa","愛媛県":"ehime","高知県":"kochi","福岡県":"fukuoka","佐賀県":"saga","長崎県":"nagasaki","熊本県":"kumamoto","大分県":"oita","宮崎県":"miyazaki","鹿児島県":"kagoshima","沖縄県":"okinawa"]

    let HourLabel = UILabel()
    let MinuteLabel = UILabel()
    let SecondLabel = UILabel()
    
    let YearLabel = UILabel()
    let MonthLabel = UILabel()
    let DayLabel = UILabel()
    
    let fontsize : CGFloat = 80
    let minifontsize : CGFloat = 24
    let textcolor = "#444444"
    var firstLabel = UILabel()
    
    var check_title = [String]()
    var news_title = [String]()
    var link = [String]()
    var enclosure = [String]()
    var check_element = String()
    var labelBatteryStatus = UILabel()
    
    var select_link = String()
    
    let WeatherLabel = UILabel()
    
    var imageViewBackground = UIImageView()
    var juudenimage = UIImageView()
    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for title in self.news_title {
            marqueeLabel.text = marqueeLabel.text ?? "" + title + ""
        }
        print(self.news_title.count)
    }
    func juuden(){
        let bLevel:Float = UIDevice.current.batteryLevel
                   
        if(bLevel == -1){
            labelBatteryStatus.text = "不明"
        }
        else{
            labelBatteryStatus.text = "\(Int(bLevel * 100)) %"
        }
               
        if UIDevice.current.batteryState == UIDevice.BatteryState.charging {
            juudenimage.image = UIImage(named:"juuden")!
        }
        else{
            juudenimage.image = UIImage(named:"nojuuden")!
        }
        
               
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        
        juudenimage.image = UIImage(named:"juuden")!
        self.view.addSubview(juudenimage)
        constrain(juudenimage) { image  in
            image.width  == 32
            image.height == 15
            image.right == image.superview!.right - 30
            image.bottom == image.superview!.bottom - 20
        }
        juuden()
        labelBatteryStatus.font = UIFont.systemFont(ofSize: 13)
        labelBatteryStatus.textAlignment = .center
        labelBatteryStatus.numberOfLines = 0
        labelBatteryStatus.textColor = UIColor.hex(string: textcolor, alpha: 1.0)
        self.view.addSubview(labelBatteryStatus)
        constrain(labelBatteryStatus, juudenimage) { i, last in
            i.right == last.left - 6
            i.centerY == last.centerY
            i.width >= 0
            i.height >= 0
        }
        
        load()

        if UserDefaults.standard.data(forKey: "backimage") != nil{
            imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            imageViewBackground.image = UserDefaults.standard.image(forKey: "backimage")
            imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
            imageViewBackground.alpha = 0.35
            self.view.addSubview(imageViewBackground)
        }
        else{
            imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            imageViewBackground.image = UIImage(named: "default")
            imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
            imageViewBackground.alpha = 0.35
            self.view.addSubview(imageViewBackground)
        }
        
        MinuteLabel.font = UIFont.systemFont(ofSize: fontsize)
        MinuteLabel.textAlignment = .center
        MinuteLabel.numberOfLines = 0
        MinuteLabel.textColor = UIColor.hex(string: textcolor, alpha: 1.0)
        self.view.addSubview(MinuteLabel)
        constrain(MinuteLabel, self.view) { i, view in
            i.center == i.superview!.center
            i.width >= 0
            i.height >= 0
        }
        
        
        let colon = UILabel()
        colon.text = ":"
        colon.font = UIFont.systemFont(ofSize: fontsize)
        colon.textAlignment = .center
        colon.numberOfLines = 0
        colon.textColor = UIColor.hex(string: textcolor, alpha: 1.0)
        self.view.addSubview(colon)
        constrain(colon, MinuteLabel) { i, last in
            i.centerY == last.centerY
            i.right == last.left - 30
            i.width >= 0
            i.height >= 0
        }
        
        
        HourLabel.font = UIFont.systemFont(ofSize: fontsize)
        HourLabel.textAlignment = .center
        HourLabel.numberOfLines = 0
        HourLabel.textColor = UIColor.hex(string: textcolor, alpha: 1.0)
        self.view.addSubview(HourLabel)
        constrain(HourLabel, colon) { i, last in
            i.centerY == i.superview!.centerY
            i.right == last.left - 30
            i.width >= 0
            i.height >= 0
        }
        
        
        let colon1 = UILabel()
        colon1.text = ":"
        colon1.font = UIFont.systemFont(ofSize: fontsize)
        colon1.textAlignment = .center
        colon1.numberOfLines = 0
        colon1.textColor = UIColor.hex(string: textcolor, alpha: 1.0)
        self.view.addSubview(colon1)
        constrain(colon1, MinuteLabel) { i, last in
            i.centerY == last.centerY
            i.left == last.right + 30
            i.width >= 0
            i.height >= 0
        }
        
        
        SecondLabel.font = UIFont.systemFont(ofSize: fontsize)
        SecondLabel.textAlignment = .center
        SecondLabel.numberOfLines = 0
        SecondLabel.textColor = UIColor.hex(string: textcolor, alpha: 1.0)
        self.view.addSubview(SecondLabel)
        constrain(SecondLabel, colon1) { i, last in
            i.centerY == i.superview!.centerY
            i.left == last.right + 30
            i.width >= 0
            i.height >= 0
        }
        
        tenki(prefecture: PrefectureArray[UserDefaults.standard.string(forKey: "area") ?? "東京都"] ?? "tokyo")
        WeatherLabel.font = UIFont.systemFont(ofSize: 20)
        WeatherLabel.textAlignment = .center
        WeatherLabel.numberOfLines = 0
        WeatherLabel.textColor = UIColor.hex(string: textcolor, alpha: 1.0)
        self.view.addSubview(WeatherLabel)
        constrain(WeatherLabel, MinuteLabel) { i, last in
            i.centerX == i.superview!.centerX
            i.top == last.bottom + 20
            i.width >= 0
            i.height >= 0
        }
        
        MonthLabel.font = UIFont.systemFont(ofSize: minifontsize)
        MonthLabel.textAlignment = .center
        MonthLabel.numberOfLines = 0
        MonthLabel.textColor = UIColor.hex(string: textcolor, alpha: 1.0)
        self.view.addSubview(MonthLabel)
        constrain(MonthLabel, MinuteLabel) { i, last in
            i.centerX == i.superview!.centerX
            i.bottom == last.top - 20
            i.width >= 0
            i.height >= 0
        }
        let surassyu = UILabel()
        surassyu.text = "/"
        surassyu.font = UIFont.systemFont(ofSize: 18)
        surassyu.textAlignment = .center
        surassyu.numberOfLines = 0
        surassyu.textColor = UIColor.hex(string: textcolor, alpha: 1.0)
        self.view.addSubview(surassyu)
        constrain(surassyu, MonthLabel) { i, last in
            i.centerY == last.centerY
            i.right == last.left - 16
            i.width >= 0
            i.height >= 0
        }
        YearLabel.font = UIFont.systemFont(ofSize: minifontsize)
        YearLabel.textAlignment = .center
        YearLabel.numberOfLines = 0
        YearLabel.textColor = UIColor.hex(string: textcolor, alpha: 1.0)
        self.view.addSubview(YearLabel)
        constrain(YearLabel, surassyu) { i, last in
            i.centerY == last.centerY
            i.right == last.left - 16
            i.width >= 0
            i.height >= 0
        }
        let surassyu1 = UILabel()
        surassyu1.text = "/"
        surassyu1.font = UIFont.systemFont(ofSize: 18)
        surassyu1.textAlignment = .center
        surassyu1.numberOfLines = 0
        surassyu1.textColor = UIColor.hex(string: textcolor, alpha: 1.0)
        self.view.addSubview(surassyu1)
        constrain(surassyu1, MonthLabel) { i, last in
            i.centerY == last.centerY
            i.left == last.right + 16
            i.width >= 0
            i.height >= 0
        }
        DayLabel.font = UIFont.systemFont(ofSize: minifontsize)
        DayLabel.textAlignment = .center
        DayLabel.numberOfLines = 0
        DayLabel.textColor = UIColor.hex(string: textcolor, alpha: 1.0)
        self.view.addSubview(DayLabel)
        constrain(DayLabel, surassyu1) { i, last in
            i.centerY == last.centerY
            i.left == last.right + 16
            i.width >= 0
            i.height >= 0
        }
        
        let image0:UIImage = UIImage(named:"setting")!
        let cameraimage1 = UIImageView(image:image0)
        self.view.addSubview(cameraimage1)
        cameraimage1.isUserInteractionEnabled = true
        cameraimage1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(opensetting)))
        constrain(cameraimage1, colon1) { i, last in
            i.bottom == i.superview!.bottom - 35
            i.centerX == i.superview!.centerX
            i.width == 30
            i.height == 30
        }
        
        let image1:UIImage = UIImage(named:"camera")!
        let cameraimage2 = UIImageView(image:image1)
        self.view.addSubview(cameraimage2)
        cameraimage2.isUserInteractionEnabled = true
        cameraimage2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(camera)))
        constrain(cameraimage2, cameraimage1) { i, last in
            i.bottom == i.superview!.bottom - 35
            i.right == last.left - 40
            i.width == 30
            i.height == 30
        }
        
        let image2:UIImage = UIImage(named:"delete")!
        let cameraimage3 = UIImageView(image:image2)
        self.view.addSubview(cameraimage3)
        cameraimage3.isUserInteractionEnabled = true
        cameraimage3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deletecamera)))
        constrain(cameraimage3, cameraimage1) { i, last in
            i.bottom == i.superview!.bottom - 35
            i.left == last.right + 40
            i.width == 30
            i.height == 30
        }
        

        
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    func ShowAlert(_ text : String){
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func opensetting() {
        let vc = FormView()
        vc.presentationController?.delegate = self
        vc.title = "設定"
            vc.navigationItem.rightBarButtonItem = {
                let btn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.onPressClose(_:)))
                return btn
            }()
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    @objc func onPressClose(_ sender : Any){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func setting() {
        print("a")
        let ac = UIAlertController(title: "ニュース設定", message: "表示させたいニュースのキーワードを入力設定してください", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {[weak ac] (action) -> Void in
            guard let textFields = ac?.textFields else {
                return
            }

            guard !textFields.isEmpty else {
                return
            }

            for text in textFields {
                if text.tag == 1 {
                    
                    if textFields.isEmpty == true || text.text == ""{
                        self.ShowAlert("正しい文字を入力してください")
                    }
                    else{
                        UserDefaults.standard.set(text.text, forKey: "keyword")
                        self.load()
                        self.ShowAlert("キーワードを設定しました")
                    }
                } else {
                }
            }
            
            

        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        //textfiled1の追加
        ac.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.text = UserDefaults.standard.string(forKey: "keyword") ?? ""
            text.tag  = 1
        })

        ac.addAction(ok)
        ac.addAction(cancel)

        present(ac, animated: true, completion: nil)

            
    }

    @objc func camera() {
        print("aa")
        
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 写真を選ぶビュー
            let pickerView = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerView.sourceType = .photoLibrary
            // デリゲート
            pickerView.delegate = self
            // ビューに表示
            self.present(pickerView, animated: true)
        }
        
        
    }
    var audioPlayer : AVAudioPlayer!

    @objc func deletecamera() {
        print("aaa")
        showAlert()
        
    }

    @objc func updateTime() {
        juuden()
        // 時刻を取得してラベルに表示
        let date = Date()
        let calendar = Calendar.current

        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        self.YearLabel.text = String(year)
        self.MonthLabel.text = String(month)
        self.DayLabel.text = String(day)
        
        if month < 10 {
            self.MonthLabel.text = "0" + String(month)
        }
        else{
            self.MonthLabel.text = String(month)
        }
        if day < 10 {
            self.DayLabel.text = "0" + String(day)
        }
        else{
            self.DayLabel.text = String(day)
        }
        if hour < 10 {
            self.HourLabel.text = "0" + String(hour)
        }
        else{
            self.HourLabel.text = String(hour)
        }
        if minutes < 10 {
            self.MinuteLabel.text = "0" + String(minutes)
        }
        else{
            self.MinuteLabel.text = String(minutes)
        }
        if seconds < 10 {
            self.SecondLabel.text = "0" + String(seconds)
        }
        else{
            self.SecondLabel.text = String(seconds)
        }
        
    }
    func load(){
        self.news_title = []
        var itemString = "勉強"
        if let key = UserDefaults.standard.string(forKey: "keyword"){
            itemString = key
        }
        let itemEncodeString = itemString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        let url: URL = URL(string:"https://news.google.com/rss/search?q=\(itemEncodeString!)&hl=ja&gl=JP&ceid=JP:ja")!

        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            let parser: XMLParser? = XMLParser(data: data!)
            parser!.delegate = self
            parser!.parse()
        })
        //タスク開始
        task.resume()
    }
    
    //解析_開始時
    func parserDidStartDocument(_ parser: XMLParser) {
        
    }
    
    //解析_要素の開始時
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "enclosure" {
            print(attributeDict["url"]!)
            enclosure.append(attributeDict["url"]!)
        }
        check_element = elementName

    }
    
    //解析_要素内の値取得
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if string != "\n" {
            if check_element == "title" {
                check_title.append(string)
                print("開始要素:" + string)
            }

            if check_element == "link" {
                link.append(string)
                print("開始要素:" + string)
            }
        }
    }
    
    //解析_要素の終了時
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if check_element == "title" {
            var title = check_title[0]
            for i in 1..<check_title.count {
                title = title + check_title[i]
            }
            check_title = [String]()
            news_title.append(title)
        }
    }
    
    //解析_終了時
    func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.sync {
            self.marqueeLabel.text = nil
            if self.news_title.count != 0 {
                self.news_title.removeFirst()
            }
            self.news_title.shuffle()
            var t = ""
            for title in self.news_title {
                t = t + title + "  /  "
            }
            print(t.count)
            marqueeLabel.text = t
            print(marqueeLabel.text?.count)
            marqueeLabel.type = .continuous
            marqueeLabel.backgroundColor = UIColor.hex(string: "#eeeeee", alpha: 0.2)
            marqueeLabel.speed = .rate(30)
            marqueeLabel.textAlignment = .right
            marqueeLabel.fadeLength = 100.0
            marqueeLabel.leadingBuffer = 50.0
            marqueeLabel.trailingBuffer = 50.0
            self.view.addSubview(marqueeLabel)
            constrain(marqueeLabel, self.view) { i, view in
                i.top == i.superview!.top
                i.left == i.superview!.left
                i.width == view.width
                i.height >= 40
            }
        }
    }
    
    //解析_エラー発生時
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("エラー:" + parseError.localizedDescription)
    }
    func showAlert() {
        let alert = UIAlertController(title: "確認",
                                      message: "背景の画像を削除してもいいですか？",
                                      preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler:{(action: UIAlertAction) -> Void in
                                        // デフォルトの画像を表示する
                                        self.imageViewBackground.image = UIImage(named: "default")
                                        UserDefaults.standard.setUIImageToData(image: UIImage(named: "default")!, forKey: "backimage")
                                        self.ShowAlert("削除が完了しました")
        })
        let cancelButton = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        // アラートにボタン追加
        alert.addAction(okButton)
        alert.addAction(cancelButton)

        // アラート表示
        present(alert, animated: true, completion: nil)
    }
    var descriptionWeather: String?
    var DescriptionTenkiJapanese : String?
    var ondo : String?
    func tenki(prefecture:String){
        let text = "https://api.openweathermap.org/data/2.5/weather?q=\(prefecture)&APPID=71534f55ae6ed652407203d32969bcff"
        print(text)
        let url = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success:

                let json = JSON(response.data as Any)

                self.descriptionWeather = json["weather"][0]["main"].string!

                if self.descriptionWeather == "Clouds" {
                    self.DescriptionTenkiJapanese = "曇り"
                }else if self.descriptionWeather == "Rain" {
                    self.DescriptionTenkiJapanese = "雨"
                }else if self.descriptionWeather == "Snow"{
                    self.DescriptionTenkiJapanese = "雪"
                }else {
                    self.DescriptionTenkiJapanese = "晴れ"
                }
                let maxondo = Int(Int(json["main"]["temp_max"].number!) - 273).description
                let minondo = Int(Int(json["main"]["temp_min"].number!) - 273).description
                self.ondo = "\(maxondo)℃ / \(minondo)℃"
                let pref = UserDefaults.standard.string(forKey: "area") ?? "東京都"
                self.WeatherLabel.text = "\(pref)の天気：\(self.DescriptionTenkiJapanese!)：\(self.ondo!)"
            case .failure(let error):
                print(error)
            }
            
        }
    }
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {

        
        self.load()
        tenki(prefecture: PrefectureArray[UserDefaults.standard.string(forKey: "area") ?? "東京都"] ?? "tokyo")
        ShowAlert("設定完了")
        
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 写真を選んだ後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 選択した写真を取得する
        let image = info[.originalImage] as! UIImage
        
        UserDefaults.standard.setUIImageToData(image: image, forKey: "backimage")
        // ビューに表示する
        imageViewBackground.image = image
        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
    }
}
extension UIColor {
    class func hex ( string : String, alpha : CGFloat) -> UIColor {
        let string_ = string.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: string_ as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            return UIColor.white;
        }
    }
}
extension UserDefaults {
    // 保存したいUIImage, 保存するUserDefaults, Keyを取得
    func setUIImageToData(image: UIImage, forKey: String) {
        // UIImageをData型へ変換
        let nsdata = image.pngData()
        print(forKey)
        // UserDefaultsへ保存
        self.set(nsdata, forKey: forKey)
    }
    // 参照するUserDefaults, Keyを取得, UIImageを返す
    func image(forKey: String) -> UIImage {
        // UserDefaultsからKeyを基にData型を参照
        let data = (self.data(forKey: forKey))
        // UIImage型へ変換
        let returnImage = UIImage(data: data!)
        // UIImageを返す
        return returnImage!
    }

}
extension Array {

    mutating func shuffle() {
        for i in 0..<self.count {
            let j = Int(arc4random_uniform(UInt32(self.indices.last!)))
            if i != j {
                self.swapAt(i, j)
            }
        }
    }

    var shuffled: Array {
        var copied = Array<Element>(self)
        copied.shuffle()
        return copied
    }
}

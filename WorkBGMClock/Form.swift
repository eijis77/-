//
//  FormView.swift
//  LifeHourglass
//
//  Created by 柴英嗣 on 2021/04/25.
//

import Foundation
import UIKit
import Eureka
import Cartography
import SCLAlertView

class FormView : FormViewController {
    
    var area : String = UserDefaults.standard.string(forKey: "area") ?? ""
    var Birth : Date?
    var backimage : String = ""
    var keyword : String = UserDefaults.standard.string(forKey: "keyword") ?? ""
    
    func ShowAlert(_ text : String){
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        form
        +++ Section("表示させたいニュースのキーワードを入力")
        <<< TextRow { row in
                row.title = "キーワード"
                row.placeholder = "キーワードを入力"
            row.value = self.keyword
            }.onChange{ row in
                self.keyword = row.value ?? ""
        }
        +++ Section("天気予報の地域を選択")
            <<< PushRow<String>(){
                $0.title = "地域名"
                $0.options = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
                $0.value = self.area
                $0.selectorTitle = "地域名"
                self.area = $0.value ?? ""
            }.onPresent{ from, to in
                to.dismissOnSelection = true
                to.dismissOnChange = false
            }.onChange({ [unowned self] row in
                self.area = row.value ?? ""
            })
        +++ Section("各都道府県の天気はOpenWeatherMapのデータを参照しています。")
            <<< ButtonRow("Button1") {row in
                    row.title = "登録"
                    row.onCellSelection{[unowned self] ButtonCellOf, row in
                        
                        if self.area == "" || self.area == nil || self.keyword == "" || self.keyword == nil {
                            ShowAlert("正しい情報を設定してください")
                        }
                        else{
                        
                            let userDefaults = UserDefaults.standard
                            // 配列の保存
                            userDefaults.set(self.keyword, forKey: "keyword")
                            userDefaults.set(self.area, forKey: "area")
                            
                            
                            let alertController = UIAlertController(title: "完了", message: "設定の登録が完了しました", preferredStyle: UIAlertController.Style.alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                            alertController.addAction(okAction)
                            present(alertController, animated: true, completion: nil)
                        
                        }
                        
                    }
            }
    }
}
extension FormView {
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else {
            return
        }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}


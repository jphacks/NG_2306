//
//  ViewController.swift
//  AlarmText2
//
//  Created by 小西貴洋 on 2023/10/28.
//

import UIKit

class SetViewController: UIViewController {

    @IBOutlet weak var Picker: UIDatePicker!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var mytimer : Timer!
    
    var resultHandler: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        TimeLabel.font = TimeLabel.font.withSize(60.0) // 20ポイントのフォントサイズに変更
        TimeLabel.textAlignment = NSTextAlignment.center
        // ボタンの横幅に応じてフォントサイズを自動調整する設定
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        //Picker("", selection: $date).colorInvert().colorMultiply(UIColor(white: <#T##CGFloat#>, alpha: <#T##CGFloat#>))
        Picker.setValue(UIColor.white, forKeyPath: "textColor")

        
        timecheck()
        mytimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timecheck), userInfo: nil, repeats: true)
    }
    
    @objc func timecheck(){
        
        let date:Date = Date()
        //日付のフォーマットを指定する。
        let format = DateFormatter()
        format.dateFormat = "HH:mm:ss"
        //日付をStringに変換する
        let sDate = format.string(from: date)
        
        TimeLabel.text = sDate
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func ReturnMain(_ sender: Any) {
        let setTime = Picker.date
        print(setTime)
        
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        //日付をStringに変換する
        let text = format.string(from: setTime)

        // 用意したクロージャに関数がセットされているか確認する
        if let handler = self.resultHandler {
            // 入力値を引数として渡された処理の実行
            handler(text)
        }
        
        self.dismiss(animated: true, completion: nil)//前の画面に戻る
    }
    
}


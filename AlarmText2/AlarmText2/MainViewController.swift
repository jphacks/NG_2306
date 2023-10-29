//
//  MainViewController.swift
//  AlarmText2
//
//  Created by 小西貴洋 on 2023/10/28.
//

import Foundation
import UIKit
import UserNotifications
import EventKit
import AVFoundation

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    //
    var audioPlayer: AVAudioPlayer?
    let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
    var eventStore = EKEventStore()
    func checkAuth() {
        //現在のアクセス権限の状態を取得
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        if status == .authorized { // もし権限がすでにあったら
            print("アクセス可能！！")
        }else if status == .notDetermined {
            // アクセス権限のアラートを送る。
            eventStore.requestAccess(to: EKEntityType.event) { (granted, error) in
                if granted { // 許可されたら
                    print("アクセス許可")
                }else { // 拒否されたら
                    print("アクセスが拒否")
                }
            }
        }
    }
    
    var at:[String] = ["9:00"]
    var switchArray: [UISwitch] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkAuth()
        // 背景色をRGB形式で指定
        let redValue: CGFloat = 39 // 赤成分
        let greenValue: CGFloat = 39 // 緑成分
        let blueValue: CGFloat = 39 // 青成分
        
        let backgroundColor = UIColor(red: redValue / 255.0, green: greenValue / 255.0, blue: blueValue / 255.0, alpha: 1.0)
        
        // UITableViewの背景色を設定
        tableView.backgroundColor = backgroundColor
        tableView.separatorColor = UIColor.white
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return at.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        cell.textLabel?.text = at[indexPath.row]
        cell.textLabel?.font = cell.textLabel?.font.withSize(30.0)
        
        cell.textLabel?.textColor = UIColor.white
        
        for (index, _) in at.enumerated() {
            let aSwitch = UISwitch()
            aSwitch.frame = CGRect(x: 300, y: 240 + 77 * index, width: 0, height: 0)
            aSwitch.tag = index // スイッチにタグを設定
            aSwitch.addTarget(self, action: #selector(switchTapped(_:)), for: .valueChanged)
            view.addSubview(aSwitch)
            switchArray.append(aSwitch)
        }
        
        return cell
    }
    
    @objc func switchTapped(_ sender: UISwitch) {
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "時間になりました"
        content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "alarm_sound.mp3"))
        //content.sound = UNNotificationSound.default
        let index = sender.tag
        let isSwitchOn = sender.isOn
        
        if isSwitchOn {
            print("\(at[index]) is turned on.")
            let dateString = at[index]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            var dateComponents = DateComponents()
            dateComponents.year = 2022
            dateComponents.month = 12
            dateComponents.day = 31
            dateComponents.hour = 23
            dateComponents.minute = 59
            dateComponents.second = 59
            if let date = dateFormatter.date(from: dateString) {
                dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
                // dateComponentsを使用して何かをする
            }
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "alarm", content: content, trigger: trigger)
            print(request)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error setting alarm: \(error.localizedDescription)")
                }
            }
        } else {
            print("\(at[index]) is turned off.")
            // アラームを削除する
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["alarm"])
        }
    }

    @IBAction func SetTime(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segueのIDを確認して特定のsegueのときのみ動作させる
        if segue.identifier == "toSetTime" {
            // 遷移先のViewControllerを取得
            let next = segue.destination as? SetViewController
            // 遷移先のプロパティに処理ごと渡す
            next?.resultHandler = { text in
                // 引数を使ってoutputLabelの値を更新する処理
//                self.alarmTime.text = text
                self.at.append(text)
                self.tableView.reloadData()//画面から戻ったらtableを更新
            }
        }
    }
    
    func playAlarmSound() {
            guard let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "mp3") else { return }
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
            } catch {
                print("Error playing alarm sound: \(error.localizedDescription)")
            }
        }
        
    func stopAlarmSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

extension MainViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "alarm" {
            // アラームがトリガーされたときに音声通知を再生する
            print("A")
            playAlarmSound()
            
            completionHandler()
        }
    }
}


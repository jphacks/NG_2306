//
//  TalkViewController.swift
//  AlarmText2
//
//  Created by 小西貴洋 on 2023/10/29.
//
import SwiftUI
import UIKit
import Speech
import EventKit
import UserNotifications
import AVFoundation
import OpenAI
import Accelerate
import Foundation

class TalkViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let openAI = OpenAI(apiToken: "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")
        private func getEmbeddings(for text: String) async -> [Double] {
            let embeddingsQuery = EmbeddingsQuery(model: .textEmbeddingAda, input: text)
            let result = try! await openAI.embeddings(query: embeddingsQuery)
            return result.data.first!.embedding
        }
    private var recognitionTask: SFSpeechRecognitionTask?
    //音楽

    
    @IBOutlet weak var textView2: UITextView!
    private let audioEngine = AVAudioEngine()
    @IBAction func recordTapped(_ sender: Any) {
        print("Tapped")
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            userText = textView2.text
            //回答をuserTextに格納
            recordButton.isEnabled = false
            recordButton.setTitle("録音", for: [])
            
            var quizList: [[String]] = getEventsInToday()
            
            let text1 = quizList[count][0]
            var A = quizList.count
            print(text1)
            Task{
                
                //音声認識で勝手に入るTextという文字を削除
                let modifiedText = userText.replacingOccurrences(of: "Text", with: "")
                //text2.trimmingCharacters(in: .whitespacesAndNewlines)
                let text2 = userText
                print(text2)
                let lvec = await getEmbeddings(for: text1)
                
                let rvec = await getEmbeddings(for: text2)
                
                print(vDSP.cosineSimilarity(lhs: lvec, rhs: rvec))
                if vDSP.cosineSimilarity(lhs: lvec, rhs: rvec) > 0.85 {
                    Answer = true
                }else {
                    Answer = false
                }
                if Answer {
                    //print正解!
                    
                    print("正解です！")
                    guard let url = Bundle.main.url(forResource: "Correct", withExtension: "mp3") else {
                        print("MP3ファイルが見つかりませんでした。")
                        return
                    }
                    do {
                        let player = try AVAudioPlayer(contentsOf: url)
                        player.play()
                    } catch {
                        print("AVAudioPlayerの作成に失敗しました。")
                    }
                    
                    
                    //sleep(2)
                    count += 1
                    makeQuiz(num: count)
                }
                else{
                    guard let url = Bundle.main.url(forResource: "No", withExtension: "mp3") else {
                        print("MP3ファイルが見つかりませんでした。")
                        return
                    }
                    do {
                        let player = try AVAudioPlayer(contentsOf: url)
                        player.play()
                    } catch {
                        print("AVAudioPlayerの作成に失敗しました。")
                    }
                    //不正解！もう一周
//                    textView.text = ("不正解！")
//                    print("不正解！")
//                    var talk = "不正解"
//                    speech(text: talk)
//                    sleep(2)
                    count += 1
                    count = count % A
                    
                    makeQuiz(num: count)
                    
                }
            }
            }else {
                do {
                    try startRecording()
                    recordButton.setTitle("回答", for: [])
                } catch {
                    recordButton.setTitle("Recording Not Available", for: [])
                }
            }
        }
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    
//    @IBOutlet weak var AIimage: UIImageView!
//    @IBOutlet weak var personImage: UIImageView!
    
    var userText = ""
    var Answer = false
    var whi = true
    var count = 0
    var eventStore = EKEventStore()
    let calendar = Calendar.current
    func getEventsInToday() -> [[String]] {
        var componentsOneDayDelay = DateComponents()
        componentsOneDayDelay.day = 1
        var componentsNineHoursDelay = DateComponents()
        componentsNineHoursDelay.hour = 0
        let nowDate = Date()
        let compornent = calendar.dateComponents([.year, .month, .day], from: nowDate)
        let gmt_startDate = calendar.date(from: compornent)!
        let startDate = calendar.date(byAdding: componentsNineHoursDelay, to: gmt_startDate)!
        
        let endDate = calendar.date(byAdding: componentsOneDayDelay, to: startDate)!
        
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        
        let eventArray = eventStore.events(matching: predicate)
        
        var eventList: [[String]] = []
        for (index, eventarray) in eventArray.enumerated(){
            eventList.append([])
            let event_date = eventarray.startDate
            let compornent = calendar.dateComponents([.day, .hour, .minute], from: event_date!)//            print(eventarray.title!, eventarray.startDate!)
            eventList[index].append(eventarray.title!)
            eventList[index].append(String(compornent.day!))
            eventList[index].append(String(compornent.hour!))
            eventList[index].append(String(compornent.minute!))
        }
        return eventList
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordButton.isEnabled = false
        let eventList = getEventsInToday()
        
        // Do any additional setup after loading the view.
        
//        let pImage = UIImage(named: "upper_body_-2.jpg")
//        personImage.image = pImage
//        let AImage = UIImage(named: "5370.pmg")
//        AIimage.image = AImage
        
        textView.font = UIFont.boldSystemFont(ofSize: 28)
        textView2.font = UIFont.boldSystemFont(ofSize: 28)
    }
    
    var synthesizer = AVSpeechSynthesizer()
    func speech(text: String){
        let japaneseUtterance = AVSpeechUtterance(string: text)
        japaneseUtterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        synthesizer.speak(japaneseUtterance)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        speechRecognizer.delegate = self
        
        // Asynchronously make the authorization request.
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            // Divert to the app's main thread so that the UI
            // can be updated.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                    
                default:
                    self.recordButton.isEnabled = false
                }
            }
        }
        makeQuiz(num: count)
    }
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                self.textView2.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
                
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("録音", for: [])
            }
        }
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking.
    }
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("回答", for: [])
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition Not Available", for: .disabled)
        }
    }
    public func makeQuiz(num: Int) -> Void{
        if Answer && count != 0 {
            textView.text = ("正解！")
            var talk = "正解"

        }else if !Answer && count != 0{
            let url = URL(fileURLWithPath: "alarm_sound.mp3")
             
            // AVAudioPlayerインスタンスを作成
            var audioPlayer: AVAudioPlayer?
             
            do {
                // AVAudioPlayerインスタンスに音声ファイルを割り当て
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                
                // 音声ファイルを再生
                audioPlayer?.play()
            } catch {
                // エラー処理
                print(error.localizedDescription)
            }
            textView.text = ("不正解！")
            print("不正解！")
            var talk = "不正解"
            
        }
        
        if !Answer{
            //クイズの生成　できたクイズはtextView.textに　=　でいれる
            var QuizList: [[String]] = getEventsInToday()
            print(count)
            print(QuizList)
            var quiz = "今日の" + QuizList[count][2] + "時" + QuizList[count][3] + "分の予定はなんでしょう？"
            print(quiz)
            //speech(text: quiz)
            textView.text = quiz
        }
    }
    
}

extension vDSP {
    @inlinable
    public static func cosineSimilarity<U: AccelerateBuffer>(
        lhs: U,
        rhs: U
    ) -> Double where U.Element == Double {
        let dotProduct = vDSP.dot(lhs, rhs)
        
        let lhsMagnitude = vDSP.sumOfSquares(lhs).squareRoot()
        let rhsMagnitude = vDSP.sumOfSquares(rhs).squareRoot()
        
        return dotProduct / (lhsMagnitude * rhsMagnitude)
    }
    
    @inlinable
    public static func cosineSimilarity<U: AccelerateBuffer>(
        lhs: U,
        rhs: U
    ) -> Float where U.Element == Float {
        let dotProduct = vDSP.dot(lhs, rhs)
        
        let lhsMagnitude = vDSP.sumOfSquares(lhs).squareRoot()
        let rhsMagnitude = vDSP.sumOfSquares(rhs).squareRoot()
        
        return dotProduct / (lhsMagnitude * rhsMagnitude)
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

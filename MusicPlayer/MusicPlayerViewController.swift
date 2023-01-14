//
//  MusicPlayerViewController.swift
//  MusicPlayer
//
//  Created by Kai on 2023/1/9.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    // playButton 的 IBOutlet
    @IBOutlet weak var starButton: UIButton!
    // 演唱者的 IBOutlet
    @IBOutlet weak var singerLabel: UILabel!
    // 歌曲名的 IBOutlet
    @IBOutlet weak var songLabel: UILabel!
    // 歌曲當前時間的 Label IBOutlet
    @IBOutlet weak var currentTimeLabel: UILabel!
    // 歌曲總時長的 Label IBOutlet
    @IBOutlet weak var totalTimeLabel: UILabel!
    // 歌曲進度的 Slider IBOutlet
    @IBOutlet weak var songSlider: UISlider!
    // 切換模式(正常/單曲循環/隨機) 的 Button IBOutlet
    @IBOutlet weak var modeButton: UIButton!
    
    let player = AVPlayer()
    var index = 0
    var songDuration:Double = 0
    // 預設單曲循環為 false
    var repeatOn:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        playMusic(currentMusic: index)
        player.pause()
        starButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        setSongDurationLabel()
        notitficaitonMusicRepeat()
        songLabel.font = UIFont(name: "HanyiSentyPine", size: 45)
        singerLabel.font = UIFont(name: "HanyiSentyPine", size: 80)
    }
    
    var music = [
        mainMusic(name: "為你寫下這首情歌", singer: "五月天", albumImage: "01", time: 239),
        mainMusic(name: "最偉大的作品", singer: "周杰倫", albumImage: "02", time: 306),
        mainMusic(name: "告別的時代", singer: "蘇見信", albumImage: "03", time: 299),
        mainMusic(name: "愛情你比我想的閣較偉大", singer: "茄子蛋", albumImage: "04", time: 270),
        mainMusic(name: "閣愛妳一擺", singer: "茄子蛋", albumImage: "05", time: 307)
    ]
    //利用 enum 及 switch 判斷當前模式
    enum ModeState:String{
        case normal
        case reprat
        case shuffle
    }
    //預設播放模式為正常模式
    var mode = ModeState.normal
    //透過 switch 判斷
    func checkModeState() {
        switch mode {
        case .shuffle:
            repeatOn = false
        case .normal:
            repeatOn = false
        case .reprat:
            repeatOn = true
        default:
            break
        }
    }
    
    //利用 if else 判斷歌曲結束後執行程式
    fileprivate func notitficaitonMusicRepeat() {
    NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
            if self.repeatOn == true{
                //偵測 value 0/ timescalse 1 = 0 時
                let musicEndTime:CMTime = CMTimeMake(value: 0, timescale: 1)
                print("musicEndTime\(musicEndTime)")
                //seek從頭播放
                self.player.seek(to: musicEndTime)
                self.player.play()
            } else if self.repeatOn == false {
                if self.mode == ModeState.shuffle {
                    self.index = Int.random(in: 0...(self.music.count - 1))
                    print(self.index)
                    self.nextSong()
                } else if self.mode == ModeState.normal {
                    self.nextSong()
                    }
            }
        }
    }
    
    //初始設定 UI 的 function,只在 viewdidload 中執行
    func setupUI() {
        //gradientLayerBackground
        let gradientLayer = CAGradientLayer()
            //漸層背景的大小設定
            gradientLayer.frame = view.bounds
            //加入顏色
            gradientLayer.colors = [
            UIColor(red: 247/255, green: 201/255, blue: 120/255, alpha: 1).cgColor,
            UIColor(red: 243/255, green: 164/255, blue: 105/255, alpha: 1).cgColor,
            UIColor(red: 241/255, green: 130/255, blue: 113/255, alpha: 1).cgColor,
            UIColor(red: 204/255, green: 107/255, blue: 142/255, alpha: 1).cgColor,
            UIColor(red: 168/255, green: 106/255, blue: 164/255, alpha: 1).cgColor,
            UIColor(red: 143/255, green: 106/255, blue: 174/255, alpha: 1).cgColor,
            UIColor(red: 123/255, green: 95/255, blue: 172/255, alpha: 1).cgColor,
            UIColor(red: 90/255, green: 85/255, blue: 174/255, alpha: 1).cgColor,
            UIColor(red: 63/255, green: 81/255, blue: 177/255, alpha: 1).cgColor
        ]
            //針對漸層的顏色佔比例
            gradientLayer.locations = [0, 0.2, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
            //使用 insertSublayer 而不是 addSublayer,並設定顯示於最底層
            view.layer.insertSublayer(gradientLayer, at: 0)
        
            //imageViewSet
            //圓角設定
            imageView.layer.cornerRadius = 60
            //圖片填滿效果
            imageView.contentMode = .scaleAspectFit
            //邊框設定
            imageView.layer.borderWidth = 3
            imageView.layer.borderColor = UIColor.black.cgColor
            
            //songSliderSet
            //改變 Thumb 為系統的長方形圖
            songSlider.setThumbImage(UIImage(systemName: "rectangle.portrait.fill"), for: .normal)
            //或是可以將原本的 Thumb 改為透明
            //songSlider.thumbTintColor = UIColor.clear
    }
    
    // playMusic & updateUI function
    func playMusic(currentMusic: Int) {
        let fileUrl = Bundle.main.url(forResource: "\(music[currentMusic].name)", withExtension: "mp3")!
        let playItem = AVPlayerItem(url: fileUrl)
        //偵測所選取歌曲的總時長
        songDuration = playItem.asset.duration.seconds
        //設定歌曲進度 slider 的最大值
        setSliderMinMax()
        player.replaceCurrentItem(with: playItem)
        player.play()
        starButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        imageView.image = UIImage(named: "\(music[index].albumImage)")
        singerLabel.text = "\(music[index].singer)"
        songLabel.text = "\(music[index].name)"
    }
    
    // play/pause Button
    @IBAction func playButton(_ sender: UIButton) {
        //當歌曲為播放中時,按下 button 讓歌曲暫停,並更改 button image 為 play
        if player.timeControlStatus == .playing {
            sender.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
        //當歌曲不在播放時,按下 button 讓歌曲繼續播放,並更改 button image 為 pause
        } else {
            sender.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            player.play()
        }
    }
    
    //下一首歌曲
    func nextSong() {
        index = (index + 1) % music.count
        playMusic(currentMusic: index)
    }
    
    //上一首歌曲
    func preSong() {
        index = (index + music.count - 1 ) % music.count
        playMusic(currentMusic: index)
    }
    
    //下一首的 Button
    @IBAction func nextButton(_ sender: Any) {
        //當為隨機播放模式時,下一首會以隨機播放
        if mode == ModeState.shuffle {
            index = Int.random(in: 0...(music.count - 1))
            playMusic(currentMusic: index)
        //當不為隨機播放模式時,下一首會依照 Array 順序排序
        } else {
            nextSong()
        }
    }
    
    //上一首的 Button
    @IBAction func preButton(_ sender: Any) {
        if mode == ModeState.shuffle {
            index = Int.random(in: 0...(music.count - 1))
            playMusic(currentMusic: index)
        } else {
            preSong()
        }
    }
    
    @IBAction func setVolume(_ sender: UISlider) {
        player.volume = sender.value
    }
 
    //音樂時間轉換（總秒數轉 "分鐘:秒數"）
    func timeFormat(time:Double)->String{
        let resultTime = Int(time).quotientAndRemainder(dividingBy: 60)
        return "\(resultTime.quotient):\(String(format: "%.2d", resultTime.remainder))"
    }
    //設定歌曲當前時間、當前slider時長及歌曲總時間
    func setSongDurationLabel() {
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main) { (CMTime) in
            if self.player.timeControlStatus == .playing {
                //設定歌曲進度slider
                let currentTime = self.player.currentTime().seconds
                self.songSlider.value = Float(currentTime)
                //設定目前播放歌曲的時間及歌曲總時間
                self.currentTimeLabel.text = self.timeFormat(time: currentTime)
                self.totalTimeLabel.text =  self.timeFormat(time: self.songDuration)
            }
        }
    }
    //設定歌曲進度 Slider 的最大值
    func setSliderMinMax() {
        songSlider.maximumValue = Float(songDuration)
        songSlider.isContinuous = true
        //.isContinuous: T:滑動間，音樂停止 F:滑動時，音樂持續播放直到滑動完後執行動作。
    }
    //設定當前歌曲透過滑動 slider 變更時間及音樂區段
    @IBAction func controlSongDuration(_ sender: UISlider) {
        let time = CMTime(value: CMTimeValue(sender.value), timescale: 1)
        player.seek(to: time) //seek(找尋): 找尋音樂區段
    }

    //切換模式的 Button
    @IBAction func modeButton(_ sender: UIButton) {
        //當 buttonImage = repeat 時為正常模式
        if modeButton.currentBackgroundImage == UIImage(systemName: "repeat") {
                //當按下 button 時會將模式變為單曲循環模式,同時會將 buttonImage 改為 repeat.1
                mode = ModeState.reprat
                modeButton.setBackgroundImage(UIImage(systemName: "repeat.1"), for: .normal)
                print(mode)
                //並執行 switch 判斷 repeatOn 的 Bool
                checkModeState()
        //當 buttonImage = repeat.1 時為單曲循環模式
        } else if modeButton.currentBackgroundImage == UIImage(systemName: "repeat.1") {
                //當按下 button 時會將模式變為隨機播放模式,同時會將 buttonImage 改為 shuffle
                mode = ModeState.shuffle
                modeButton.setBackgroundImage(UIImage(systemName: "shuffle"), for: .normal)
                print(mode)
                //並執行 switch 判斷 repeatOn 的 Bool
                checkModeState()
        //當 buttonImage = shuffle 時為隨機播放模式
        } else if modeButton.currentBackgroundImage == UIImage(systemName: "shuffle") {
                //當按下 button 時會將模式變為正常模式,同時會將 buttonImage 改為 repeat
                mode = ModeState.normal
                modeButton.setBackgroundImage(UIImage(systemName: "repeat"), for: .normal)
                print(mode)
                //並執行 switch 判斷 repeatOn 的 Bool
                checkModeState()
        }
    }
        //原本預計練習用 enum & switch 來判斷及執行,後來因考慮到點選模式按鈕後應於歌曲結束後才執行,最終才將執行程式放在 notitficaiton function 中。
}

//==================================================

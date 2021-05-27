//
//  Sounds.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-10-30.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import AVFoundation


class SoundsMaker: NSObject {
	
	public static let main = SoundsMaker()
	
	var audioPlayer = AVAudioPlayer()
	var isMute : Bool = false
	
	var tweetSoundID: SystemSoundID = 1016
	var messageSoundID: SystemSoundID = 1007
	
	//For more list sounds, you can find them here: http://iphonedevwiki.net/index.php/AudioServices
	
	private func playSound(file:String, ext:String) -> Void {
		if (!isMute ) {
			do {
				let url = URL.init(fileURLWithPath: Bundle.main.path(forResource: file, ofType: ext)!)
				audioPlayer = try AVAudioPlayer(contentsOf: url)
				audioPlayer.prepareToPlay()
				audioPlayer.play()
			} catch let error {
				NSLog(error.localizedDescription)
			}
		}
	}
	
	public func alert() {
		//playSound(file: "alert", ext: "mp3")
		AudioServicesPlaySystemSound (messageSoundID)
	}
	
	public func turnOnOffSounds () {
		isMute = !isMute
	}
	
	
}

class VideoMaker: NSObject {
	
	public static let main = VideoMaker()
	public var player = AVPlayer()
	public var playerLayer = AVPlayerLayer()
	
	public func setUp(name: String = "logo", type: String = "mp4"){
		let url = Bundle.main.path(forResource: name, ofType: type)
		player = AVPlayer(url: URL(fileURLWithPath: url ?? ""))
		playerLayer = AVPlayerLayer(player: player)
		//reference: https://stackoverflow.com/questions/50927561/weird-borders-around-avplayerviewcontroller
		playerLayer.shouldRasterize = true
		playerLayer.rasterizationScale = UIScreen.main.scale
	}
	
	public func playLogo() {
		player.seek(to: kCMTimeZero)
		player.play()
	}
	
}

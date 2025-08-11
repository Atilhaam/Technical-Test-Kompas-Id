//
//  Playbackmanager.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 08/08/25.
//

import Foundation
import AVFoundation
import MediaPlayer
import Combine

final class PlaybackManager: ObservableObject {
    @Published var audioPlayer: AVPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentlyPlayingID: String?

    private var timeObserver: Any?
    private var commandCenterConfigured = false

    // Call this to start playback for a given article
    func startBackgroundAudio(from url: URL, title: String, articleID: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }

        // cleanup previous observer
        if let obs = timeObserver {
            audioPlayer?.removeTimeObserver(obs)
            timeObserver = nil
        }

        currentlyPlayingID = articleID
        isPlaying = true

        audioPlayer = AVPlayer(url: url)
        audioPlayer?.play()

        // periodic time observer (1s)
        timeObserver = audioPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2),
                                                            queue: .main) { [weak self] time in
            guard let self = self else { return }
            var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(time)
            info[MPNowPlayingInfoPropertyPlaybackRate] = self.isPlaying ? 1.0 : 0.0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }

        setupNowPlaying(title: title)
        configureRemoteCommandCenterIfNeeded()
    }

    func togglePlayPause() {
        guard let player = audioPlayer else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()

        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func stop() {
        audioPlayer?.pause()
        audioPlayer = nil
        isPlaying = false
        currentlyPlayingID = nil
        if let obs = timeObserver {
            audioPlayer?.removeTimeObserver(obs)
            timeObserver = nil
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func setupNowPlaying(title: String) {
        var nowPlayingInfo: [String: Any] = [:]
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = "News Reader"

        if let currentItem = audioPlayer?.currentItem {
            let duration = CMTimeGetSeconds(currentItem.asset.duration)
            if duration.isFinite {
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            }
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func configureRemoteCommandCenterIfNeeded() {
        guard !commandCenterConfigured else { return }
        commandCenterConfigured = true

        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.audioPlayer?.play()
            self?.isPlaying = true
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.audioPlayer?.pause()
            self?.isPlaying = false
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent,
                  let player = self?.audioPlayer else { return .commandFailed }
            let time = CMTime(seconds: positionEvent.positionTime, preferredTimescale: 1)
            player.seek(to: time)
            return .success
        }
    }
}

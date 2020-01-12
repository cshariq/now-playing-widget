//
//  NowPlayingItemView.swift
//  Pock
//
//  Created by Pierluigi Galdi on 17/02/2019.
//  Copyright © 2019 Pierluigi Galdi. All rights reserved.
//

import Foundation
import AppKit
import PockKit
import Defaults

extension String {
    func truncate(length: Int, trailing: String = "…") -> String {
        return self.count > length ? String(self.prefix(length)) + trailing : self
    }
}

class NowPlayingItemView: PKDetailView {
    
    /// Overrideable
    public var didTap: (() -> Void)?
    public var didSwipeLeft: (() -> Void)?
    public var didSwipeRight: (() -> Void)?
    public var didLongPress: (() -> Void)?
    
    /// Data
    public var nowPLayingItem: NowPlayingItem? {
        didSet {
            self.updateContent()
        }
    }
    
    override func didLoad() {
        titleView.numberOfLoop    = 3
        subtitleView.numberOfLoop = 1
        super.didLoad()
    }
    
    private func updateContent() {
        
        var appBundleIdentifier: String = self.nowPLayingItem?.appBundleIdentifier ?? ""
        
        switch (appBundleIdentifier) {
        case "com.apple.WebKit.WebContent":
            appBundleIdentifier = "com.apple.Safari"
        case "com.spotify.client", "com.apple.iTunes", "com.apple.Safari", "com.google.Chrome", "com.netease.163music", "com.tencent.QQMusicMac", "com.xiami.macclient", "com.apple.Music":
            break
        default:
            appBundleIdentifier = Defaults[.defaultMusicPlayerBundleID]
        }
        
        let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: appBundleIdentifier)
        
        DispatchQueue.main.async { [weak self] in
            if let path = path {
                self?.imageView.image = NSWorkspace.shared.icon(forFile: path)
            }else {
                self?.imageView.image = NSWorkspace.shared.icon(forFileType: "mp3")
            }
            
            var title  = self?.nowPLayingItem?.title  ?? "Tap here"
            var artist = self?.nowPLayingItem?.artist ?? "to play music"
            
            if title.isEmpty {
                title = "Missing title"
            }
            if artist.isEmpty {
                artist = "Unknown artist"
            }
            
            let titleWidth    = (title  as NSString).size(withAttributes: self?.titleView.textFontAttributes    ?? [:]).width
            let subtitleWidth = (artist as NSString).size(withAttributes: self?.subtitleView.textFontAttributes ?? [:]).width
            self?.maxWidth = min(max(titleWidth, subtitleWidth), 80)
            
            self?.set(title: title)
            self?.set(subtitle: artist)
            
            self?.updateForNowPlayingState()
        }
    }
    
    private func updateForNowPlayingState() {
        if Defaults[.animateIconWhilePlaying], self.nowPLayingItem?.isPlaying ?? false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: { [weak self] in
                self?.startBounceAnimation()
            })
        }else {
            self.stopBounceAnimation()
        }
    }
    
    override open func didTapHandler() {
        self.didTap?()
    }
    
    override open func didSwipeLeftHandler() {
        self.didSwipeLeft?()
    }
    
    override open func didSwipeRightHandler() {
        self.didSwipeRight?()
    }
    
    override func didLongPressHandler() {
        self.didLongPress?()
    }
    
}

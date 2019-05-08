//
//  RewardVideoAdX.swift
//  AdX
//
//  Created by RyoKosuge on 2019/05/08.
//  Copyright © 2019年 Ryo Kosuge. All rights reserved.
//

import UIKit
import GoogleMobileAds

enum RewardVideoAdXError: Error {
    case noAd
    case timeout
    
    var localizedDescription: String {
        switch self {
        case .noAd:
            return "no ad"
        case .timeout:
            return "request timeout"
        }
    }
}

protocol RewardVideoAdXDelegate: class {
    func rewardVideoDidLoad(_ rewardVideo: RewardVideoAdX)
    func rewardVideo(_ rewardVideo: RewardVideoAdX, didFailError error: RewardVideoAdXError)
    func rewardVideo(_ rewardVideo: RewardVideoAdX, didCloseWithRewarded rewarded: Bool)
}

class RewardVideoAdX: NSObject {
    
    let adUnitID: String
    
    var timeoutInterval: TimeInterval = 0
    weak var delegate: RewardVideoAdXDelegate?
    
    private var isRewarded: Bool = false
    
    private var timer: Timer?
    private var isTimeout: Bool = false

    init(adUnitID: String) {
        self.adUnitID = adUnitID
    }

    func prepare() {
        self.isRewarded = false
        self.isTimeout = false
        GADRewardBasedVideoAd.sharedInstance().delegate = self
    }

    func load() {
        GADRewardBasedVideoAd.sharedInstance().load(DFPRequest(), withAdUnitID: adUnitID)
        setTimer()
    }

    func present(fromRootViewController viewController: UIViewController) {
        guard GADRewardBasedVideoAd.sharedInstance().isReady else {
            return
        }

        GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: viewController)
    }

}

// MARK: - timer fired
extension RewardVideoAdX {
    
    private func clearTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: timeoutInterval,
                                          target: self,
                                          selector: #selector(timerFired(_:)),
                                          userInfo: nil,
                                          repeats: false)
    }

    @objc
    private func timerFired(_ timer: Timer) {
        clearTimer()
        self.isTimeout = true
        self.delegate?.rewardVideo(self, didFailError: .timeout)
    }

}

// MARK: - GADRewardBasedVideoAdDelegate
extension RewardVideoAdX: GADRewardBasedVideoAdDelegate {
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        guard !isTimeout else { return }
        clearTimer()
        self.delegate?.rewardVideoDidLoad(self)
    }

    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        self.isRewarded = true
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        self.delegate?.rewardVideo(self, didCloseWithRewarded: self.isRewarded)
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        clearTimer()
        guard !isTimeout else { return }
        self.delegate?.rewardVideo(self, didFailError: .noAd)
    }

}

//
//  ViewController.swift
//  AdX
//
//  Created by RyoKosuge on 2019/05/08.
//  Copyright © 2019年 Ryo Kosuge. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet
    weak var constCenterY: NSLayoutConstraint?
    
    @IBOutlet
    weak var adUnitIDTextField: UITextField?
    
    @IBOutlet
    weak var timeoutIntervalTextField: UITextField?
    
    @IBOutlet
    weak var loadButton: UIButton?
    
    @IBOutlet
    weak var showButton: UIButton?
    
    private var reward: RewardVideoAdX?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        prepareView()
    }

}

// MARK: - button action
extension ViewController {
    
    @objc
    private func onTouchCloseButton() {
        self.adUnitIDTextField?.resignFirstResponder()
        self.timeoutIntervalTextField?.resignFirstResponder()
    }

    @IBAction
    func onTouchLoadButton() {
        showButton?.isEnabled = false

        let adUnitID = adUnitIDTextField?.text ?? ""
        let timeout = TimeInterval(timeoutIntervalTextField?.text ?? "0") ?? 0.0
        let reward = RewardVideoAdX(adUnitID: adUnitID)
        reward.delegate = self
        reward.timeoutInterval = timeout
        reward.prepare()
        reward.load()
        self.reward = reward
    }

    @IBAction
    func onTouchShowButton() {
        reward?.present(fromRootViewController: self)
    }

}

// MARK: - UIKeyboard
extension ViewController {

    @objc
    private func willShowKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let rect: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.0

        view.setNeedsLayout()
        constCenterY?.constant = -(rect.height * 0.5)
        UIView.animate(withDuration: duration) {[weak self] in
            self?.view.layoutIfNeeded()
        }
    }

    @objc
    private func willHideKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.0
        
        view.setNeedsLayout()
        constCenterY?.constant = 0
        UIView.animate(withDuration: duration) {[weak self] in
            self?.view.layoutIfNeeded()
        }
    }

}

// MARK: - prepare
extension ViewController {
    
    private func prepareView() {
        let toolBar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        let closeButton = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(onTouchCloseButton))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, closeButton], animated: true)
        
        self.adUnitIDTextField?.inputAccessoryView = toolBar
        self.timeoutIntervalTextField?.inputAccessoryView = toolBar
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(willHideKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        showButton?.isEnabled = false
    }

}

// MARK: - RewardVideoAdXDelegate
extension ViewController: RewardVideoAdXDelegate {

    func rewardVideoDidLoad(_ rewardVideo: RewardVideoAdX) {
        self.showButton?.isEnabled = true
    }
    
    func rewardVideo(_ rewardVideo: RewardVideoAdX, didFailError error: RewardVideoAdXError) {
        let alert = UIAlertController(title: "エラー", message: "読み込みエラー\n\(error.localizedDescription)", preferredStyle: .alert)
        let action = UIAlertAction(title: "閉じる", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        showButton?.isEnabled = false
    }
    
    func rewardVideo(_ rewardVideo: RewardVideoAdX, didCloseWithRewarded rewarded: Bool) {
        let message = rewarded ? "報酬受け取りました" : "報酬はありません"
        let alert = UIAlertController(title: "再生完了", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "閉じる", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        showButton?.isEnabled = false
    }
    
}

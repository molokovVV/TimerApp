//
//  ViewController.swift
//  TimerApp
//
//  Created by Виталик Молоков on 23.12.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController, CAAnimationDelegate {
    
    //MARK: - Properties
    
    private var timer = Timer()
    private var accurateTimerCount = 1000
    private var relaxTime = 5
    private var workTime = 20
    
    private var isWorkTime = true
    private var isStarted = false
    private var isAnimationStarted = false
    
    private let foreProgressLayer = CAShapeLayer()
    private let backProgressLayer = CAShapeLayer()
    private let animation = CABasicAnimation(keyPath: "strokeEnd")
    
    //MARK: - UI Elements
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:20"
        label.textAlignment = .center
        label.font = UIFont(name: "Verdana", size: 50)
        label.textColor = .systemMint
        
        return label
    }()
    
    private lazy var timerButtonPlay: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonStarted), for: .touchUpInside)
        button.setImage(UIImage(named: "playIcon"), for: .normal)
        
        return button
    }()
    
    private lazy var timerButtonCancel: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonCanceled), for: .touchUpInside)
        button.setImage(UIImage(named: "stopIcon"), for: .normal)
        button.isEnabled = false
        button.alpha = 0.5
        
        return button
    }()
    
    //MARK: - Stacks
    
    private lazy var timerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 5
        stack.addArrangedSubview(timerLabel)
        stack.addArrangedSubview(timerButtonPlay)
        stack.addArrangedSubview(timerButtonCancel)
        return stack
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayots()
        drawBackLayer()
    }
    
    //MARK: - Animation
    
    private func drawBackLayer() {
        backProgressLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.midX, 
                                                                 y: view.frame.midY), 
                                              radius: 150, 
                                              startAngle: -90.degreesToRadians, 
                                              endAngle: 270.degreesToRadians, 
                                              clockwise: true).cgPath
        backProgressLayer.strokeColor = UIColor.systemMint.cgColor
        backProgressLayer.fillColor = UIColor.clear.cgColor
        backProgressLayer.lineWidth = 5
    }
    
    private func drawForeLayer() {
        foreProgressLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.midX, 
                                                                 y: view.frame.midY), 
                                              radius: 150, 
                                              startAngle: -90.degreesToRadians, 
                                              endAngle: 270.degreesToRadians, 
                                              clockwise: true).cgPath
        foreProgressLayer.strokeColor = {
            if isWorkTime {
                foreProgressLayer.strokeColor = UIColor.black.cgColor
            } else {
                foreProgressLayer.strokeColor = UIColor.white.cgColor
            }
            return foreProgressLayer.strokeColor
        }()
        foreProgressLayer.fillColor = UIColor.clear.cgColor
        foreProgressLayer.lineWidth = 5
    }
    
    private func startResumeAnimation() {
        if !isAnimationStarted {
            startAnimation()
        } else {
            resumeAnimation()
        }
    }
    
    private func startAnimation() {
        resetAnimation()
        foreProgressLayer.strokeEnd = 0.0
        animation.keyPath = "strokeEnd"
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = {
            if isWorkTime {
                animation.duration = CFTimeInterval(workTime)
            } else {
                animation.duration = CFTimeInterval(relaxTime)
            }
            return animation.duration
        }()
        
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        foreProgressLayer.add(animation, forKey: "strokeEnd")
        isAnimationStarted = true
    }
    
    private func resetAnimation() {
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        isAnimationStarted = false
    }
    
    private func pauseAnimation() {
        let pausedTime = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        foreProgressLayer.speed = 0.0
        foreProgressLayer.timeOffset = pausedTime
    }
    
    private func resumeAnimation() {
        let pausedTime = foreProgressLayer.timeOffset
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        let timeSincePaused = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        foreProgressLayer.beginTime = timeSincePaused
    }
    
    private func stopAnimation() {
        foreProgressLayer.removeAllAnimations()
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        isAnimationStarted = false
    }
    
    //MARK: - Setups
    
    private func setupHierarchy() {
        view.addSubview(timerStack)
        view.layer.addSublayer(backProgressLayer)
        view.layer.addSublayer(foreProgressLayer)
    }
    
    private func setupLayots() {
        timerStack.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
        }
        
        timerButtonPlay.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        timerButtonCancel.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    private func changeToWork() {
        guard relaxTime > 1 else {
            stopAnimation()
            relaxTime = 5
            changeInterface()
            isStarted = false
            isWorkTime = true
            timer.invalidate()
            return
        }
        
        relaxTime -= 1
        timerLabel.text = formatTimer()
    }

    private func changeToRelax() {
        guard workTime > 1 else {
            stopAnimation()
            workTime = 20
            changeInterface()
            isStarted = false
            isWorkTime = false
            timer.invalidate()
            return
        }
        
        workTime -= 1
        timerLabel.text = formatTimer()
    }


    private func formatTimer() -> String {
        if isWorkTime {
            let minutes = Int(workTime) / 60 % 60
            let seconds = Int(workTime) % 60
            return String(format:"%02i:%02i", minutes, seconds)
        } else {
            let minutes = Int(relaxTime) / 60 % 60
            let seconds = Int(relaxTime) % 60
            return String(format:"%02i:%02i", minutes, seconds)
        }
    }

    private func changeInterface() {
        if isWorkTime {
            timerButtonCancel.isEnabled = false
            timerLabel.text = "00:05"
            timerButtonPlay.setImage(UIImage(named: "playIcon"), for: .normal)
            view.backgroundColor = .white
            
        } else {
            timerButtonCancel.isEnabled = false
            timerLabel.text = "00:20"
            timerButtonPlay.setImage(UIImage(named: "playIcon"), for: .normal)
            foreProgressLayer.strokeColor = UIColor.black.cgColor
            view.backgroundColor = .black
            
        }
    }

    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }

    //MARK: - Actions

    @objc private func updateTimer() {
        if accurateTimerCount > 0 {
            accurateTimerCount -= 1
            return
        }
        
        accurateTimerCount = 1000
        
        if isWorkTime {
            changeToRelax()
        } else {
            changeToWork()
        }
    }

    @objc private func buttonStarted() {
        timerButtonCancel.isEnabled = true
        timerButtonCancel.alpha = 1
        
        if !isStarted {
            startTimer()
            drawForeLayer()
            startResumeAnimation()
            timerButtonPlay.setImage(UIImage(named: "pauseIcon"), for: .normal)
            isStarted = true
        } else {
            timer.invalidate()
            pauseAnimation()
            timerButtonPlay.setImage(UIImage(named: "playIcon"), for: .normal)
            isStarted = false
        }
    }

    @objc private func buttonCanceled() {
        stopAnimation()
        timerButtonCancel.isEnabled = false
        timerButtonCancel.alpha = 0.5
        isStarted = false
        workTime = 20
        relaxTime = 5
        accurateTimerCount = 1000
        timer.invalidate()
        timerLabel.text = {
            if isWorkTime {
                timerLabel.text = "00:20"
                timerButtonPlay.setImage(UIImage(named: "playIcon"), for: .normal)
            } else {
                timerLabel.text = "00:05"
                timerButtonPlay.setImage(UIImage(named: "playIcon"), for: .normal)
            }
            return timerLabel.text
        }()
    }
}

extension Int {
    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 180
    }
}

//
//  ViewController.swift
//  TimerApp
//
//  Created by Виталик Молоков on 23.12.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    //MARK: - UI Elements
    
    private lazy var timer: Timer = {
       let timer = Timer()
        
        return timer
    }()
    
    private lazy var timerLabel: UILabel = {
        let timerLabel = UILabel()
        timerLabel.text = "TIMER"
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont(name: "Avenir-Black", size: 50)
        timerLabel.textColor = .systemMint
        
        return timerLabel
    }()
    
    private lazy var timerButton: UIButton = {
        let timerButton = UIButton()
        timerButton.setImage(UIImage(named: "playLight"), for: .normal)
        timerButton.backgroundColor = .white
        
        return timerButton
    }()
    
    //MARK: - Stacks
    
    private lazy var timerStack: UIStackView = {
        let timerStack = UIStackView()
        timerStack.axis = .vertical
        timerStack.alignment = .center
        timerStack.distribution = .equalSpacing
        timerStack.spacing = 5
        timerStack.addArrangedSubview(timerLabel)
        timerStack.addArrangedSubview(timerButton)
        return timerStack
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayots()
    }
    
    //MARK: - Setups
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupHierarchy() {
        view.addSubview(timerButton)
        view.addSubview(timerStack)
    }
    
    private func setupLayots() {
        timerStack.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
        }
        
        timerButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
    }
}


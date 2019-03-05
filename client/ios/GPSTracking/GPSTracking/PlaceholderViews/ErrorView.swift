//
//  ErrorView.swift
//  Example
//
//  Created by Alexander Schuch on 29/08/14.
//  Copyright (c) 2014 Alexander Schuch. All rights reserved.
//

import UIKit

class ErrorView: BasicPlaceholderView {

	let textLabel = UILabel()
	let detailTextLabel = UILabel()
	let tapGestureRecognizer = UITapGestureRecognizer()
	
	override func setupView() {
		super.setupView()
		
		backgroundColor = UIColor.whiteColor()
		
		self.addGestureRecognizer(tapGestureRecognizer)
		
		textLabel.text = "Ошибка загрузки.".localized
        textLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        textLabel.textColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)

//		textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
		centerView.addSubview(textLabel)
		
		detailTextLabel.text = "Перезагрузка.".localized
        detailTextLabel.font = UIFont(name: "HelveticaNeue", size: 15)
		detailTextLabel.textAlignment = .Center
		detailTextLabel.textColor = UIColor.grayColor()
//		detailTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = false
		centerView.addSubview(detailTextLabel)
		
		let views = ["label": textLabel, "detailLabel": detailTextLabel]
		let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-[label]-|", options: .AlignAllCenterY, metrics: nil, views: views)
		let hConstraintsDetail = NSLayoutConstraint.constraintsWithVisualFormat("|-[detailLabel]-|", options: .AlignAllCenterY, metrics: nil, views: views)
		let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[label]-[detailLabel]-|", options: .AlignAllCenterX, metrics: nil, views: views)
		
		centerView.addConstraints(hConstraints)
		centerView.addConstraints(hConstraintsDetail)
		centerView.addConstraints(vConstraints)
	}

}

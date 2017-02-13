//
//  FBAnnotationClusterView.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import MapKit

public class FBAnnotationClusterView : MKAnnotationView {

	private var configuration: FBAnnotationClusterViewConfiguration

	private let countLabel: UILabel =
    {
		let label = UILabel()
		label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		label.textAlignment = .center
		label.backgroundColor = UIColor.clear
		label.textColor = UIColor.white
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 2
		label.numberOfLines = 1
		label.baselineAdjustment = .alignCenters
		return label
	}()

	public override var annotation: MKAnnotation?
    {
		didSet
        {
			updateClusterSize()
		}
	}
    
    public convenience init(annotation: MKAnnotation?, reuseIdentifier: String?, configuration: FBAnnotationClusterViewConfiguration)
    {
        self.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		self.configuration = configuration
		self.setupView()
    }

	public override init(annotation: MKAnnotation?, reuseIdentifier: String?)
    {
		self.configuration = FBAnnotationClusterViewConfiguration.default()
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		self.setupView()
	}

    required public init?(coder aDecoder: NSCoder)
    {
		self.configuration = FBAnnotationClusterViewConfiguration.default()
        super.init(coder: aDecoder)
		self.setupView()
    }
    
    private func setupView()
    {
		self.backgroundColor = UIColor.clear
		self.layer.borderColor = UIColor.white.cgColor
		self.addSubview(countLabel)
    }

	private func updateClusterSize()
    {
		guard let cluster = self.annotation as? FBAnnotationCluster else
        {
            return
        }

        let count = cluster.annotations.count
        let template = self.configuration.templateForCount(count: count)

        switch template.displayMode
        {
            case .Image(let imageName):
                self.image = UIImage(named: imageName)
            
            case .SolidColor(let sideLength, let color):
                self.backgroundColor = color
                self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: sideLength, height: sideLength))
        }

        self.layer.borderWidth = template.borderWidth
        self.countLabel.font = template.font
        self.countLabel.text = "\(count)"

        self.setNeedsLayout()
	}

    override public func layoutSubviews()
    {
		super.layoutSubviews()
        
		self.countLabel.frame = self.bounds
		self.layer.cornerRadius = self.image == nil ? self.bounds.size.width / 2 : 0
    }
}

//
//  GlossButtonStrokedSurfaceNode.swift
//  AppUIKit
//
//  Created by muukii on 2019/09/14.
//  Copyright © 2019 eure. All rights reserved.
//

import Foundation

extension GlossButtonHighlightAnimation where Components == _GlossButtonStrokedSurfaceNode.Components {
  
  public static var basic: GlossButtonHighlightAnimation {
    return .init { (isHighlighted, components) in
      
      let animationKey = "highlight.animation"
      
      if isHighlighted {
                        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [
          {
            let a = CABasicAnimation(keyPath: "opacity")
            a.toValue = 0.5
            return a
          }(),
        ]
        animationGroup.duration = 0.1
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.isRemovedOnCompletion = false
        
        components.borderLayer.add(animationGroup, forKey: animationKey)
        
      } else {
                        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [
          {
            let a = CABasicAnimation(keyPath: "opacity")
            a.fromValue = components.borderLayer.presentation()?.opacity ?? 0.5
            a.toValue = 1
            return a
          }(),
        ]
        animationGroup.duration = 0.2
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.isRemovedOnCompletion = false
        
        components.borderLayer.add(animationGroup, forKey: animationKey)
      }
      
    }
  }
}


public struct GlossButtonStrokedStyle {
  
  public var cornerRound: GlossButtonCornerRound?
  public var strokeColor: UIColor
  public var borderWidth: CGFloat
  public var highlightAnimation: GlossButtonHighlightAnimation<_GlossButtonStrokedSurfaceNode.Components>
  
  public init(
    cornerRound: GlossButtonCornerRound?,
    strokeColor: UIColor,
    borderWidth: CGFloat,
    highlightAnimation: GlossButtonHighlightAnimation<_GlossButtonStrokedSurfaceNode.Components> = .basic
  ) {
    
    self.cornerRound = cornerRound
    self.strokeColor = strokeColor
    self.borderWidth = borderWidth
    self.highlightAnimation = highlightAnimation
  }
}

public final class _GlossButtonStrokedSurfaceNode: ASDisplayNode, _GlossButtonSurfaceNodeType {
  
  public typealias Components = (borderLayer: CALayer, overlayShapeLayer: CAShapeLayer)
  
  public var isHighlighted: Bool = false {
    didSet {
      let components: Components = (borderShapeLayer, overlayShapeLayer)
      strokedStyle?.highlightAnimation.runChangedHighlight(isHighlighted: isHighlighted, components: components)
    }
  }
  
  private lazy var borderShapeLayer = CAShapeLayer()
  private lazy var borderShapeLayerNode: ASDisplayNode = .init { [unowned self] () -> CALayer in
    return self.borderShapeLayer
  }
  
  private lazy var overlayShapeLayer = CAShapeLayer()
  private lazy var overlayShapeLayerNode: ASDisplayNode = .init { [unowned self] () -> CALayer in
    return self.overlayShapeLayer
  }
  
  private var strokedStyle: GlossButtonStrokedStyle?
  
  public override init() {
    super.init()
    
    isUserInteractionEnabled = false
    automaticallyManagesSubnodes = true
  }
  
  public override func didLoad() {
    super.didLoad()
    borderShapeLayer.fillColor = UIColor.clear.cgColor
  }
  
  public override func layout() {
    super.layout()
    
    guard let strokeStyle = strokedStyle else { return }
    
    func __cornerRadius(for layer: CALayer, from cornerRound: GlossButtonCornerRound?) -> CGFloat {
      switch cornerRound {
      case .none:
        return 0
      case let .radius(radius)?:
        return radius
      case .circle?:
        return .infinity// round(min(layer.frame.width, layer.frame.height) / 2)
      }
    }
    
    let path = UIBezierPath(roundedRect: bounds.insetBy(dx: strokeStyle.borderWidth / 2, dy: strokeStyle.borderWidth / 2), cornerRadius: __cornerRadius(for: self.layer, from: strokeStyle.cornerRound))
    
    borderShapeLayer.path = path.cgPath
    borderShapeLayer.lineWidth = strokeStyle.borderWidth
    borderShapeLayer.strokeColor = strokeStyle.strokeColor.cgColor
    
    overlayShapeLayer.path = path.cgPath
    overlayShapeLayer.lineWidth = 0
    overlayShapeLayer.fillColor = UIColor.clear.cgColor
    overlayShapeLayer.strokeColor = UIColor.clear.cgColor
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASWrapperLayoutSpec(layoutElements: [
      overlayShapeLayerNode,
      borderShapeLayerNode,
    ])
  }
  
  public func setStyle(_ strokedStyle: GlossButtonStrokedStyle) {
    
    self.strokedStyle = strokedStyle
    setNeedsLayout()
  }
  
}

//
//  GlossButtonFilledSurfaceNode.swift
//  AppUIKit
//
//  Created by muukii on 2019/09/14.
//  Copyright © 2019 eure. All rights reserved.
//

import Foundation

extension GlossButtonHighlightAnimation where Components == _GlossButtonFilledSurfaceNode.Components {
  
  public static var basic: GlossButtonHighlightAnimation {
    return .init { (isHighlighted, components) in
      
      let animationKey = "highlight.animation"
      
      if isHighlighted {
        
        let duration: CFTimeInterval = 0.1
        
        do {
          let animation = CABasicAnimation(keyPath: "opacity")
          animation.toValue = 0.5
          animation.duration = duration
          animation.fillMode = CAMediaTimingFillMode.forwards
          animation.isRemovedOnCompletion = false
          
          components.shadowLayer.add(animation, forKey: animationKey)
        }
        
        do {
          let animation = CABasicAnimation(keyPath: "opacity")
          animation.toValue = 0.5
          animation.duration = duration
          animation.fillMode = CAMediaTimingFillMode.forwards
          animation.isRemovedOnCompletion = false
          
          components.surfaceLayer.add(animation, forKey: animationKey)
        }
                
      } else {
                
        do {
                    
          let animation = CAAnimationGroup()
          
          animation.animations = [
            {
              let a = CABasicAnimation(keyPath: "opacity")
              a.fromValue = components.shadowLayer.presentation()?.opacity ?? 1
              a.toValue = 1
              return a
            }()
          ]
          animation.duration = 0.2
          animation.fillMode = CAMediaTimingFillMode.forwards
          animation.isRemovedOnCompletion = false
          
          components.shadowLayer.add(animation, forKey: animationKey)
        }
        
        do {
          let animation = CAAnimationGroup()
          
          animation.animations = [
            {
              let a = CABasicAnimation(keyPath: "opacity")
              a.fromValue = components.surfaceLayer.presentation()?.opacity ?? 1
              a.toValue = 1
              return a
            }()
          ]
          animation.duration = 0.2
          animation.fillMode = CAMediaTimingFillMode.forwards
          animation.isRemovedOnCompletion = false
          components.surfaceLayer.add(animation, forKey: animationKey)
        }
      }
            
    }
  }
}

public struct GlossButtonFilledStyle {
  
  public struct DropShadow {
    public let applier: (CALayer) -> Void
    public let isModern: Bool
    
    public init(applier: @escaping (CALayer) -> Void, isModern: Bool) {
      self.applier = applier
      self.isModern = isModern
    }
    
    @available(*, deprecated, renamed: "nil")
    public static var invisible: DropShadow? {
      return nil
    }
  }
  
  public var cornerRound: GlossButtonCornerRound?
  public var backgroundColor: GlossButtonColor?
  public var dropShadow: DropShadow?
  public var highlightAnimation: GlossButtonHighlightAnimation<_GlossButtonFilledSurfaceNode.Components>
  
  public init(
    cornerRound: GlossButtonCornerRound?,
    backgroundColor: GlossButtonColor?,
    dropShadow: DropShadow?,
    highlightAnimation: GlossButtonHighlightAnimation<_GlossButtonFilledSurfaceNode.Components> = .basic
  ) {
    
    self.cornerRound = cornerRound
    self.backgroundColor = backgroundColor
    self.dropShadow = dropShadow
    self.highlightAnimation = highlightAnimation
  }
}


public final class _GlossButtonFilledSurfaceNode: ASDisplayNode, _GlossButtonSurfaceNodeType {
  
  public typealias Components = (
    surfaceLayer: CALayer,
    shadowLayer: CALayer,
    overlayLayer: CALayer
  )
  
  public var isHighlighted: Bool = false {
    didSet {
      
      let components: Components = (surfaceGradientLayer, shadowShapeLayer, overlayLayer)
      fillStyle?.highlightAnimation.runChangedHighlight(isHighlighted: isHighlighted, components: components)
    }
  }
  
  private lazy var shadowShapeLayer = CAShapeLayer()
  
  private lazy var shadowLayerNode: ASDisplayNode = .init { [unowned self] () -> CALayer in
    return self.shadowShapeLayer
  }
  
  private let surfaceMaskNode = ShapeRenderingNode()
  
  private lazy var surfaceGradientLayer = CAGradientLayer()
  private lazy var surfaceLayerNode: ASDisplayNode = .init { [unowned self] () -> CALayer in
    return self.surfaceGradientLayer
  }
  
  private lazy var overlayLayer = CALayer()
  private lazy var overlayLayerNode: ASDisplayNode = .init { [unowned self] () -> CALayer in
    return self.overlayLayer
  }
  
  private var fillStyle: GlossButtonFilledStyle?
  
  public override init() {
    super.init()
    
    isUserInteractionEnabled = false
    automaticallyManagesSubnodes = true
  }
  
  public override func didLoad() {
    super.didLoad()
    surfaceGradientLayer.mask = surfaceMaskNode.layer
    shadowShapeLayer.fillColor = UIColor.clear.cgColor
    overlayLayer.backgroundColor = UIColor.clear.cgColor
    surfaceGradientLayer.addSublayer(overlayLayer)
  }
  
  public override func layout() {
    super.layout()
    
    overlayLayer.frame = surfaceGradientLayer.bounds
    
    guard let fillStyle = fillStyle else { return }
    
    func __cornerRadius(for layer: CALayer, from cornerRound: GlossButtonCornerRound?) -> CGFloat {
      switch cornerRound {
      case .none:
        return 0
      case let .radius(radius)?:
        return radius
      case .circle?:
        let radius = (min(layer.bounds.width, layer.bounds.height))
        return radius
      }
    }
    
    func setBackgroundforegroundColor(_ layer: CAGradientLayer, _ b: GlossButtonColor?) {
      switch b {
      case .none:
        
        layer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        
      case let .fill(color)?:
        
        layer.colors = [color.cgColor, color.cgColor]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        
      case let .gradient(colorAndLocations, startPoint, endPoint)?:
        
        layer.colors = colorAndLocations.map { $0.1.cgColor }
        layer.locations = colorAndLocations.map { NSNumber(value: Double($0.0)) }
        layer.startPoint = startPoint
        layer.endPoint = endPoint
      }
    }
    
    surfaceMaskNode.frame = surfaceGradientLayer.bounds
                            
    surfaceMaskNode.shapePath = UIBezierPath(
      roundedRect: surfaceGradientLayer.bounds,
      cornerRadius: __cornerRadius(for: surfaceGradientLayer, from: fillStyle.cornerRound)
    )
    
    shadowShapeLayer.path = UIBezierPath(
      roundedRect: shadowShapeLayer.bounds,
      cornerRadius: __cornerRadius(for: shadowShapeLayer, from: fillStyle.cornerRound)
    ).cgPath
  
    setBackgroundforegroundColor(surfaceGradientLayer, fillStyle.backgroundColor)
    
    if let dropShadow = fillStyle.dropShadow {
      dropShadow.applier(shadowShapeLayer)
      shadowShapeLayer.shadowPath = shadowShapeLayer.path
    } else {
      shadowShapeLayer.shadowOpacity = 1
      shadowShapeLayer.shadowColor = UIColor.clear.cgColor
      shadowShapeLayer.shadowOffset = .zero
      shadowShapeLayer.shadowRadius = 0
      shadowShapeLayer.shadowPath = nil
    }
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    guard let fillStyle = self.fillStyle else { return ASLayoutSpec() }
    
    let shadowSpec: ASLayoutElement
    
    if let _ = fillStyle.dropShadow?.isModern {
      shadowSpec = ASInsetLayoutSpec(insets: .init(top: 6, left: 6, bottom: 6, right: 6), child: shadowLayerNode)
    } else {
      shadowSpec = shadowLayerNode
    }
    
    return ASWrapperLayoutSpec(
      layoutElements: [
        shadowSpec,
        surfaceLayerNode,
      ]
    )
  }
  
  public func setStyle(_ filledStyle: GlossButtonFilledStyle) {
    
    self.fillStyle = filledStyle
    setNeedsLayout()
  }
  
}

//
//  GlossButtonHighlightSurfaceNode.swift
//  AppUIKit
//
//  Created by muukii on 2019/09/15.
//  Copyright © 2019 eure. All rights reserved.
//

import Foundation

import AsyncDisplayKit

extension GlossButtonHighlightAnimation where Components == GlossButtonHighlightSurfaceNode.Components {
  
  // TODO:
}

public struct GlossButtonHighlightSurfaceStyle {
  
  public var cornerRound: GlossButtonCornerRound?
  public var highlightAnimation: GlossButtonHighlightAnimation<GlossButtonHighlightSurfaceNode.Components>
  
  public init(
    cornerRound: GlossButtonCornerRound?,
    highlightAnimation: GlossButtonHighlightAnimation<GlossButtonHighlightSurfaceNode.Components>
  ) {
    
    self.cornerRound = cornerRound
    self.highlightAnimation = highlightAnimation
  }
}

public final class GlossButtonHighlightSurfaceNode: ASDisplayNode, _GlossButtonSurfaceNodeType {
  
  public typealias Components = (CAShapeLayer)
  
  public var isHighlighted: Bool = false {
    didSet {
      let components: Components = (overlayShapeLayer)
      surfaceStyle?.highlightAnimation.runChangedHighlight(isHighlighted: isHighlighted, components: components)
    }
  }
  
  private lazy var overlayShapeLayer = CAShapeLayer()
  private lazy var overlayShapeLayerNode: ASDisplayNode = .init { [unowned self] () -> CALayer in
    return self.overlayShapeLayer
  }
  
  private var surfaceStyle: GlossButtonHighlightSurfaceStyle?
  
  public override init() {
    super.init()
    
    isUserInteractionEnabled = false
    automaticallyManagesSubnodes = true
  }
  
  public override func layout() {
    super.layout()
    
    guard let surfaceStyle = surfaceStyle else { return }
    
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
    
    let path = UIBezierPath(roundedRect: bounds, cornerRadius: __cornerRadius(for: self.layer, from: surfaceStyle.cornerRound))
        
    overlayShapeLayer.path = path.cgPath
    overlayShapeLayer.lineWidth = 0
    overlayShapeLayer.fillColor = UIColor.clear.cgColor
    overlayShapeLayer.strokeColor = UIColor.clear.cgColor
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASWrapperLayoutSpec(layoutElements: [
      overlayShapeLayerNode,
    ])
  }
  
  public func setStyle(_ strokedStyle: GlossButtonHighlightSurfaceStyle) {
    
    self.surfaceStyle = strokedStyle
    setNeedsLayout()
  }
  
}

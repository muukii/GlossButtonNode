//
//  GlossButtonBodyNode.swift
//  AppUIKit
//
//  Created by muukii on 2019/09/14.
//  Copyright © 2019 eure. All rights reserved.
//

import Foundation

import AsyncDisplayKit

extension GlossButtonHighlightAnimation where Components == _GlossButtonBodyNode.Components {
  
  public static var noAnimation: GlossButtonHighlightAnimation {
    return .init { (isHighlighted, components) in }
  }
  
  public static var basic: GlossButtonHighlightAnimation {
    return .init { (isHighlighted, components) in
            
      if isHighlighted {
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState], animations: {
          components.imageNode.alpha = 0.5
          components.titleNode.alpha = 0.5
        }, completion: nil)
        
      } else {
        
        UIView.animate(withDuration: 0.16, delay: 0, options: [.beginFromCurrentState], animations: {
          components.imageNode.alpha = 1
          components.titleNode.alpha = 1
        }, completion: nil)
        
      }
      
    }
  }
}

public final class _GlossButtonBodyNode: ASDisplayNode {
  
  public typealias Components = (imageNode: ASDisplayNode, titleNode: ASDisplayNode)
  
  public var isHighlighted: Bool = false {
    didSet {
      let components: Components = (imageNode, titleNode)
      bodyStyle?.highlightAnimation.runChangedHighlight(isHighlighted: isHighlighted, components: components)
    }
  }
  
  private let imageNode = ASImageNode()
  private let titleNode = ASTextNode()
  
  private var bodyStyle: GlossButtonBodyStyle?
  
  public override init() {
    super.init()
    
    imageNode.contentMode = .center
    automaticallyManagesSubnodes = true
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    guard let bodyLayout = bodyStyle?.layout else {
      return ASLayoutSpec()
    }
    
    let _imageNode = imageNode.image != nil ? imageNode : nil
    let _titleNode = titleNode.attributedText.map({ $0.string.isEmpty == false }) ?? false ? titleNode : nil
    
    return bodyLayout.makeLayoutSpec(imageNode: _imageNode, titleNode: _titleNode)
  }
  
  public func setBodyStyle(_ bodyStyle: GlossButtonBodyStyle) {
    self.bodyStyle = bodyStyle
    setNeedsLayout()
  }
  
  public func setImage(_ image: UIImage?) {
    self.imageNode.image = image
    setNeedsLayout()
  }
  
  public func setTitle(_ title: NSAttributedString?) {
    self.titleNode.attributedText = title
    setNeedsLayout()
  }
  
}

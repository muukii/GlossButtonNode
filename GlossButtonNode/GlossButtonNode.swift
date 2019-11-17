//
//  Element.GlossButtonNode.swift
//  pairs-global
//
//  Created by muukii on 12/21/16.
//  Copyright © 2016 eure. All rights reserved.
//

import Foundation

import AsyncDisplayKit

/// Button component ASDisplayNode based
///
/// - TODO:
///   - Improve shape of structure that describing style.
public final class GlossButtonNode : ASControlNode {
    
  // MARK: - Properties
  
  public struct ControlState: OptionSet {
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }
          
    public var rawValue: Int
    
    public typealias RawValue = Int
        
    public static let normal = ControlState(rawValue: 1 << 0)
    public static let disabled = ControlState(rawValue: 1 << 1)
    public static let selected = ControlState(rawValue: 1 << 2)
  }
  
  public override var supportsLayerBacking: Bool {
    return false
  }
  
  private let bodyNode = _GlossButtonBodyNode()
  
  public var isProcessing: Bool {
    get {
      return _isProcessing
    }
    set {
      
      ASPerformBlockOnMainThread {
        
        self.prepareLoadingIndicatorIfNeeded()
      
        self._isProcessing = newValue
        
        self.indicator.style = self.currentDescriptor?.indicatorViewStyle ?? .white
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
          
          if newValue {
            
            self.bodyNode.alpha = 0
            self.bodyNode.transform = CATransform3DMakeScale(0.9, 0.9, 1)
            self.indicator.startAnimating()
            
            self.indicatorNode.transform = CATransform3DMakeScale(0.8, 0.8, 1)
            self.indicatorNode.transform = CATransform3DIdentity
            self.indicatorNode.alpha = 1
            self.isUserInteractionEnabled = false
            
          } else {
            
            self.bodyNode.alpha = 1
            self.bodyNode.transform = CATransform3DIdentity
            self.indicator.stopAnimating()
            
            self.indicatorNode.transform = CATransform3DMakeScale(0.8, 0.8, 1)
            self.indicatorNode.alpha = 0
            self.isUserInteractionEnabled = true
          }
        }, completion: { _ in
        })
      }
      
    }
  }
  
  private var _isProcessing: Bool = false
  
  public override var isSelected: Bool {
    didSet {
      if oldValue != isSelected {
        updateThatFitsState()
      }
    }
  }
  
  public override var isEnabled: Bool {
    didSet {
      if oldValue != isEnabled {
        isUserInteractionEnabled = isEnabled
        updateThatFitsState()
      }
    }
  }
  
  public override var isHighlighted: Bool {
    didSet {
      guard oldValue != isHighlighted else { return }
      bodyNode.isHighlighted = isHighlighted
      filledSurfaceNode?.isHighlighted = isHighlighted
      strokedSurfaceNode?.isHighlighted = isHighlighted
      highlightSurfaceNode?.isHighlighted = isHighlighted
    }
  }
  
  private lazy var indicatorNode: ASDisplayNode = ASDisplayNode { () -> UIView in
    return UIActivityIndicatorView(style: .white)
  }
  
  private var indicator: UIActivityIndicatorView {
    return indicatorNode.view as! UIActivityIndicatorView
  }
    
  private var descriptorStorage: [ControlState.RawValue : GlossButtonDescriptor] = [:]
  private var currentDescriptor: GlossButtonDescriptor?
  
  private var filledSurfaceNode: _GlossButtonFilledSurfaceNode?
  private var strokedSurfaceNode: _GlossButtonStrokedSurfaceNode?
  private var highlightSurfaceNode: GlossButtonHighlightSurfaceNode?
  
  private var needsLayoutLoadingIndicator: Bool = false
  
  // MARK: - Initializers
  
  public override init() {
    super.init()
    
    automaticallyManagesSubnodes = true
  }
  
  // MARK: - Functions
  
  public func setDescriptor(
    _ descriptor: GlossButtonDescriptor,
    for state: ControlState,
    animated: Bool = false
  ) {
    
    if animated {
      let snapshot = self.view.snapshotView(afterScreenUpdates: false) ?? UIView()
      view.addSubview(snapshot)
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
        
        snapshot.alpha = 0

      }, completion: { _ in
        snapshot.removeFromSuperview()
      })
    }
    
    descriptorStorage[state.rawValue] = descriptor
    updateThatFitsState()
  }
  
  public override func layout() {
    super.layout()
  }
  
  public override func didLoad() {
    super.didLoad()
    
    isUserInteractionEnabled = true
    indicatorNode.backgroundColor = .clear
    indicatorNode.alpha = 0
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    guard let targetDescriptor = currentDescriptor else {
      return ASWrapperLayoutSpec(layoutElements: [])
    }
    
    var indicator: ASDisplayNode?
    if needsLayoutLoadingIndicator {
      indicator = indicatorNode
    }
            
    return ASInsetLayoutSpec(
      insets: targetDescriptor.boundPadding,
      child: ASBackgroundLayoutSpec(
        child: ASWrapperLayoutSpec(layoutElements: [
          indicator.flatMap {
            ASCenterLayoutSpec(
              horizontalPosition: .center,
              verticalPosition: .center,
              sizingOption: .minimumSize, child: $0
            )
          },
          ASInsetLayoutSpec(
            insets: targetDescriptor.insets,
            child: bodyNode
          ),
          ].compactMap { $0 } as [ASLayoutElement]
        ),
        background: ASWrapperLayoutSpec(layoutElements: [
          filledSurfaceNode,
          strokedSurfaceNode,
          highlightSurfaceNode,
          ].compactMap { $0 } as [ASLayoutElement]
        )
      )
    )
         
  }
  
  private func updateThatFitsState() {
    
    let findDescriptor: (ControlState) -> GlossButtonDescriptor? = { state in
      self.descriptorStorage.first {
        ControlState(rawValue: $0.key) == state
        }?.value
    }
    
    let normalDescriptor = findDescriptor([.normal])
    
    let targetDescriptor: GlossButtonDescriptor?
    
    switch (isSelected, isEnabled) {
    case (true, true):
      targetDescriptor = findDescriptor([.selected]) ?? normalDescriptor
    case (true, false):
      targetDescriptor = findDescriptor([.selected, .disabled]) ?? findDescriptor([.disabled]) ?? normalDescriptor
    case (false, false):
      targetDescriptor = findDescriptor([.disabled]) ?? {
        var d = normalDescriptor
        d?.bodyOpacity = 0.7
        return d
        }()
    case (false, true):
      targetDescriptor = normalDescriptor
    }
    
    guard let d = targetDescriptor else {
      return
    }
    
    currentDescriptor = d
    
    switch d.surfaceStyle {
    case .fill(let style):
      
      let node = self.filledSurfaceNode ?? .init()
      node.setStyle(style)
      self.filledSurfaceNode = node
      self.strokedSurfaceNode = nil
      self.highlightSurfaceNode = nil
      
    case .stroke(let style):
      
      let node = self.strokedSurfaceNode ?? .init()
      node.setStyle(style)
      self.strokedSurfaceNode = node
      
      self.filledSurfaceNode = nil
      self.highlightSurfaceNode = nil
      
    case .highlight(let style):
      
      let node = self.highlightSurfaceNode ?? .init()
      node.setStyle(style)
      self.highlightSurfaceNode = node
      
      self.filledSurfaceNode = nil
      self.strokedSurfaceNode = nil
      
    }
    
    bodyNode.setImage(d.image)
    bodyNode.setTitle(d.title)
    bodyNode.setBodyStyle(d.bodyStyle)
    
    alpha = d.bodyOpacity
    
    setNeedsLayout()
    setNeedsDisplay()
    
  }
  
  private func prepareLoadingIndicatorIfNeeded() {
    guard needsLayoutLoadingIndicator == false else { return }
    
    needsLayoutLoadingIndicator = true
    setNeedsLayout()
    layoutIfNeeded()
  }
}


protocol _GlossButtonSurfaceNodeType: ASDisplayNode {
      
  var isHighlighted: Bool { get set }
}

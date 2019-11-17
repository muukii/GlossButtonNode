//
//  GlossButtonDescriptor.swift
//  AppUIKit
//
//  Created by muukii on 2019/09/14.
//  Copyright © 2019 eure. All rights reserved.
//

import Foundation

public struct GlossButtonDescriptor {
    
  public var image: UIImage?
  public var title: NSAttributedString?
  
  public var boundPadding: UIEdgeInsets = .zero
  // Body padding
  public var insets: UIEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)

  public var bodyStyle: GlossButtonBodyStyle
  public var surfaceStyle: GlossButtonSurfaceStyle

  public var indicatorViewStyle: UIActivityIndicatorView.Style
  public var bodyOpacity: CGFloat
  
  public init(
    title: NSAttributedString? = nil,
    image: UIImage? = nil,
    bodyStyle: GlossButtonBodyStyle,
    surfaceStyle: GlossButtonSurfaceStyle,
    bodyOpacity: CGFloat = 1,
    insets: UIEdgeInsets? = nil,
    indicatorViewStyle: UIActivityIndicatorView.Style = .white
  ) {
    
    self.title = title
    self.image = image
    self.bodyOpacity = bodyOpacity
    if let insets = insets {
      self.insets = insets
    }
    self.surfaceStyle = surfaceStyle
    self.bodyStyle = bodyStyle
    self.indicatorViewStyle = indicatorViewStyle
  }
  
  @available(*, deprecated)
  public init(
    title: NSAttributedString? = nil,
    image: UIImage? = nil,
    bodyLayout: GlossButtonBodyLayout,
    boundsStyle: GlossButtonSurfaceStyle,
    bodyOpacity: CGFloat = 1,
    insets: UIEdgeInsets? = nil,
    indicatorViewStyle: UIActivityIndicatorView.Style = .white
  ) {
    
    self.title = title
    self.image = image
    self.bodyOpacity = bodyOpacity
    if let insets = insets {
      self.insets = insets
    }
    self.surfaceStyle = boundsStyle
    self.bodyStyle = .init(layout: bodyLayout)
    self.indicatorViewStyle = indicatorViewStyle
  }
  
}

// MARK: - Modifying Method Chain
extension GlossButtonDescriptor {
  
  public func title(_ title: NSAttributedString?) -> GlossButtonDescriptor {
    var m = self
    m.title = title
    return m
  }
  
  public func image(_ image: UIImage?) -> GlossButtonDescriptor {
    var m = self
    m.image = image
    return m
  }
  
  public func insets(_ insets: UIEdgeInsets) -> GlossButtonDescriptor {
    var m = self
    m.insets = insets
    return m
  }
  
  public func boundPadding(_ boundPadding: UIEdgeInsets) -> GlossButtonDescriptor {
    var m = self
    m.boundPadding = boundPadding
    return m
  }
  
  public func bodyOpacity(_ opacity: CGFloat) -> GlossButtonDescriptor {
    var m = self
    m.bodyOpacity = bodyOpacity
    return m
  }
  
  public func surfaceStyle(_ sufaceStyle: GlossButtonSurfaceStyle) -> Self {
    var m = self
    m.surfaceStyle = sufaceStyle
    return m
  }
  
}

public enum GlossButtonColor {
  case fill(UIColor)
  case gradient(colorAndLocations: [(CGFloat, UIColor)], startPoint: CGPoint, endPoint: CGPoint)
}

public enum GlossButtonCornerRound {
  case circle
  case radius(CGFloat)
}

public enum GlossButtonSurfaceStyle {
  
  /// workaround
  public static var translucentHighlight: GlossButtonSurfaceStyle {
    return .stroke(.init(cornerRound: nil, strokeColor: .clear, borderWidth: 0))
  }
  
  @available(*, deprecated)
  public static var highlightOnly: GlossButtonSurfaceStyle {
    return .stroke(.init(cornerRound: nil, strokeColor: .clear, borderWidth: 0))
  }
  
  case fill(GlossButtonFilledStyle)
  case stroke(GlossButtonStrokedStyle)
  // We want more good name
  case highlight(GlossButtonHighlightSurfaceStyle)
 
}

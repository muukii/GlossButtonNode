//
//  GlossButtonSurfaceHighlightAnimation.swift
//  AppUIKit
//
//  Created by muukii on 2019/09/14.
//  Copyright © 2019 eure. All rights reserved.
//

import Foundation

public struct GlossButtonHighlightAnimation<Components> {
  
  public typealias Animation = (_ isHighlited: Bool, _ components: Components) -> Void
  
  private let onChangedHighlight: Animation
  
  public init(onChangedHighlight: @escaping Animation) {
    self.onChangedHighlight = onChangedHighlight
  }
  
  func runChangedHighlight(isHighlighted: Bool, components: Components) {
    onChangedHighlight(isHighlighted, components)
  }
  
}

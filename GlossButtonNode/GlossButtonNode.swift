import AsyncDisplayKit

public final class GlossButtonNode : ASControlNode {

  // MARK: - Properties

  public var isProcessing: Bool {
    get {
      return _isProcessing
    }
    set {

      assert(Thread.isMainThread)

      addIndicatorNode = true
      _isProcessing = newValue

      indicator.activityIndicatorViewStyle = currentDescriptor?.indicatorViewStyle ?? .white

      UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {

        if newValue {

          self.titleNode.alpha = 0
          self.imageNode.alpha = 0
          self.titleNode.transform = CATransform3DMakeScale(0.9, 0.9, 1)
          self.imageNode.transform = CATransform3DMakeScale(0.9, 0.9, 1)
          self.indicator.startAnimating()

          self.indicatorNode.transform = CATransform3DMakeScale(0.8, 0.8, 1)
          self.indicatorNode.transform = CATransform3DIdentity
          self.indicatorNode.alpha = 1
          self.isUserInteractionEnabled = false

        } else {

          self.titleNode.alpha = 1
          self.imageNode.alpha = 1
          self.titleNode.transform = CATransform3DIdentity
          self.imageNode.transform = CATransform3DIdentity
          self.indicator.stopAnimating()

          self.indicatorNode.transform = CATransform3DMakeScale(0.8, 0.8, 1)
          self.indicatorNode.alpha = 0
          self.isUserInteractionEnabled = true
        }
      }, completion: { _ in
      })
    }
  }

  private var _isProcessing: Bool = false

  public override var isSelected: Bool {
    didSet {
      if oldValue != isSelected {
        update()
      }
    }
  }

  public override var isEnabled: Bool {
    didSet {
      if oldValue != isEnabled {
        isUserInteractionEnabled = isEnabled
        alpha = isEnabled ? 1 : 0.7
      }
    }
  }

  public override var isHighlighted: Bool {
    get {
      return super.isHighlighted
    }
    set {
      guard super.isHighlighted != newValue else { return }

      let animationKey = "highlight.animation"

      guard let style = isSelected ? selectedStyle : normalStyle else {
        return
      }

      switch style {
      case .highlightOnly:

        shadowLayer.removeAnimation(forKey: animationKey)

        if newValue {

          let animation = CAAnimationGroup()
          animation.animations = [
            {
              let a = CABasicAnimation(keyPath: "opacity")
              a.toValue = 1
              return a
            }(),
            {
              let a = CABasicAnimation(keyPath: "transform.scale.xy")
              a.fromValue = 0.85
              a.toValue = 1
              return a
            }(),
          ]
          animation.duration = 0.12
          animation.fillMode = kCAFillModeForwards
          animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
          animation.isRemovedOnCompletion = false

          backdropHighlightLayer.add(animation, forKey: animationKey)

        } else {

          let animation = CAAnimationGroup()
          animation.animations = [
            {
              let a = CABasicAnimation(keyPath: "opacity")
              a.fromValue = 1
              a.toValue = 0
              return a
            }(),
            {
              let a = CABasicAnimation(keyPath: "transform.scale.xy")
              a.fromValue = 1
              a.toValue = 0.98
              return a
            }(),
          ]
          animation.duration = 0.18
          animation.fillMode = kCAFillModeForwards
          animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
          animation.isRemovedOnCompletion = false

          backdropHighlightLayer.add(animation, forKey: animationKey)

        }

      case .fill, .stroke:
        if newValue {

          let animation = CAAnimationGroup()
          animation.animations = [
            {
              let a = CABasicAnimation(keyPath: "shadowOpacity")
              a.toValue = 0
              return a
            }(),
          ]
          animation.duration = 0.15
          animation.fillMode = kCAFillModeForwards
          animation.isRemovedOnCompletion = false

          shadowLayer.add(animation, forKey: animationKey)

          UIView.animate(withDuration: 0.15, delay: 0, options: [], animations: {
            self.titleNode.alpha = 0.5
            self.imageNode.alpha = 0.5
          }, completion: nil)

        } else {

          let animation = CAAnimationGroup()

          animation.animations = [
            {
              let a = CABasicAnimation(keyPath: "shadowOpacity")
              a.fromValue = 0
              a.toValue = 1
              return a
            }()
          ]
          animation.duration = 0.2
          animation.fillMode = kCAFillModeForwards
          animation.isRemovedOnCompletion = false

          shadowLayer.add(animation, forKey: animationKey)

          if isProcessing == false {
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
              self.titleNode.alpha = 1
              self.imageNode.alpha = 1
            }, completion: nil)
          }
        }
      }

      super.isHighlighted = newValue
    }
  }

  public var padding: UIEdgeInsets = .zero {
    didSet {
      setNeedsLayout()
    }
  }

  public var bodyLayout: BodyLayout = .horizontal() {
    didSet {
      setNeedsLayout()
    }
  }

  public var normalStyle: BoundsStyle? {
    didSet {
      setNeedsLayout()
    }
  }

  public var selectedStyle: BoundsStyle? {
    didSet {
      setNeedsLayout()
    }
  }

  public var edgeInsets: UIEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10) {
    didSet {
      setNeedsLayout()
    }
  }

  private lazy var shadowLayer = CAGradientLayer()
  private lazy var backdropGradientLayer = CAGradientLayer()
  private lazy var backdropHighlightLayer = CAShapeLayer()

  private var currentDescriptor: Descriptor?

  private lazy var shadowNode: ASDisplayNode = .init { [unowned self] () -> CALayer in
    return self.shadowLayer
  }

  private lazy var backdropNode: ASDisplayNode = .init { [unowned self] () -> CALayer in
    return self.backdropGradientLayer
  }

  private lazy var backdropHighlightNode: ASDisplayNode = .init { [unowned self] () -> CALayer in
    return self.backdropHighlightLayer
  }

  private let borderNode = ASDisplayNode()
  private let imageNode = ASImageNode()
  private let titleNode = ASTextNode()

  private lazy var indicatorNode: ASDisplayNode = ASDisplayNode { () -> UIView in
    return UIActivityIndicatorView(activityIndicatorStyle: .white)
  }

  private var indicator: UIActivityIndicatorView {
    return indicatorNode.view as! UIActivityIndicatorView
  }

  private var addIndicatorNode: Bool = false {
    didSet {
      setNeedsLayout()
    }
  }

  // MARK: - Initializers

  public override init() {
    super.init()

    automaticallyManagesSubnodes = true
    backdropNode.isUserInteractionEnabled = false
    borderNode.isUserInteractionEnabled = false

  }

  // MARK: - Functions

  public func set(descriptor: Descriptor) {

    currentDescriptor = descriptor

    normalStyle = descriptor.normalStyle
    selectedStyle = descriptor.selectedStyle
    set(title: descriptor.title, image: descriptor.image)
    bodyLayout = descriptor.bodyLayout

    if let insets = descriptor.insets {
      edgeInsets = insets
    }
  }

  public func set(title: NSAttributedString?, image: UIImage?) {
    titleNode.attributedText = title
    imageNode.image = image
    setNeedsLayout()
  }

  public override func layout() {
    super.layout()
    update()
  }

  public override func didLoad() {
    super.didLoad()

    isUserInteractionEnabled = true
    indicatorNode.backgroundColor = .clear
    indicatorNode.alpha = 0

    backdropHighlightLayer.opacity = 0
    backdropHighlightLayer.fillColor = UIColor(white: 0.96, alpha: 1).cgColor

  }

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    imageNode.contentMode = .center

    let bodyLayoutSpec = { () -> ASLayoutSpec in
      switch (imageNode.image != nil, titleNode.attributedText.map({ $0.string.isEmpty == false }) ?? false) {
      case (true, true):
        return bodyLayout.makeLayoutSpec(imageNode: imageNode, titleNode: titleNode)
      case (false, true):
        return bodyLayout.makeLayoutSpec(imageNode: nil, titleNode: titleNode)
      case (true, false):
        return bodyLayout.makeLayoutSpec(imageNode: imageNode, titleNode: nil)
      case (false, false):
        return bodyLayout.makeLayoutSpec(imageNode: nil, titleNode: nil)
      }
    }()

    let body = ASInsetLayoutSpec(
      insets: edgeInsets,
      child: bodyLayoutSpec
    )

    let indicatorSpec: ASLayoutSpec

    // To lazy initialize
    if addIndicatorNode {

      indicatorSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: indicatorNode)
    } else {

      indicatorSpec = ASLayoutSpec()
    }

    let content = ASBackgroundLayoutSpec(
      child: ASBackgroundLayoutSpec(
        child: ASBackgroundLayoutSpec(
          child: ASBackgroundLayoutSpec(
            child: body,
            background: borderNode
          ),
          background: indicatorSpec
        ),
        background: ASWrapperLayoutSpec(
          layoutElements: [
            backdropNode,
            backdropHighlightNode
          ]
        )
      ),
      background: shadowNode
    )

    return ASInsetLayoutSpec(
      insets: padding,
      child: content
    )

  }

  private func update() {

    guard bounds.size != .zero else { return }

    guard let style = isSelected ? selectedStyle : normalStyle else {
      return
    }

    func setCornerRadius(_ layer: CALayer, _ r: CornerRound) {
      switch r {
      case .none:
        layer.cornerRadius = 0
      case let .radius(radius):
        layer.cornerRadius = radius
      case .circle:
        layer.cornerRadius = round(min(backdropNode.frame.width, backdropNode.frame.height) / 2)
      }
    }

    switch style {
    case .highlightOnly:

      let path = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat.greatestFiniteMagnitude)
      backdropHighlightLayer.path = path.cgPath

    case .fill(let fillStyle):

      func setBackgroundforegroundColor(_ layer: CAGradientLayer, _ b: Color) {
        switch b {
        case .none:

          layer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
          layer.locations = [0, 1]
          layer.startPoint = CGPoint(x: 0, y: 0)
          layer.endPoint = CGPoint(x: 1, y: 1)

        case let .fill(color):

          layer.colors = [color.cgColor, color.cgColor]
          layer.locations = [0, 1]
          layer.startPoint = CGPoint(x: 0, y: 0)
          layer.endPoint = CGPoint(x: 1, y: 1)

        case let .gradient(colorAndLocations, startPoint, endPoint):

          layer.colors = colorAndLocations.map { $0.1.cgColor }
          layer.locations = colorAndLocations.map { NSNumber(value: Double($0.0)) }
          layer.startPoint = startPoint
          layer.endPoint = endPoint
        }
      }

      backdropGradientLayer.isHidden = false
      shadowLayer.isHidden = false

      backdropGradientLayer.masksToBounds = true
      setCornerRadius(backdropGradientLayer, fillStyle.cornerRound)
      setCornerRadius(shadowLayer, fillStyle.cornerRound)

      setBackgroundforegroundColor(backdropGradientLayer, fillStyle.backgroundColor)
      setBackgroundforegroundColor(shadowLayer, fillStyle.backgroundColor)

      borderNode.layer.borderWidth = 0

      if let applyDropShadow = fillStyle.applyDropShadow {
        applyDropShadow(shadowLayer)
      } else {
        shadowLayer.shadowRadius = 0
        shadowLayer.shadowOpacity = 0
      }

    case .stroke(let strokeStyle):

      backdropGradientLayer.isHidden = true
      shadowLayer.isHidden = true
      shadowLayer.isHidden = true

      backdropGradientLayer.masksToBounds = false

      setCornerRadius(backdropGradientLayer, strokeStyle.cornerRound)
      setCornerRadius(borderNode.layer, strokeStyle.cornerRound)

      borderNode.layer.borderWidth = strokeStyle.borderWidth
      borderNode.layer.borderColor = strokeStyle.strokeColor.cgColor

    }
  }
}

extension GlossButtonNode {

  public struct BodyLayout {

    public typealias Compose<T: ASDisplayNode> = (T) -> ASLayoutElement

    private let _layoutSpecFactory: (_ imageNode: ASLayoutElement?, _ titleNode: ASLayoutElement?) -> ASLayoutSpec

    private var composeImageNode: Compose<ASImageNode> = { $0 }
    private var composeTitleNode: Compose<ASTextNode> = { $0 }

    public init(_ layoutSpecFactory: @escaping (_ imageNode: ASLayoutElement?, _ titleNode: ASLayoutElement?) -> ASLayoutSpec) {
      self._layoutSpecFactory = layoutSpecFactory
    }

    public func set(composeImageNode: @escaping Compose<ASImageNode>) -> BodyLayout {

      var _self = self
      _self.composeImageNode = composeImageNode
      return _self
    }

    public func set(composeTitleNode: @escaping Compose<ASTextNode>) -> BodyLayout {

      var _self = self
      _self.composeTitleNode = composeTitleNode
      return _self
    }

    fileprivate func makeLayoutSpec(imageNode: ASImageNode?, titleNode: ASTextNode?) -> ASLayoutSpec {

      return _layoutSpecFactory(imageNode.map(composeImageNode), titleNode.map(composeTitleNode))
    }

    public static func vertical(imageEdgeInsets: UIEdgeInsets = .zero, titleEdgeInsets: UIEdgeInsets = .zero) -> BodyLayout {

      return BodyLayout.init { imageNode, titleNode in
        return _axisLayout(direction: .vertical, imageNode: imageNode, titleNode: titleNode, imageEdgeInsets: imageEdgeInsets, titleEdgeInsets: titleEdgeInsets)
      }
    }

    public static func horizontal(imageEdgeInsets: UIEdgeInsets = .zero, titleEdgeInsets: UIEdgeInsets = .zero) -> BodyLayout {

      return BodyLayout.init { imageNode, titleNode in
        return _axisLayout(direction: .horizontal, imageNode: imageNode, titleNode: titleNode, imageEdgeInsets: imageEdgeInsets, titleEdgeInsets: titleEdgeInsets)
      }
    }

    private static func _axisLayout(
      direction: ASStackLayoutDirection,
      imageNode: ASLayoutElement?,
      titleNode: ASLayoutElement?,
      imageEdgeInsets: UIEdgeInsets,
      titleEdgeInsets: UIEdgeInsets
      ) -> ASLayoutSpec {

      let bodyLayoutSpec: ASStackLayoutSpec

      let titleNodeInsetSpec = titleNode.map { ASInsetLayoutSpec(insets: titleEdgeInsets, child: $0) }
      let imageNodeInsetSpec = imageNode.map { ASInsetLayoutSpec(insets: imageEdgeInsets, child: $0) }

      switch (imageNodeInsetSpec, titleNodeInsetSpec) {
      case let (imageNode?, titleNode?):

        bodyLayoutSpec = ASStackLayoutSpec(
          direction: direction,
          spacing: 2,
          justifyContent: .center,
          alignItems: .center,
          children: [
            imageNode,
            titleNode,
            ]
        )

        bodyLayoutSpec.horizontalAlignment = .middle
        bodyLayoutSpec.verticalAlignment = .center

      case let (nil, titleNode?):

        bodyLayoutSpec = ASStackLayoutSpec(
          direction: direction,
          spacing: 0,
          justifyContent: .center,
          alignItems: .center,
          children: [
            titleNode,
            ]
        )

        bodyLayoutSpec.horizontalAlignment = .middle
        bodyLayoutSpec.verticalAlignment = .center

      case let (imageNode?, nil):

        bodyLayoutSpec = ASStackLayoutSpec(
          direction: direction,
          spacing: 0,
          justifyContent: .center,
          alignItems: .center,
          children: [
            imageNode,
            ]
        )

        bodyLayoutSpec.horizontalAlignment = .middle
        bodyLayoutSpec.verticalAlignment = .center

      case (nil, nil):
        bodyLayoutSpec = ASStackLayoutSpec.horizontal()
      }

      bodyLayoutSpec.style.flexGrow = 1

      return bodyLayoutSpec
    }
  }

}

public extension GlossButtonNode {

  public enum Color {
    case none
    case fill(UIColor)
    case gradient(colorAndLocations: [(CGFloat, UIColor)], startPoint: CGPoint, endPoint: CGPoint)
  }

  public enum CornerRound {
    case none
    case circle
    case radius(CGFloat)
  }

  public enum BoundsStyle {
    case fill(Fill)
    case stroke(Stroke)
    case highlightOnly

    public struct Fill {

      public let cornerRound: CornerRound
      public let backgroundColor: Color
      public let applyDropShadow: ((CALayer) -> Void)?

      public init(
        cornerRound: CornerRound,
        backgroundColor: Color,
        applyDropShadow: ((CALayer) -> Void)? = nil
        ) {

        self.cornerRound = cornerRound
        self.backgroundColor = backgroundColor
        self.applyDropShadow = applyDropShadow
      }
    }

    public struct Stroke {

      public let cornerRound: CornerRound
      public let strokeColor: UIColor
      public let borderWidth: CGFloat

      public init(
        cornerRound: CornerRound,
        strokeColor: UIColor,
        borderWidth: CGFloat
        ) {

        self.cornerRound = cornerRound
        self.strokeColor = strokeColor
        self.borderWidth = borderWidth
      }
    }
  }

}

extension GlossButtonNode {

  public struct Descriptor {

    public var normalStyle: BoundsStyle
    public var selectedStyle: BoundsStyle?
    public var image: UIImage?
    public var title: NSAttributedString?
    public var bodyLayout: BodyLayout
    public var insets: UIEdgeInsets?
    public var indicatorViewStyle: UIActivityIndicatorViewStyle?

    public init(
      title: NSAttributedString?,
      image: UIImage?,
      bodyLayout: BodyLayout,
      normalStyle: BoundsStyle,
      selectedStyle: BoundsStyle? = nil,
      insets: UIEdgeInsets? = nil,
      indicatorViewStyle: UIActivityIndicatorViewStyle? = nil) {

      self.title = title
      self.image = image
      self.insets = insets
      self.normalStyle = normalStyle
      self.selectedStyle = selectedStyle
      self.bodyLayout = bodyLayout
      self.indicatorViewStyle = indicatorViewStyle
    }
  }
}

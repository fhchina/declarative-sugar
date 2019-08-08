/*
 DeclarativeViewController -> Context -> Stack -> StackItem
 */

import UIKit

public protocol DZWidget: UIView {}
extension UIView: DZWidget {}

public protocol DZSingleChildWidget: DZWidget {
    var child: DZWidget { get set }
}

public protocol DZStackableWidget: DZWidget {
    var children: [DZWidget] { get set }
    var stackView: UIStackView { get set }
}

extension DZStackableWidget {
    public func buildStackView() {
        var previousView: UIView?
        for viewType in children {
            if let spacing = viewType as? DZSpacer {
                let spacingValue = spacing.spacing
                if let previousView = previousView {
                    stackView.addCustomSpacing(spacingValue, after: previousView)
                }
                else {
                    let mockView = UIView()
                    stackView.addArrangedSubview(mockView)
                    previousView = mockView
                    stackView.addCustomSpacing(spacingValue, after: mockView)
                }
            }
            stackView.addArrangedSubview(viewType)
            previousView = viewType
        }
    }
}


public class DZSpacer: UIView {
    
    public var spacing: CGFloat
    
    public init(_ spacing: CGFloat) {
        self.spacing = spacing
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class DZContext {
    public var rootWidget: DZWidget
    
    public init(rootWidget: DZWidget) {
        self.rootWidget = rootWidget
    }
    
    public func setHidden(_ hidden: Bool, for view: UIView) {
        guard
            let currentStackView = findCurrentStackView(item: view)
            else { return }
        currentStackView.setHidden(hidden, arrangedSubview: view)
    }
    
    public func setSpacing(_ newValue: CGFloat, for spacer: DZSpacer) {
        guard
            let currentStackView = findCurrentStackView(item: spacer)
            else { return }
        spacer.spacing = newValue
        if let view = findPreviousView(spacer) {
            currentStackView.addCustomSpacing(spacer.spacing, after: view)
        }
    }
    
    public var rootView: UIView {
        if let single = rootWidget as? DZSingleChildWidget {
            return single
        }
        
        if let stackable = rootWidget as? DZStackableWidget {
            return stackable.stackView
        }
        
        return rootWidget
    }
    
    private func findCurrentStackView(item: DZWidget) -> UIStackView? {
        return item.superview as? UIStackView
    }
    
    private func findPreviousView(_ item: DZWidget) -> UIView? {
        guard
            let currentStackView = findCurrentStackView(item: item),
            let currentIndex = currentStackView.arrangedSubviews.firstIndex(where: { $0 === item })
            else { return nil }
        return currentStackView.arrangedSubviews[0...currentIndex].last
    }
    
}


public class DZRow: UIView, DZStackableWidget {
    
    public var children: [DZWidget]
    public var stackView = UIStackView()
    public init(mainAxisAlignment: UIStackView.Distribution = .fill,
                crossAxisAlignment: UIStackView.Alignment = .leading,
                children: [DZWidget?]) {
        self.children = children.compactMap {$0}
        super.init(frame: .zero)
        
        addSubview(stackView)
        stackView.alignment = crossAxisAlignment
        stackView.distribution = mainAxisAlignment
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: .directionMask, metrics: nil, views: ["stackView":stackView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: .directionMask, metrics: nil, views: ["stackView":stackView]))
        buildStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public class DZColumn: UIView, DZStackableWidget {
    
    public var children: [DZWidget]
    public var stackView = UIStackView()
    
    public init(mainAxisAlignment: UIStackView.Distribution? = .fill,
                crossAxisAlignment: UIStackView.Alignment? = .fill,
                children: [DZWidget?])  {
        self.children = children.compactMap {$0}
        super.init(frame: .zero)
        
        addSubview(stackView)
        stackView.alignment = crossAxisAlignment ?? .fill
        stackView.distribution = mainAxisAlignment ?? .fill
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: .directionMask, metrics: nil, views: ["stackView":stackView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: .directionMask, metrics: nil, views: ["stackView":stackView]))
        buildStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



public struct DZEdgeInsets {
    
    public var left: CGFloat?
    public var top: CGFloat?
    public var right: CGFloat?
    public var bottom: CGFloat?
    public static func only(left: CGFloat? = nil,
                            top: CGFloat? = nil,
                            right: CGFloat? = nil,
                            bottom: CGFloat? = nil) -> DZEdgeInsets {
        var edgeInsets = DZEdgeInsets()
        edgeInsets.left = left
        edgeInsets.top = top
        edgeInsets.right = right
        edgeInsets.bottom = bottom
        return edgeInsets
    }
    
    public static func fromLTRB(left: CGFloat?, top: CGFloat?, right: CGFloat?, bottom: CGFloat?) -> DZEdgeInsets {
        return only(left: left, top: top, right: right, bottom: bottom)
    }
    
    public static func all(_ value: CGFloat) -> DZEdgeInsets {
        return only(left: value, top: value, right: value, bottom: value)
    }
    
    public static func symmetric(vertical: CGFloat? = nil, horizontal: CGFloat? = nil) -> DZEdgeInsets {
        return only(left: horizontal, top: vertical, right: horizontal, bottom: vertical)
    }
    
}


public class DZPadding: UIView, DZSingleChildWidget {
    
    public var edgeInsets = DZEdgeInsets()
    
    public var child: DZWidget
    
    required public init(edgeInsets: DZEdgeInsets,
                         child: DZWidget)  {
        self.child = child
        self.edgeInsets = edgeInsets
        super.init(frame: .zero)
        
        
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        
        if edgeInsets.left != nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[child]", options: .directionMask, metrics: [
                "left": edgeInsets.left ?? 0,
                ], views: ["child":child]))
        }
        if edgeInsets.right != nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[child]-right-|", options: .directionMask, metrics: [
                "right": edgeInsets.right ?? 0,
                ], views: ["child":child]))
        }
        
        if edgeInsets.top != nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[child]", options: .directionMask, metrics: [
                "top": edgeInsets.top ?? 0,
                ], views: ["child":child]))
        }
        
        if edgeInsets.bottom != nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[child]-bottom-|", options: .directionMask, metrics: [
                "bottom": edgeInsets.bottom ?? 0,
                ], views: ["child":child]))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public enum DZCenterDirection {
    case both, vertical, horizontal
}

public class DZCenter: UIView, DZSingleChildWidget {
    
    public var child: DZWidget
    
    required public init(
        direction: DZCenterDirection = .both,
        child: DZWidget)  {
        self.child = child
        super.init(frame: .zero)
        
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        
        if direction != .vertical  {
            let centerX = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: child, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            addConstraint(centerX)
        }
        
        if direction != .horizontal {
            let centerY = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: child, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            addConstraint(centerY)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class DZSizedBox: UIView, DZSingleChildWidget {
    
    public var child: DZWidget
    
    required public init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        child: DZWidget)  {
        self.child = child
        super.init(frame: .zero)
        
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        
        let widthVFL: String
        if let width = width {
            widthVFL = "H:|[child(\(width))]|"
        }
        else {
            widthVFL = "H:|[child]|"
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: widthVFL, options: .directionMask, metrics: nil, views: ["child":child]))
        
        let heightVFL: String
        if let height = height {
            heightVFL = "V:|[child(\(height))]|"
        }
        else {
            heightVFL = "V:|[child]|"
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: heightVFL, options: .directionMask, metrics: nil, views: ["child":child]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class DZStack: UIView, DZSingleChildWidget {
    
    public var child: DZWidget
    
    required public init(
        edgeInsets: DZEdgeInsets? = nil,
        direction: DZCenterDirection? = nil,
        base: DZWidget,
        target: DZWidget)  {
        self.child = base
        super.init(frame: .zero)
        
        
        addSubview(base)
        base.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[base]|", options: .directionMask, metrics: nil, views: ["base":base]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[base]|", options: .directionMask, metrics: nil, views: ["base":base]))
        
        addSubview(target)
        target.translatesAutoresizingMaskIntoConstraints = false
        
        if direction != .vertical  {
            let centerX = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: target, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            addConstraint(centerX)
        }
        
        if direction != .horizontal {
            let centerY = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: target, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            addConstraint(centerY)
        }
        
        guard let edgeInsets = edgeInsets else {
            return
        }
        if edgeInsets.left != nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[target]", options: .directionMask, metrics: [
                "left": edgeInsets.left ?? 0,
                ], views: ["target":target]))
        }
        if edgeInsets.right != nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[target]-right-|", options: .directionMask, metrics: [
                "right": edgeInsets.right ?? 0,
                ], views: ["target":target]))
        }
        
        if edgeInsets.top != nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[target]", options: .directionMask, metrics: [
                "top": edgeInsets.top ?? 0,
                ], views: ["target":target]))
        }
        
        if edgeInsets.bottom != nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[target]-bottom-|", options: .directionMask, metrics: [
                "bottom": edgeInsets.bottom ?? 0,
                ], views: ["target":target]))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class DZMockView: UIView { }

public extension UIStackView {
    
    // How can I create UIStackView with variable spacing between views?
    // https://stackoverflow.com/questions/32999159/how-can-i-create-uistackview-with-variable-spacing-between-views
    func addCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) {
        if #available(iOS 11.0, *) {
            self.setCustomSpacing(spacing, after: arrangedSubview)
        } else {
            if let index = self.arrangedSubviews.firstIndex(of: arrangedSubview) {
                let nextIndex = index+1
                if nextIndex < self.arrangedSubviews.count, let separatorView = self.arrangedSubviews[nextIndex] as? DZMockView {
                    separatorView.removeFromSuperview()
                }
                let separatorView = DZMockView(frame: .zero)
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                switch axis {
                case .horizontal:
                    separatorView.widthAnchor.constraint(equalToConstant: spacing).isActive = true
                case .vertical:
                    separatorView.heightAnchor.constraint(equalToConstant: spacing).isActive = true
                @unknown default:
                    fatalError()
                }
                insertArrangedSubview(separatorView, at: nextIndex)
            }
        }
    }
    
    func removeCustomSpacing(after arrangedSubview: UIView) {
        addCustomSpacing(0, after: arrangedSubview)
    }
    
    func addArrangedSubviews(_ views: [UIView?]) {
        views
            .compactMap({ $0 })
            .forEach { addArrangedSubview($0) }
    }
    
    func insertArrangedSubview(_ view: UIView?, after: UIView?) {
        guard let after = after, let view = view else { return }
        guard let targetIndex = arrangedSubviews.firstIndex(of: after) else { return }
        if targetIndex <= arrangedSubviews.count - 1 {
            insertArrangedSubview(view, at: targetIndex)
        }
    }
    
    func insertArrangedSubview(_ view: UIView?, before: UIView?) {
        guard let before = before, let view = view else { return }
        guard let targetIndex = arrangedSubviews.firstIndex(of: before) else { return }
        if targetIndex > 0 {
            insertArrangedSubview(view, at: targetIndex)
        }
    }
    
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { removeArrangedSubview($0) }
    }
    
    func setHidden(_ isHidden: Bool, arrangedSubview: UIView?) {
        guard let arrangedSubview = arrangedSubview else { return }
        if #available(iOS 11.0, *) {
            arrangedSubview.isHidden = isHidden
        } else {
            arrangedSubview.isHidden = isHidden
            if let index = self.arrangedSubviews.firstIndex(of: arrangedSubview) {
                let nextIndex = index+1
                if nextIndex < self.arrangedSubviews.count, let separatorView = self.arrangedSubviews[nextIndex] as? DZMockView {
                    separatorView.isHidden = isHidden
                }
                
                if isHidden {
                    for view in self.arrangedSubviews.reversed() {
                        if view.isHidden == isHidden {
                            continue
                        }
                        if view is DZMockView {
                            view.isHidden = isHidden
                        }
                        break
                    }
                }
                else {
                    let preIndex = index-1
                    if preIndex >= 0, let separatorView = self.arrangedSubviews[preIndex] as? DZMockView {
                        separatorView.isHidden = isHidden
                    }
                }
            }
        }
    }
    
}


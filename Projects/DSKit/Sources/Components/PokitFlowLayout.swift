//
//  PokitFlowLayout.swift
//  DSKit
//
//  Created by 김도형 on 7/7/24.
//

import SwiftUI

public struct PokitFlowLayout: Layout {
    private let rowSpacing: CGFloat
    private let colSpacing: CGFloat
    
    public init(
        rowSpacing: CGFloat,
        colSpacing: CGFloat
    ) {
        self.rowSpacing = rowSpacing
        self.colSpacing = colSpacing
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: proposal.width, height: nil))
            if rowWidth + size.width > proposal.width ?? .infinity {
                height += rowHeight + rowSpacing
                width = max(width, rowWidth)
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + colSpacing
            rowHeight = max(rowHeight, size.height)
        }
        
        height += rowHeight
        width = max(width, rowWidth)
        
        return CGSize(width: width, height: height)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: bounds.width, height: nil))
            if x + size.width > bounds.width {
                x = bounds.minX
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + colSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

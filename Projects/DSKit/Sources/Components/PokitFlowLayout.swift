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
        var totalWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        let maxWidth = proposal.width ?? CGFloat.infinity

        for (_, subview) in subviews.enumerated() {
            let subviewSize = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            let itemWidth = subviewSize.width
            let itemHeight = subviewSize.height

            if rowWidth > 0 && (rowWidth + colSpacing + itemWidth) > maxWidth {
                // 현재 행 마무리
                totalWidth = max(totalWidth, rowWidth)
                totalHeight += rowHeight + rowSpacing
                // 새로운 행 시작
                rowWidth = itemWidth
                rowHeight = itemHeight
            } else {
                if rowWidth > 0 {
                    rowWidth += colSpacing
                }
                rowWidth += itemWidth
                rowHeight = max(rowHeight, itemHeight)
            }
        }

        // 마지막 행 높이 추가
        totalWidth = max(totalWidth, rowWidth)
        totalHeight += rowHeight + rowSpacing

        return CGSize(width: totalWidth, height: totalHeight)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        let maxX = bounds.maxX

        for (_, subview) in subviews.enumerated() {
            let subviewSize = subview.sizeThatFits(ProposedViewSize(width: bounds.width, height: nil))
            let itemWidth = subviewSize.width
            let itemHeight = subviewSize.height

            if x > bounds.minX - 1  && (x + colSpacing + itemWidth) > maxX + 1 {
                // 현재 행 마무리하고 다음 행 시작
                x = bounds.minX
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            if x > bounds.minX {
                x += colSpacing
            }
            // 아이템 배치
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(subviewSize))
            x += itemWidth
            rowHeight = max(rowHeight, itemHeight)
        }
    }
}

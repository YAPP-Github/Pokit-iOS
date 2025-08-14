//
//  PokitBottomSheet.swift
//  DSKit
//
//  Created by 김도형 on 6/29/24.
//

import SwiftUI

public struct PokitBottomSheet: View {
    @State
    private var height: CGFloat
    private let items: [Item]
    private let delegateSend: ((PokitBottomSheet.Delegate) -> Void)?
    
    public init(
        items: [Item],
        height: CGFloat = 0,
        delegateSend: ((PokitBottomSheet.Delegate) -> Void)?
    ) {
        self.items = items
        self.height = height
        self.delegateSend = delegateSend
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            list()
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.height(height)])
        .pokitPresentationCornerRadius()
        .pokitPresentationBackground()
        .readHeight()
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            if let height {
                print("height:", height)
                self.height = height
            }
        }
        .ignoresSafeArea(.all)
        .padding(.top, 12)
        .padding(.bottom, -20)
    }
    
    @ViewBuilder
    private func list() -> some View {
        let last = items.last
        
        ForEach(items, id: \.hashValue) { item in
            listCell(item)
            
            if item != last {
                Divider()
                    .foregroundStyle(.pokit(.border(.tertiary)))
            }
        }
    }
    
    @ViewBuilder
    private func listCell(_ item: PokitBottomSheet.Item) -> some View {
        Button {
            listCellButtonTapped(item)
        } label: {
            HStack {
                Text(item.name)
                    .pokitFont(.b1(.m))
                    .foregroundStyle(.pokit(.text(.secondary)))
                
                Spacer()
                
                Image(item.icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.pokit(.icon(.primary)))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
    }
    
    private func listCellButtonTapped(_ item: PokitBottomSheet.Item) {
        switch item {
        case .favorite:
            delegateSend?(.favoriteCellButtonTapped)
            return
        case .share:
            delegateSend?(.shareCellButtonTapped)
            return
        case .edit:
            delegateSend?(.editCellButtonTapped)
            return
        case .delete:
            delegateSend?(.deleteCellButtonTapped)
            return
        }
    }
}

public extension PokitBottomSheet {
    enum Item: CaseIterable {
        case favorite
        case share
        case edit
        case delete
        
        var name: String {
            switch self {
            case .favorite: return "즐겨찾기"
            case .share: return "공유하기"
            case .edit: return "수정하기"
            case .delete: return "삭제하기"
            }
        }
        
        var icon: PokitImage {
            switch self {
            case .favorite: return .icon(.star)
            case .share: return .icon(.share)
            case .edit: return .icon(.edit)
            case .delete: return .icon(.trash)
            }
        }
    }
    
    enum Delegate {
        case favoriteCellButtonTapped
        case shareCellButtonTapped
        case editCellButtonTapped
        case deleteCellButtonTapped
    }
}

@available(iOS 18.0, *)
#Preview {
    @Previewable
    @State var isPresented: Bool = true
    
    ZStack {
        Color.green.ignoresSafeArea()
    }
    .sheet(isPresented: $isPresented) {
        PokitBottomSheet(
            items: [.share, .edit, .delete],
            delegateSend: { _ in }
        )
    }
}

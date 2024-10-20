//
//  CategoryFilterSheet.swift
//  Feature
//
//  Created by 김민호 on 7/18/24.

import SwiftUI

import DSKit

public struct CategoryFilterSheet: View {
    
    @State private var height: CGFloat = 0
    @Binding private var sortType: SortType
    @State private var isBookMarkSelected: Bool
    @State private var isUnReadSelected: Bool
    private let delegateSend: ((CategoryFilterSheet.Delegate) -> Void)?
    
    public init(
        sortType: Binding<SortType>,
        isBookMarkSelected: Bool,
        isUnreadSeleected: Bool,
        delegateSend: ((CategoryFilterSheet.Delegate) -> Void)?
    ) {
        self._sortType = sortType
        self._isBookMarkSelected = .init(initialValue: isBookMarkSelected)
        self._isUnReadSelected = .init(initialValue: isUnreadSeleected)
        self.delegateSend = delegateSend
    }
    
}
//MARK: - View
public extension CategoryFilterSheet {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                header
                
                contents
            }
            .padding(.top)
            .background(.pokit(.bg(.base)))
            .pokitPresentationCornerRadius()
            .pokitPresentationBackground()
            .presentationDragIndicator(.visible)
            .readHeight()
            .onPreferenceChange(HeightPreferenceKey.self) { height in
                if let height {
                    self.height = height - geometry.safeAreaInsets.bottom
                }
            }
            .presentationDetents([.height(self.height)])
        }
    }
}
//MARK: - Configure View
private extension CategoryFilterSheet {
    var header: some View {
        VStack(spacing: 16) {
            /// header
            HStack(spacing: 0) {
                Spacer()
                Text("필터")
                    .pokitFont(.title3)
                    .foregroundStyle(.pokit(.text(.primary)))
                Spacer()
            }
            .overlay(alignment: .topTrailing) {
                Button(action: { delegateSend?(.dismiss) }) {
                    Image(.icon(.x))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.pokit(.border(.tertiary)))
        }
        .padding(.top, 16)
    }
    var contents: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("정렬")
                    .pokitFont(.b1(.m))
                    .foregroundStyle(.black)
                    .padding(.bottom, 4)
                sortView(.최신순)
                sortView(.오래된순)
            }
            .padding(.top, 20)
            .padding(.bottom, 36)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("모아보기")
                    .pokitFont(.b1(.m))
                    .foregroundStyle(.black)
                    .padding(.bottom, 4)
                sortCollectView(.즐겨찾기)
                sortCollectView(.안읽음)
            }
            .padding(.bottom, 36)
            
            PokitBottomButton(
                "확인",
                state: .filled(.primary),
                action: { delegateSend?(
                    .확인_버튼_눌렀을때(
                        self.sortType,
                        bookMarkSelected: self.isBookMarkSelected,
                        unReadSelected: self.isUnReadSelected
                    )
                )
                }
            )
        }
        .padding(.horizontal, 20)
    }
    
    func sortView(_ type: SortType) -> some View {
        HStack(spacing: 8) {
            Button(action: { self.sortButtonTapped(type) }) {
                let isSelected = self.sortType == type
                Circle()
                    .stroke(
                        isSelected
                        ? .pokit(.border(.brand))
                        : .pokit(.border(.tertiary)), lineWidth: 2
                    )
                    .frame(width: 24, height: 24)
                    .background {
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(
                                isSelected
                                ? .pokit(.border(.brand))
                                : .pokit(.icon(.tertiary))
                            )
                    }
            }
            Text(type.rawValue)
                .foregroundStyle(.pokit(.text(.secondary)))
                .pokitFont(.b2(.m))
            Spacer()
        }
    }
    @ViewBuilder
    func sortCollectView(_ type: SortCollectType) -> some View {
        let isSelected = type == .즐겨찾기
        ? $isBookMarkSelected
        : $isUnReadSelected
        
        HStack(spacing: 8) {
            PokitCheckBox(
                baseState: .default,
                selectedState: .filled,
                isSelected: isSelected,
                shape: .rectangle,
                action: { }
            )
            Text(type.title)
                .pokitFont(.b2(.m))
                .foregroundStyle(.pokit(.text(.secondary)))
            Spacer()
        }
    }
}
//MARK: - Action
private extension CategoryFilterSheet {
    func sortButtonTapped(_ type: SortType) {
        self.sortType = type
    }
}
//MARK: - Delegate
public extension CategoryFilterSheet {
    enum Delegate: Equatable {
        case dismiss
        case 확인_버튼_눌렀을때(SortType, bookMarkSelected: Bool, unReadSelected: Bool)
    }
}
//MARK: - Preview
#Preview {
    CategoryFilterSheet(
        sortType: .constant(.최신순),
        isBookMarkSelected: true,
        isUnreadSeleected: true,
        delegateSend: nil
    )
}



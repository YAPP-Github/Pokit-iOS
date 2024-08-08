//
//  PokitCategorySettingView.swift
//  Feature
//
//  Created by 김민호 on 7/25/24.

import SwiftUI

import ComposableArchitecture
import Domain
import DSKit

@ViewAction(for: PokitCategorySettingFeature.self)
public struct PokitCategorySettingView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<PokitCategorySettingFeature>
    @FocusState private var isFocused: Bool
    
    /// - Initializer
    public init(store: StoreOf<PokitCategorySettingFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitCategorySettingView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                thumbnailSection
                pokitNameSection
                if !store.itemList.isEmpty {
                    myPokitSection
                } else {
                    Spacer()
                }
                saveButton
            }
            .padding(.horizontal, 20)
            .background(.pokit(.bg(.base)))
            .ignoresSafeArea(edges: .bottom)
            .navigationBarBackButtonHidden()
            .toolbar { navigationBar }
            .pokitNavigationBar(title: store.type.title)
            .sheet(isPresented: $store.isProfileSheetPresented) {
                ProfileBottomSheet(
                    images: store.profileImages,
                    delegateSend: { store.send(.scope(.profile($0))) }
                )
            }
            .task { await send(.onAppear).finish() }
        }
    }
}
//MARK: - Configure View
private extension PokitCategorySettingView {
    var navigationBar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            PokitToolbarButton(
                .icon(.arrowLeft),
                action: { send(.dismiss) }
            )
        }
    }
    /// 썸네일이미지 +프로필 설정
    var thumbnailSection: some View {
        AsyncImage(
            url: URL(string: store.selectedProfile?.imageURL ?? ""),
            transaction: .init(animation: .spring)
        ) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .roundedCorner(12, corners: .allCorners)
            default:
                RoundedRectangle(cornerRadius: 12)
            }
        }
        .frame(width: 80, height: 80)
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .stroke(
                    .pokit(.icon(.tertiary)),
                    lineWidth: 1
                )
                .frame(width: 24, height: 24)
                .background {
                    ZStack {
                        Circle()
                            .foregroundStyle(
                                .pokit(.icon(.inverseWh))
                            )
                        Button(action: { send(.profileSettingButtonTapped) }) {
                            Image(.icon(.edit))
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundStyle(.pokit(.icon(.tertiary)))
                                .padding(2)
                        }
                    }
                    
                }
                .offset(x: 10)
                .padding(.bottom, 7)
        }
    }
    /// 타이틀 + 텍스트필드를 포함한 포킷명 입력 섹션
    var pokitNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("포킷명")
                .pokitFont(.b2(.m))
                .foregroundStyle(.pokit(.text(.secondary)))
            PokitTextInput(
                text: $store.categoryName,
                state: .constant(.active),
                placeholder: "포킷명을 입력해주세요.",
                maxLetter: 10,
                focusState: $isFocused,
                equals: true
            )
        }
    }
    /// 내포킷 리스트( ScrollView)
    var myPokitSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("내 포킷")
                    .pokitFont(.b2(.m))
                    .foregroundStyle(.pokit(.text(.secondary)))
                Spacer()
            }
            
            ScrollView {
                ForEach(store.itemList, id: \.id) { item in
                    PokitItem(item: item)
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.top, 28)
    }
    /// 저장하기 버튼
    var saveButton: some View {
        PokitBottomButton(
            "저장하기",
            state: !store.categoryName.isEmpty && store.selectedProfile != nil
            ? .filled(.primary)
            : .disable,
            action: { send(.saveButtonTapped) }
        )
    }
    /// 내포킷 Item
    struct PokitItem: View {
        let item: BaseCategory
        
        init(item: BaseCategory) {
            self.item = item
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.categoryName)
                        .pokitFont(.b1(.b))
                        .foregroundStyle(.pokit(.text(.disable)))
                    Spacer()
                }
                HStack {
                    Text("링크 \(item.contentCount)개")
                        .pokitFont(.detail1)
                        .foregroundStyle(.pokit(.text(.disable)))
                    Spacer()
                }
            }
            .padding(.vertical, 12)
        }
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        PokitCategorySettingView(
            store: Store(
                initialState: .init(type: .추가),
                reducer: { PokitCategorySettingFeature() }
            )
        )
    }
    
}



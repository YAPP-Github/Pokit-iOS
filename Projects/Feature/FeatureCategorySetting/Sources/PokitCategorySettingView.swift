//
//  PokitCategorySettingView.swift
//  Feature
//
//  Created by 김민호 on 7/25/24.

import SwiftUI

import ComposableArchitecture
import Domain
import DSKit
import NukeUI

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
                myPokitSection
                saveButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .pokitMaxWidth()
            .pokitNavigationBar { navigationBar }
            .ignoresSafeArea(edges: isFocused ? [] : .bottom)
            .sheet(isPresented: $store.isProfileSheetPresented) {
                ProfileBottomSheet(
                    selectedImage: store.selectedProfile,
                    images: store.profileImages,
                    delegateSend: { store.send(.scope(.profile($0))) }
                )
            }
            .task { await send(.뷰가_나타났을때).finish() }
        }
    }
}
//MARK: - Configure View
private extension PokitCategorySettingView {
    var navigationBar: some View {
        PokitHeader(title: store.type.title) {
            PokitHeaderItems(placement: .leading) {
                PokitToolbarButton(.icon(.arrowLeft)) {
                    send(.dismiss)
                }
            }
        }
        .padding(.top, 8)
    }
    /// 썸네일이미지 +프로필 설정
    @MainActor
    var thumbnailSection: some View {
        LazyImage(
            url: URL(string: store.selectedProfile?.imageURL ?? ""),
            transaction: .init(animation: .spring)
        ) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .roundedCorner(12, corners: .allCorners)
            } else {
                WithPerceptionTracking {
                    ZStack {
                        Color.pokit(.bg(.disable))
                        
                        if store.selectedProfile?.imageURL != nil {
                            PokitSpinner()
                                .foregroundStyle(.pokit(.icon(.brand)))
                                .frame(width: 48, height: 48)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
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
                        Button(action: { send(.프로필_설정_버튼_눌렀을때) }) {
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
                type: .iconR(
                    icon: .icon(.x),
                    action: { send(.포킷명지우기_버튼_눌렀을때) }
                ),
                shape: .rectangle,
                state: $store.pokitNameTextInpuState,
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
            if let itemList = store.itemList {
                if itemList.isEmpty {
                    Spacer()
                } else {
                    HStack {
                        Text("내 포킷")
                            .pokitFont(.b2(.m))
                            .foregroundStyle(.pokit(.text(.secondary)))
                        Spacer()
                    }
                    
                    
                    ScrollView {
                        ForEach(itemList, id: \.id) { item in
                            PokitItem(item: item)
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            } else {
                PokitLoading()
            }
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
            action: { send(.저장_버튼_눌렀을때) }
        )
    }
    /// 내포킷 Item
    struct PokitItem: View {
        let item: BaseCategoryItem
        
        init(item: BaseCategoryItem) {
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



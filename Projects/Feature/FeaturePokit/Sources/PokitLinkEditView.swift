//
//  PokitLinkEditView.swift
//  Feature
//
//  Created by 김민호 on 12/24/24.

import SwiftUI

import ComposableArchitecture
import DSKit
import Domain
import CoreKit
import FeatureCategorySetting
import Util

@ViewAction(for: PokitLinkEditFeature.self)
public struct PokitLinkEditView: View {
    /// - Properties
    @Perception.Bindable public var store: StoreOf<PokitLinkEditFeature>
    
    /// - Initializer
    public init(store: StoreOf<PokitLinkEditFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitLinkEditView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                if store.list.isEmpty {
                    PokitCaution(type: .미분류_링크없음)
                    Spacer()
                } else {
                    ScrollView {
                        ForEach(store.list, id: \.id) { item in
                            let isFirst = item.id == self.store.list.first?.id
                            let isLast = item.id == self.store.list.last?.id
                            WithPerceptionTracking {
                                PokitLinkCard(
                                    link: item,
                                    state: isFirst
                                    ? .top
                                    : isLast ? .bottom : .middle,
                                    type: .unCatgorized(isSelected: store.selectedItems.contains(item)),
                                    action: nil,
                                    kebabAction: nil,
                                    fetchMetaData: {},
                                    favoriteAction: nil,
                                    selectAction: { send(.체크박스_선택했을때(item)) }
                                )
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .padding(.bottom, 38)
                }
            }
            .padding(.top, 16)
            .overlay(alignment: .bottom) {
                if !store.list.isEmpty {
                    actionFloatButtonView
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .pokitNavigationBar(navigationBar)
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $store.categorySelectSheetPresetend) {
                PokitSelectSheet(
                    list: store.category?.data ?? nil,
                    itemSelected: { send(.카테고리_선택했을때($0)) },
                    pokitAddAction: { send(.포킷_추가하기_버튼_눌렀을때) }
                )
                .presentationDragIndicator(.visible)
                .pokitPresentationCornerRadius()
                .presentationDetents([.height(564)])
                .pokitPresentationBackground()
                
            }
            .sheet(isPresented: $store.linkDeleteSheetPresented) {
                PokitAlert(
                    "링크를 정말 삭제하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며, \n복구하실 수 없습니다.",
                    confirmText: "삭제",
                    action: { send(.삭제확인_버튼_눌렀을때) },
                    cancelAction: { send(.경고시트_해제) }
                )
            }
            .overlay(alignment: .bottom) {
                if store.linkPopup != nil {
                    PokitLinkPopup(
                        type: $store.linkPopup,
                        action: { send(.링크팝업_버튼_눌렀을때, animation: .pokitSpring) }
                    )
                    .pokitMaxWidth()
                }
            }
            /// fullScreenCover를 통해 새로운 Destination을 만들었음
            /// 그렇지 않으면 MainPath에서 관리해야 하고, `LinkEdit`을 모듈로 빼야 함
            /// 추후 여러 군데에서 사용 된다면 그때 진행
            .fullScreenCover(
                item: $store.scope(
                    state: \.addPokit,
                    action: \.scope.addPokit
                )
            ) { store in
                PokitCategorySettingView(store: store)
            }
            .task { await send(.뷰가_나타났을때).finish() }
        }
    }
}
//MARK: - Configure View
private extension PokitLinkEditView {
    var navigationBar: some View {
        PokitHeader(title: "링크 분류하기") {
            PokitHeaderItems(placement: .leading) {
                PokitToolbarButton(.icon(.x)) {
                    send(.dismiss)
                }
            }
        }
        .padding(.top, 8)
    }
    
    var actionFloatButtonView: some View {
        PokitLinkEditFloatView(
            delegateSend: { store.send(.scope(.floatButtonAction($0))) }
        )
    }
}
//MARK: - Preview
#Preview {
    PokitLinkEditView(
        store: Store(
            initialState: .init(
                linkList: BaseContentListInquiry(
                    data: [BaseContentItem(id: 3, categoryName: "23", categoryId: 255, title: "2323", memo: nil, thumbNail: Constants.mockImageUrl, data: "", domain: "", createdAt: "", isRead: false, isFavorite: false)],
                    page: 0,
                    size: 0,
                    sort: [],
                    hasNext: false
                )
            ),
            reducer: { PokitLinkEditFeature() }
        )
    )
}



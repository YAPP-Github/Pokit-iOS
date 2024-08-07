//
//  PokitCategorySettingFeature.swift
//  Feature
//
//  Created by 김민호 on 7/25/24.

import Foundation

import ComposableArchitecture
import Domain
import CoreKit
import Util

@Reducer
public struct PokitCategorySettingFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.pasteboard) var pasteboard
    /// - State
    @ObservableState
    public struct State: Equatable {
        fileprivate var domain: PokitCategorySetting
        
        var selectedProfile: BaseCategoryImage? {
            get { domain.categoryImage }
            set { domain.categoryImage = newValue }
        }
        var categoryName: String {
            get { domain.categoryName }
            set { domain.categoryName = newValue }
        }
        var profileImages: [BaseCategoryImage] {
            get { domain.imageList }
        }
        var itemList: IdentifiedArrayOf<BaseCategory> {
            var identifiedArray = IdentifiedArrayOf<BaseCategory>()
            domain.categoryListInQuiry.data.forEach { category in
                identifiedArray.append(category)
            }
            return identifiedArray
        }
        let type: SettingType
        var isProfileSheetPresented: Bool = false
        
        /// - 포킷 수정 API / 추가 API
        /// categoryName
        /// categoryImageId
        /// categoryId (포킷 수정용)
    
        public init(
            type: SettingType,
            categoryId: Int? = nil,
            categoryImage: BaseCategoryImage? = nil,
            categoryName: String? = ""
        ) {
            self.type = type
            self.domain = .init(
                categoryId: categoryId,
                categoryName: categoryName,
                categoryImage: categoryImage
            )
        }
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum View: BindableAction, Equatable {
            case binding(BindingAction<State>)
            case dismiss
            case profileSettingButtonTapped
            case saveButtonTapped
            case onAppear
        }
        
        public enum InnerAction: Equatable { case doNothing }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable {
            case profile(ProfileBottomSheet.Delegate)
        }
        
        public enum DelegateAction: Equatable {
            /// 이전화면으로 돌아가 카테고리 항목을 추가하면됨
            case settingSuccess(categoryName: String, categoryImageId: Int)
            case linkCopyDetected(URL?)
        }
    }
    
    /// - Initiallizer
    public init() {}

    /// - Reducer Core
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            /// - View
        case .view(let viewAction):
            return handleViewAction(viewAction, state: &state)
            
            /// - Inner
        case .inner(let innerAction):
            return handleInnerAction(innerAction, state: &state)
            
            /// - Async
        case .async(let asyncAction):
            return handleAsyncAction(asyncAction, state: &state)
            
            /// - Scope
        case .scope(let scopeAction):
            return handleScopeAction(scopeAction, state: &state)
            
            /// - Delegate
        case .delegate(let delegateAction):
            return handleDelegateAction(delegateAction, state: &state)
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
            ._printChanges()
    }
}
//MARK: - FeatureAction Effect
private extension PokitCategorySettingFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .profileSettingButtonTapped:
            /// 1. 프로필 목록 조회 API 호출
            /// 2. 프로필 목록들을 profileImages에 할당
            // - MARK: 목업 데이터 조회
            state.domain.imageList = CategoryImageResponse.mock.map { $0.toDomain() }
            /// 3. 토글 on
            state.isProfileSheetPresented.toggle()
            return .none
            
        case .saveButtonTapped:
            return .run { [domain = state.domain] send in
                ///Todo: 네트워크 코드 추가
//                let result = try await network
            
                /// - mock
                guard let imageId = domain.categoryImage?.id else { return }
                await send(.delegate(.settingSuccess(
                    categoryName: domain.categoryName,
                    categoryImageId: imageId
                )))
            }
            
        case .onAppear:
            // - MARK: 목업 데이터 조회
            state.domain.categoryListInQuiry = CategoryListInquiryResponse.mock.toDomain()
            return .run { send in
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                }
            }
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        case .profile(.imageSelected(let imageInfo)):
            state.isProfileSheetPresented = false
            state.selectedProfile = imageInfo
            return .none
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}

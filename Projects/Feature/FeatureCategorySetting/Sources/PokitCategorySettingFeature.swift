//
//  PokitCategorySettingFeature.swift
//  Feature
//
//  Created by 김민호 on 7/25/24.

import Foundation

import ComposableArchitecture
import DSKit
import Domain
import CoreKit
import Util

/// - 사용되는 API 목록
/// 1. Profile 🎨
/// 2. 포킷 생성 🖨️
@Reducer
public struct PokitCategorySettingFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.categoryClient) var categoryClient
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
        var itemList: IdentifiedArrayOf<BaseCategoryItem>? {
            guard let categoryList = domain.categoryListInQuiry.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseCategoryItem>()
            categoryList.forEach { category in
                identifiedArray.append(category)
            }
            return identifiedArray
        }
        
        let type: SettingType
        var isProfileSheetPresented: Bool = false
        var pokitNameTextInpuState: PokitInputStyle.State = .default
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
        
        public enum InnerAction: Equatable {
            case 카테고리_목록_조회_결과(BaseCategoryListInquiry)
            case 프로필_목록_조회_결과(images: [BaseCategoryImage])
            case 포킷_오류_핸들링(BaseError)
        }
        
        public enum AsyncAction: Equatable {
            case 프로필_목록_조회
        }
        
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
            /// [Profile 🎨]1. 프로필 목록 조회 API 호출
            state.isProfileSheetPresented.toggle()
            return .none

        case .saveButtonTapped:
            return .run { [domain = state.domain,
                           type = state.type] send in
                switch type {
                case .추가:
                    guard let image = domain.categoryImage else { return }
                    let request = CategoryEditRequest(categoryName: domain.categoryName, categoryImageId: image.id)
                    let response = try await categoryClient.카테고리_생성(request)
                    await send(
                        .delegate(
                            .settingSuccess(
                                categoryName: response.categoryName,
                                categoryImageId: response.categoryImage.imageId
                            )
                        )
                    )
                case .수정:
                    guard let categoryId = domain.categoryId else { return }
                    guard let image = domain.categoryImage else { return }
                    let request = CategoryEditRequest(categoryName: domain.categoryName, categoryImageId: image.id)
                    let response = try await categoryClient.카테고리_수정(categoryId, request)
                    await send(
                        .delegate(
                            .settingSuccess(
                                categoryName: response.categoryName,
                                categoryImageId: response.categoryImage.imageId
                            )
                        )
                    )
                case .공유추가:
                    guard let categoryId = domain.categoryId else { return }
                    guard let image = domain.categoryImage else { return }
                    try await categoryClient.공유받은_카테고리_저장(
                        .init(
                            originCategoryId: categoryId,
                            categoryName: domain.categoryName,
                            categoryImageId: image.id
                        )
                    )
                    await send(
                        .delegate(
                            .settingSuccess(
                                categoryName: domain.categoryName,
                                categoryImageId: image.id
                            )
                        )
                    )
                }
            } catch: { error, send in
                guard let errorResponse = error as? ErrorResponse else {
                    return
                }
                await send(.inner(.포킷_오류_핸들링(.init(response: errorResponse))))
            }
            
        case .onAppear:
            return .run { send in
                let pageRequest = BasePageableRequest(page: 0, size: 100, sort: ["desc"])
                let response = try await categoryClient.카테고리_목록_조회(pageRequest, true).toDomain()
                await send(.inner(.카테고리_목록_조회_결과(response)))
                await send(.async(.프로필_목록_조회))
                
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                }
            }
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .프로필_목록_조회_결과(images):
            state.domain.imageList = images

            guard let _ = state.selectedProfile else {
                state.selectedProfile = images.first
                return .none
            }
            return .none
        case let .카테고리_목록_조회_결과(response):
            state.domain.categoryListInQuiry = response
            return .none
        case let .포킷_오류_핸들링(baseError):
            switch baseError {
            case let .CA_001(message):
                state.pokitNameTextInpuState = .error(message: message)
                return .none
            default: return .none
            }
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .프로필_목록_조회:
            return .run { send in
                let a = try await categoryClient.카테고리_프로필_목록_조회()
                let b = a.map { $0.toDomain() }
                await send(.inner(.프로필_목록_조회_결과(images: b)))
            }
        }
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

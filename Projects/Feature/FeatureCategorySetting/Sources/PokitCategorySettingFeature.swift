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

@Reducer
public struct PokitCategorySettingFeature {
    /// - Dependency
    @Dependency(\.dismiss) 
    var dismiss
    @Dependency(PasteboardClient.self) 
    var pasteboard
    @Dependency(CategoryClient.self) 
    var categoryClient
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
        
        var isPublicType: Bool {
            get { domain.openType == .공개 ? true : false }
            set { domain.openType = newValue ? .공개 : .비공개 }
        }
        
        let type: SettingType
        let shareType: ShareType
        var isProfileSheetPresented: Bool = false
        var pokitNameTextInpuState: PokitInputStyle.State = .default
        @Shared(.inMemory("SelectCategory")) var categoryId: Int?
        /// - 포킷 수정 API / 추가 API
        /// categoryName
        /// categoryImageId
        /// categoryId (포킷 수정용)
    
        public init(
            type: SettingType,
            category: BaseCategoryItem? = nil
        ) {
            self.type = type
            self.domain = .init(
                categoryId: category?.id,
                categoryName: category?.categoryName,
                categoryImage: category?.categoryImage,
                openType: category?.openType,
                keywordType: category?.keywordType
            )
            self.shareType = category == nil
            ? .미공유
            : category?.userCount ?? 0 > 0
                ? .공유
                : .미공유
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
            case 프로필_설정_버튼_눌렀을때
            case 저장_버튼_눌렀을때
            case 뷰가_나타났을때
            case 포킷명지우기_버튼_눌렀을때
        }
        
        public enum InnerAction: Equatable {
            case 프로필_목록_조회_API_반영(images: [BaseCategoryImage])
            case 포킷_오류_핸들링(BaseError)
            case 카테고리_인메모리_저장(BaseCategoryItem)
        }
        
        public enum AsyncAction: Equatable {
            case 프로필_목록_조회_API
            case 클립보드_감지
        }
        
        public enum ScopeAction: Equatable {
            case profile(ProfileBottomSheet.Delegate)
        }
        
        public enum DelegateAction: Equatable {
            /// 이전화면으로 돌아가 카테고리 항목을 추가하면됨
            case settingSuccess
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
            
        case .프로필_설정_버튼_눌렀을때:
            state.isProfileSheetPresented.toggle()
            return .none

        case .저장_버튼_눌렀을때:
            return .run { [domain = state.domain,
                           type = state.type] send in
                switch type {
                case .추가:
                    guard let image = domain.categoryImage else { return }
                    let request = CategoryEditRequest(
                        categoryName: domain.categoryName,
                        categoryImageId: image.id,
                        openType: domain.openType.title,
                        keywordType: domain.keywordType.title
                    )
                    let response = try await categoryClient.카테고리_생성(request)
                    let responseToCategoryDomain = BaseCategoryItem(
                        id: response.categoryId,
                        userId: 0,
                        categoryName: response.categoryName,
                        categoryImage: BaseCategoryImage(
                            imageId: response.categoryImage.imageId,
                            imageURL: response.categoryImage.imageUrl
                        ),
                        contentCount: 0,
                        createdAt: "",
                        //TODO: v2 property 수정
                        openType: domain.openType,
                        keywordType: domain.keywordType,
                        userCount: 0
                    )
                    await send(.inner(.카테고리_인메모리_저장(responseToCategoryDomain)))
                    await send(.delegate(.settingSuccess))
                    
                case .수정:
                    guard let categoryId = domain.categoryId else { return }
                    guard let image = domain.categoryImage else { return }
                    let request = CategoryEditRequest(
                        categoryName: domain.categoryName,
                        categoryImageId: image.id,
                        openType: domain.openType.title,
                        keywordType: domain.keywordType.title
                    )
                    let _ = try await categoryClient.카테고리_수정(categoryId, request)
                    await send(.delegate(.settingSuccess))
                    
                case .공유추가:
                    guard let categoryId = domain.categoryId else { return }
                    guard let image = domain.categoryImage else { return }
                    try await categoryClient.공유받은_카테고리_저장(
                        CopiedCategoryRequest(
                            originCategoryId: categoryId,
                            categoryName: domain.categoryName,
                            categoryImageId: image.id
                        )
                    )
                    await send(.delegate(.settingSuccess))
                }
            } catch: { error, send in
                guard let errorResponse = error as? ErrorResponse else { return }
                await send(.inner(.포킷_오류_핸들링(BaseError(response: errorResponse))))
            }
            
        case .뷰가_나타났을때:
            /// 단순 조회API들의 나열이라 merge사용
            return .merge(
                .send(.async(.프로필_목록_조회_API)),
                .send(.async(.클립보드_감지))
            )
        case .포킷명지우기_버튼_눌렀을때:
            state.domain.categoryName = ""
            return .none
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .프로필_목록_조회_API_반영(images):
            state.domain.imageList = images

            guard let _ = state.selectedProfile else {
                state.selectedProfile = images.first
                return .none
            }
            return .none
            
        case let .포킷_오류_핸들링(baseError):
            state.pokitNameTextInpuState = .error(message: baseError.message)
            return .none
            
        case let .카테고리_인메모리_저장(response):
            state.categoryId = response.id
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .프로필_목록_조회_API:
            return .run { send in
                let response = try await categoryClient.카테고리_프로필_목록_조회()
                let images = response.map { $0.toDomain() }
                await send(.inner(.프로필_목록_조회_API_반영(images: images)))
            }
        
        case .클립보드_감지:
            return .run { send in
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                }
            }
        }
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        case .profile(.이미지_선택했을때(let imageInfo)):
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

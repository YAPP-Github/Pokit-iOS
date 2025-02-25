//
//  NickNameSettingFeature.swift
//  Feature
//
//  Created by 김민호 on 7/22/24.

import ComposableArchitecture

import CoreKit
import Domain
import DSKit
import Util

@Reducer
public struct NickNameSettingFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    var dismiss
    @Dependency(\.mainQueue)
    var mainQueue
    @Dependency(UserClient.self)
    var userClient
    @Dependency(CategoryClient.self)
    var categoryClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        fileprivate var domain: NicknameSetting
        var text: String {
            get { self.domain.nickname }
            set { self.domain.nickname = newValue }
        }
        var user: BaseUser? {
            get { domain.user }
        }
        
        var selectedProfile: BaseProfile? {
            get { domain.selectedProfile }
            set { domain.selectedProfile = newValue }
        }
        
        var profileImages: [BaseProfile] {
            get { domain.imageList }
        }
        
        var textfieldState: PokitInputStyle.State = .default
        var buttonState: PokitButtonStyle.State = .disable
        var isProfileSheetPresented: Bool = false
        
        public init(user: BaseUser?) {
            if let user,
               let profile = user.profile {
                self.domain = .init(
                    selectedProfile: BaseProfile(
                        id: profile.id,
                        imageURL: profile.imageURL
                    )
                )
            } else {
                self.domain = .init(selectedProfile: nil)
            }
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
            
            case 저장_버튼_눌렀을때
            case 뷰가_나타났을때
            case 닉네임지우기_버튼_눌렀을때
            case 프로필_설정_버튼_눌렀을때
        }
        
        public enum InnerAction: Equatable {
            case 닉네임_텍스트_변경되었을때
            case 닉네임_중복_확인_API_반영(Bool)
            case 닉네임_조회_API_반영(BaseUser)
            case 프로필_목록_조회_API_반영(images: [BaseProfile])
        }
        
        public enum AsyncAction: Equatable {
            case 닉네임_중복_확인_API
            case 닉네임_조회_API
            case 프로필_목록_조회_API
        }
        
        public enum ScopeAction {
            case profile(PokitProfileBottomSheet<BaseProfile>.Delegate)
        }
        
        public enum DelegateAction: Equatable { case 없음 }
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
    public enum CancelID { case response }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension NickNameSettingFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding(\.text):
            state.buttonState = .disable
            return .run { send in
                await send(.inner(.닉네임_텍스트_변경되었을때))
            }
            .debounce(
                id: CancelID.response,
                for: 0.5,
                scheduler: mainQueue
            )
            
        case .binding:
            return .none
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .저장_버튼_눌렀을때:
            return .run { [nickName = state.text, selectedImage = state.selectedProfile] send in
                if let selectedImage {
                    let request = ProfileEditRequest(profileImageId: selectedImage.id, nickname: nickName)
                    let _ = try await userClient.프로필_수정(model: request)
                } else {
                    let request = ProfileEditRequest(profileImageId: nil, nickname: nickName)
                    let _ = try await userClient.프로필_수정(model: request)
                }
                await dismiss()
            }
            
        case .뷰가_나타났을때:
            return .merge(
                .send(.async(.프로필_목록_조회_API)),
                .send(.async(.닉네임_조회_API))
            )
            
        case .닉네임지우기_버튼_눌렀을때:
            state.domain.nickname = ""
            state.buttonState = .disable
            return .none
            
        case .프로필_설정_버튼_눌렀을때:
            state.isProfileSheetPresented.toggle()
            return .none
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .닉네임_텍스트_변경되었을때:
            /// [1]. 닉네임 변경 X, 현재 프로필이 nil이면서 프로필을 선택했을 때 -> 버튼 활성화
            if let currentNickName = state.user?.nickname,
               let _ = state.selectedProfile {
                if currentNickName == state.text &&
                    state.user?.profile == nil {
                    state.buttonState = .filled(.primary)
                    return .none
                }
            }
            /// [2]. 닉네임 변경 X,, 프로필만 변경했을 때 -> 버튼 활성화
            if let currentNickName = state.user?.nickname,
               let currentProfile = state.user?.profile,
               let selectedProfile = state.selectedProfile {
                if currentNickName == state.text && currentProfile != selectedProfile {
                    state.buttonState = .filled(.primary)
                    return .none
                }
            }
            /// [3]. 닉네임 텍스트필드가 비어있을 때
            if state.text.isEmpty {
                state.buttonState = .disable
                return .none
            }
            /// [4]. 닉네임이 10자를 넘을 때
            if state.text.count > 10 {
                state.buttonState = .disable
                state.textfieldState = .error(message: "최대 10자까지 입력 가능합니다.")
                return .none
            }
            /// [5]. 닉네임에 특수문자가 포함되어 있을 때
            if !state.text.isNickNameValid {
                state.buttonState = .disable
                state.textfieldState = .error(message: "한글, 영어, 숫자만 입력이 가능합니다.")
                return .none
            }
            /// [6]. 정상 케이스일 때
            return .run { send in await send(.async(.닉네임_중복_확인_API)) }
            
        case let .닉네임_중복_확인_API_반영(isDuplicate):
            state.textfieldState = isDuplicate
            ? .error(message: "중복된 닉네임입니다.")
            : .active
            
            state.buttonState = isDuplicate
            ? .disable
            : .filled(.primary)
            return .none
            
        case let .닉네임_조회_API_반영(user):
            state.domain.user = user
            state.domain.nickname = user.nickname
            if let profile = user.profile {
                state.selectedProfile =  BaseProfile(id: profile.id, imageURL: profile.imageURL)
            } else {
                state.selectedProfile = nil
            }
            return .none
            
        case let .프로필_목록_조회_API_반영(images):
            state.domain.imageList = images
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .닉네임_중복_확인_API:
            return .run { [nickName = state.text] send in
                let result = try await userClient.닉네임_중복_체크(nickName)
                await send(.inner(.닉네임_중복_확인_API_반영(result.isDuplicate)))
            }
            
        case .닉네임_조회_API:
            return .run { send in
                let user = try await userClient.닉네임_조회().toDomain()
                await send(.inner(.닉네임_조회_API_반영(user)), animation: .easeInOut)
            }
            
        case .프로필_목록_조회_API:
            return .run { send in
                let response = try await userClient.프로필_이미지_목록_조회()
                let images = response.map { $0.toDomain() }
                await send(.inner(.프로필_목록_조회_API_반영(images: images)))
            }
        }
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        case .profile(.이미지_선택했을때(let imageInfo)):
            state.isProfileSheetPresented = false
            state.selectedProfile = imageInfo
            
            return .send(.inner(.닉네임_텍스트_변경되었을때))
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}

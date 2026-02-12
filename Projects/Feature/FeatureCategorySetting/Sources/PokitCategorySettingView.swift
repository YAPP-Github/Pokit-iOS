//
//  PokitCategorySettingView.swift
//  Feature
//
//  Created by 김민호 on 7/25/24.

import SwiftUI

import ComposableArchitecture
import Domain
import DSKit
import Util
import NukeUI

@ViewAction(for: PokitCategorySettingFeature.self)
public struct PokitCategorySettingView: View {
    @Environment(\.scenePhase)
    private var scenePhase
    
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
                PokitDivider()
                    .padding(.horizontal, -20)
                    .padding(.top, 28)

                // 공동 편집 중이면 알림 받기 표시 (소유자, 참여자 모두)
                if store.isCoEditing {
                    alarmSettingSection
                }

                // 소유자만 전체 공개 설정과 키워드 표시
                if store.isOwner {
                    openTypeSettingSection
                    keywordSection
                }

                Spacer()
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
            .overlay(alignment: .bottom) {
                saveButton
            }
            .padding(.top, 16)
//            .pokitMaxWidth()
            .pokitNavigationBar { navigationBar }
            .sheet(isPresented: $store.isProfileSheetPresented) {
                PokitProfileBottomSheet(
                    selectedImage: store.selectedProfile,
                    images: store.profileImages,
                    delegateSend: { store.send(.scope(.profile($0))) }
                )
            }
            .sheet(isPresented: $store.isKeywordSheetPresented) {
                PokitKeywordBottomSheet(
                    selectedKeywordType: store.selectedKeywordType,
                    action: { send(.키워드_선택_버튼_눌렀을때($0)) }
                )
            }
            .sheet(isPresented: $store.showAlertSheet) {
                WithPerceptionTracking {
                    PokitAlertBottomSheet(store: store)
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .dismissKeyboard(focused: $isFocused)
            .task { await send(.뷰가_나타났을때).finish() }
            .onChange(of: scenePhase) { newValue in
                send(.scenePhase_바꼈을때(newValue))
            }
        }
    }
}
//MARK: - Configure View
private extension PokitCategorySettingView {
    @ViewBuilder
    var navigationBar: some View {
        let title: String = {
            // 참여자는 "포킷 설정", 소유자는 기존 타이틀
            if store.isParticipant {
                return "포킷 설정"
            }
            return store.type.title
        }()

        PokitHeader(title: title) {
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
                Circle().foregroundStyle(.pokit(.bg(.primary)))
                    .overlay {
                        image
                            .resizable()
                            .padding(10)
                            .clipShape(.circle)
                    }
            } else {
                WithPerceptionTracking {
                    ZStack {
                        Color.pokit(.bg(.primary))
                        if store.selectedProfile?.imageURL != nil {
                            PokitSpinner()
                                .foregroundStyle(.pokit(.icon(.brand)))
                                .frame(width: 48, height: 48)
                        }
                    }
                    .clipShape(.circle)
                }
            }
        }
        .frame(width: 80, height: 80)
        .overlay(alignment: .bottomTrailing) {
            // 소유자만 프로필 편집 버튼 표시
            if store.isOwner {
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
                    .padding(.bottom, 3)
            }
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
                type: store.isOwner && !store.categoryName.isEmpty ? .iconR(
                    icon: .icon(.x),
                    action: { send(.포킷명지우기_버튼_눌렀을때) }
                ) : .text,
                shape: .rectangle,
                state: store.isParticipant
                    ? .constant(.disable)
                    : $store.pokitNameTextInpuState,
                placeholder: store.isOwner ? "포킷명을 입력해주세요." : "",
                info: store.isParticipant ? "수정 권한이 없습니다." : nil,
                maxLetter: 10,
                focusState: $isFocused,
                equals: true
            )
            .disabled(!store.isOwner)
        }
    }
    
    /// 알림 받기
    var alarmSettingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: .init(
                get: { store.alertEnable },
                set: { send(.알림_권한_바인딩($0)) }
            )) {
                Text("알림 받기")
                    .pokitFont(.b1(.b))
                    .foregroundStyle(.pokit(.text(.primary)))
            }
            .tint(.pokit(.icon(.brand)))
            Text("포킷이 수정되면 알림을 보내드립니다.")
                .pokitFont(.detail1)
                .foregroundStyle(.pokit(.text(.tertiary)))
        }
        .padding(.vertical, 12)
        .padding(.leading, 8)
        .padding(.top, 16)
    }
    
    /// 공개 여부 설정
    var openTypeSettingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: $store.isPublicType) {
                Text("전체 공개로 설정하기")
                    .pokitFont(.b1(.b))
                    .foregroundStyle(.pokit(.text(.primary)))
            }
            .tint(.pokit(.icon(.brand)))
            Text("포킷에 저장된 링크가 다른 사용자에게 추천됩니다.")
                .pokitFont(.detail1)
                .foregroundStyle(.pokit(.text(.tertiary)))
        }
        .padding(.vertical, 12)
        .padding(.leading, 8)
        .padding(.top, 16)
    }
    
    /// 포킷 키워드
    var keywordSection: some View {
        Group {
            if store.isPublicType {
                VStack(alignment: .leading, spacing: 4) {
                    Button(action: { send(.키워드_바텀시트_활성화(true)) }) {
                        HStack {
                            Text("포킷 키워드")
                                .pokitFont(.b1(.b))
                                .foregroundStyle(.pokit(.text(.primary)))
                            
                            Spacer()
                            
                            Image(.icon(.arrowRight))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.pokit(.icon(.primary)))
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Text(store.keywordSelectType.label)
                        .pokitFont(.detail1)
                        .foregroundStyle(store.keywordSelectType.fontColor)
                }
                .padding(.vertical, 12)
                .padding(.leading, 8)
                .padding(.top, 8)
            }
        }
        .animation(.smooth, value: store.isPublicType)
    }
    /// 저장하기 버튼
    var saveButton: some View {
        PokitBottomButton(
            "저장하기",
            state: store.saveButtonEnabled
            ? .filled(.primary)
            : .disable,
            action: { send(.저장_버튼_눌렀을때) }
        )
        .gradientBackground()
        .keyboardAnchor(store.isKeyboardVisible)
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



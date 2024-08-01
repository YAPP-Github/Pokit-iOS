//
//  LinkDetailView.swift
//  Feature
//
//  Created by 김도형 on 7/19/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: LinkDetailFeature.self)
public struct LinkDetailView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<LinkDetailFeature>
    
    /// - Initializer
    public init(store: StoreOf<LinkDetailFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension LinkDetailView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                title
                ScrollView {
                    VStack {
                        linkContent
                            .padding(.vertical, 24)
                    }
                }
                .onAppear {
                    send(.linkDetailViewOnAppeared, animation: .smooth)
                }
                .overlay(alignment: .bottom) {
                    bottomToolbar
                }
            }
            .padding(.top, 28)
            .background(.pokit(.bg(.base)))
            .pokitPresentationBackground()
            .pokitPresentationCornerRadius()
            .presentationDetents([.medium, .large])
            .sheet(isPresented: $store.showAlert) {
                PokitAlert(
                    "링크를 정말 삭제하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며, \n복구하실 수 없습니다.",
                    confirmText: "삭제",
                    action: { send(.deleteAlertConfirmTapped) }
                )
            }
        }
    }
}
//MARK: - Configure View
private extension LinkDetailView {
    var remindAndBadge: some View {
        HStack(spacing: 4) {
            if store.link.isRemind {
                Image(.icon(.bell))
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(.pokit(.icon(.inverseWh)))
                    .padding(2)
                    .background {
                        Circle()
                            .fill(.pokit(.bg(.brand)))
                    }
            }
            
            PokitBadge(store.link.pokit, state: .default)
            
            Spacer()
        }
    }
    
    var title: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                remindAndBadge
                
                Text(store.link.title)
                    .pokitFont(.title3)
                    .foregroundStyle(.pokit(.text(.primary)))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                HStack {
                    Spacer()
                    
                    Text(linkDateText)
                        .pokitFont(.detail2)
                        .foregroundStyle(.pokit(.text(.tertiary)))
                }
            }
            .padding(.horizontal, 20)
            
            Divider()
                .foregroundStyle(.pokit(.border(.tertiary)))
                .padding(.top, 4)
        }
    }
    
    var linkContent: some View {
        VStack(spacing: 16) {
            if let title = store.linkTitle,
               let image = store.linkImage {
                PokitLinkPreview(
                    title: title,
                    url: store.link.url,
                    image: image
                )
                .pokitBlurReplaceTransition(.smooth)
            }
            
            linkMemo
        }
        .padding(.horizontal, 20)
    }
    
    var linkMemo: some View {
        HStack {
            VStack {
                Text(store.link.memo)
                    .pokitFont(.b3(.r))
                    .foregroundStyle(.pokit(.text(.primary)))
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(16)
            
            Spacer()
        }
        .frame(minHeight: 132)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 1, green: 0.96, blue: 0.89))
        }
    }
    
    var favorite: some View {
        Image(.icon(.star))
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundStyle(
                store.link.isFavorite ? .pokit(.icon(.brand)) : .pokit(.icon(.tertiary))
            )
    }
    
    var bottomToolbar: some View {
        HStack(spacing: 12) {
            favorite
            
            Spacer()
            
            toolbarButton(
                .icon(.share),
                action: { send(.sharedButtonTapped) }
            )
            
            toolbarButton(
                .icon(.edit),
                action: { send(.editButtonTapped) }
            )
            
            toolbarButton(
                .icon(.trash),
                action: { send(.deleteButtonTapped) }
            )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(.pokit(.bg(.base)))
        .overlay(alignment: .top) {
            Divider()
                .foregroundStyle(.pokit(.border(.tertiary)))
        }
    }
    
    @ViewBuilder
    func toolbarButton(
        _ icon: PokitImage,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.pokit(.icon(.secondary)))
        }
    }
}
private extension LinkDetailView {
    var linkDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd hh:mm"
        return formatter.string(from: store.link.createdAt)
    }
}
//MARK: - Preview
#Preview {
    LinkDetailView(
        store: Store(
            initialState: .init(
                link: LinkDetailMock(
                    title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                    url: "https://www.youtube.com/watch?v=xSTwqKUyM8k",
                    createdAt: .now,
                    memo: "건강과 지속 가능성을 추구",
                    pokit: "아티클",
                    isRemind: true,
                    isFavorite: true
                )
            ),
            reducer: { LinkDetailFeature() }
        )
    )
}



//
//  LinkDetailView.swift
//  Feature
//
//  Created by 김도형 on 7/19/24.

import SwiftUI

import ComposableArchitecture
import Domain
import DSKit

@ViewAction(for: ContentDetailFeature.self)
public struct ContentDetailView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<ContentDetailFeature>
    
    /// - Initializer
    public init(store: StoreOf<ContentDetailFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension ContentDetailView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                if let content = store.content {
                    title(content: content)
                    ScrollView {
                        VStack {
                            contentLinkPreview(content: content)
                                .padding(.vertical, 24)
                        }
                    }
                    .overlay(alignment: .bottom) {
                        bottomToolbar(content: content)
                    }
                } else {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.pokit(.icon(.brand)))
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            .padding(.top, 28)
            .background(.pokit(.bg(.base)))
            .pokitPresentationBackground()
            .pokitPresentationCornerRadius()
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium, .large])
            .sheet(isPresented: $store.showAlert) {
                PokitAlert(
                    "링크를 정말 삭제하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며, \n복구하실 수 없습니다.",
                    confirmText: "삭제",
                    action: { send(.deleteAlertConfirmTapped) }
                )
            }
            .onAppear {
                send(.contentDetailViewOnAppeared, animation: .smooth)
            }
        }
    }
}
//MARK: - Configure View
private extension ContentDetailView {
    @ViewBuilder
    func remindAndBadge(content: ContentDetail.Content) -> some View {
        HStack(spacing: 4) {
            if content.alertYn == .yes {
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
            
            PokitBadge(content.categoryName, state: .default)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func title(content: ContentDetail.Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                remindAndBadge(content: content)
                
                Text(content.title)
                    .pokitFont(.title3)
                    .foregroundStyle(.pokit(.text(.primary)))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                HStack {
                    Spacer()
                    
                    Text(contentDateText)
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
    
    @ViewBuilder
    func contentLinkPreview(content: ContentDetail.Content) -> some View {
        VStack(spacing: 16) {
            if let title = store.linkTitle,
               let image = store.linkImage {
                PokitLinkPreview(
                    title: title,
                    url: content.data,
                    image: image
                )
                .pokitBlurReplaceTransition(.smooth)
            }
            
            contentMemo(content: content)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func contentMemo(content: ContentDetail.Content) -> some View {
        HStack {
            VStack {
                Text(content.memo)
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
    
    @ViewBuilder
    func favorite(content: ContentDetail.Content) -> some View {
        Button(action: { send(.favoriteButtonTapped, animation: .smooth) }) {
            let isFavorite = content.favorites
            
            Image(isFavorite ? .icon(.starFill) : .icon(.star))
                .resizable()
                .scaledToFit()
                .foregroundStyle(.pokit(.icon(isFavorite ? .brand : .tertiary)))
                .frame(width: 24, height: 24)
        }
    }
    
    @ViewBuilder
    func bottomToolbar(content: ContentDetail.Content) -> some View {
        HStack(spacing: 12) {
            favorite(content: content)
            
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
private extension ContentDetailView {
    var contentDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd hh:mm"
        return formatter.string(from: store.content?.createdAt ?? .now)
    }
}
//MARK: - Preview
#Preview {
    ContentDetailView(
        store: Store(
            initialState: .init(
                contentId: 0
            ),
            reducer: { ContentDetailFeature() }
        )
    )
}



//
//  PokitParticipantsBottomSheet.swift
//  FeatureCategoryDetail
//
//  Created by 김도형 on 12/25/25.
//

import SwiftUI
import Domain
import DSKit
import NukeUI

struct PokitParticipantsBottomSheet: View {
    @State
    private var height: CGFloat = 0
    let title: String
    let participants: [InvitedUser]
    let isCreator: Bool
    let currentUserId: Int?
    let creatorUserId: Int?
    let delegateSend: ((CategoryDetailFeature.Action.ParticipantsBottomSheetDelegate) -> Void)?

    init(
        title: String,
        participants: [InvitedUser],
        isCreator: Bool,
        currentUserId: Int?,
        creatorUserId: Int?,
        delegateSend: ((CategoryDetailFeature.Action.ParticipantsBottomSheetDelegate) -> Void)?
    ) {
        self.title = title
        self.participants = participants
        self.isCreator = isCreator
        self.currentUserId = currentUserId
        self.creatorUserId = creatorUserId
        self.delegateSend = delegateSend
    }

    var body: some View {
        VStack(spacing: 0) {
            participantsList
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.height(height)])
        .pokitPresentationCornerRadius()
        .pokitPresentationBackground()
        .readHeight()
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            if let height {
                self.height = height
            }
        }
        .ignoresSafeArea(.all)
        .padding(.top, 12)
        .padding(.bottom, -20)
    }

    private var headerView: some View {
        HStack {
            Text(title)
                .pokitFont(.b1(.b))
                .foregroundStyle(.pokit(.text(.primary)))

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private var participantsList: some View {
        let sortedParticipants = participants.sorted { first, second in
            // 본인을 맨 위로
            if first.id == currentUserId { return true }
            if second.id == currentUserId { return false }
            return false
        }

        ForEach(sortedParticipants) { participant in
            let isLast = sortedParticipants.last == participant

            participantCell(participant)
                .overlay(if: !isLast, alignment: .bottom) {
                    Rectangle().fill(.pokit(.border(.tertiary)))
                        .frame(height: 1)
                }
        }
    }

    @ViewBuilder
    private func participantCell(_ participant: InvitedUser) -> some View {
        let isCurrentUser = currentUserId == participant.id
        let isOwner = creatorUserId == participant.id

        HStack(spacing: 12) {
            if let profile = participant.profile {
                LazyImage(url: URL(string: profile.imageURL)) { state in
                    Group {
                        if let image = state.image {
                            image
                                .resizable()
                        } else {
                            Circle()
                                .fill(.pokit(.bg(.disable)))
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(
                        isCurrentUser
                        ? .pokit(.border(.brand))
                        : .pokit(.border(.secondary)),
                        lineWidth: 1
                    ))
                }
            } else {
                Image(.image(.profile))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .overlay(Circle().stroke(
                        isCurrentUser
                        ? .pokit(.border(.brand))
                        : .pokit(.border(.secondary)),
                        lineWidth: 1
                    ))
            }

            Text(participant.nickname)
                .pokitFont(.b1(.m))
                .foregroundStyle(.pokit(.text(.secondary)))

            Spacer()

            if isOwner && !isCurrentUser  {
                // 소유자 라벨 (비활성화 스타일)
                PokitTextButton(
                    "소유자",
                    state: .default(.secondary),
                    size: .medium,
                    shape: .rectangle,
                    action: { }
                )
                .disabled(true)
            } else if isCreator && !isCurrentUser {
                // 내보내기 버튼 (소유자가 다른 참여자 내보낼 때)
                PokitTextButton(
                    "내보내기",
                    state: .stroke(.secondary),
                    size: .medium,
                    shape: .rectangle,
                    action: { delegateSend?(.removeParticipant(participant)) }
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

@available(iOS 18.0, *)
#Preview {
    @Previewable
    @State var isPresented: Bool = true

    ZStack {
        Color.green.ignoresSafeArea()
    }
    .sheet(isPresented: $isPresented) {
        PokitParticipantsBottomSheet(
            title: "포킷 공유 유저",
            participants: [
                .init(id: 1, nickname: "Pokitmons", profile: nil),
                .init(id: 2, nickname: "name1", profile: nil),
                .init(id: 3, nickname: "name2", profile: nil)
            ],
            isCreator: true,
            currentUserId: 1,
            creatorUserId: 2,
            delegateSend: { _ in }
        )
    }
}

//
//  PokitReportBottomSheet.swift
//  DSKit
//
//  Created by Codex on 4/6/26.
//

import SwiftUI

public struct PokitReportBottomSheet: View {
    @Environment(\.dismiss)
    private var dismiss

    @State
    private var height: CGFloat = 0
    @State
    private var selectedReasonID: String?

    private let title: String?
    private let message: String?
    private let reasons: [Item]
    private let onConfirm: (Item) -> Void

    public init(
        title: String? = nil,
        message: String? = nil,
        reasons: [Item],
        initialSelectedReasonID: String? = nil,
        onConfirm: @escaping (Item) -> Void
    ) {
        self._selectedReasonID = State(initialValue: initialSelectedReasonID)
        self.title = title
        self.message = message
        self.reasons = reasons
        self.onConfirm = onConfirm
    }

    public var body: some View {
        GeometryReader { proxy in
            let bottomSafeArea = proxy.safeAreaInsets.bottom
            let topSafeArea = proxy.safeAreaInsets.top

            VStack(spacing: 0) {
                if title != nil || message != nil {
                    header
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                }

                reasonList

                actionButtons
            }
            .padding(.top, 12 - topSafeArea)
            .padding(.bottom, 36 - bottomSafeArea)
            .background(.pokit(.bg(.base)))
            .pokitPresentationCornerRadius()
            .pokitPresentationBackground()
            .presentationDragIndicator(.visible)
            .readHeight()
            .onPreferenceChange(HeightPreferenceKey.self) { height in
                if let height {
                    self.height = height
                }
            }
            .presentationDetents([.height(height)])
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

private extension PokitReportBottomSheet {
    @ViewBuilder
    var header: some View {
        VStack(spacing: 8) {
            if let title {
                Text(title)
                    .pokitFont(.title2)
                    .foregroundStyle(.pokit(.text(.primary)))
                    .multilineTextAlignment(.center)
            }

            if let message {
                Text(message)
                    .pokitFont(.b2(.m))
                    .foregroundStyle(.pokit(.text(.secondary)))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    var reasonList: some View {
        VStack(spacing: 0) {
            ForEach(reasons) { reason in
                Button {
                    selectedReasonID = reason.id
                } label: {
                    HStack(spacing: 12) {
                        PokitRadio(
                            state: selectedReasonID == reason.id
                            ? .active
                            : .default
                        )

                        Text(reason.title)
                            .pokitFont(.b1(.m))
                            .foregroundStyle(.pokit(.text(.primary)))
                            .multilineTextAlignment(.leading)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
                .buttonStyle(.plain)

                if reason != reasons.last {
                    Rectangle()
                        .fill(.pokit(.border(.tertiary)))
                        .frame(height: 1)
                }
            }
        }
        .background(.pokit(.bg(.base)))
    }

    var actionButtons: some View {
        HStack(spacing: 8) {
            PokitBottomButton(
                "취소",
                state: .default(.primary),
                action: cancel
            )

            PokitBottomButton(
                "신고",
                state: selectedReasonID == nil ? .disable : .filled(.primary),
                action: confirm
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .background(.pokit(.bg(.base)))
    }

    func cancel() {
        dismiss()
    }

    func confirm() {
        guard
            let selectedReasonID,
            let selectedReason = reasons.first(where: { $0.id == selectedReasonID })
        else { return }
        onConfirm(selectedReason)
        dismiss()
    }
}

public extension PokitReportBottomSheet {
    struct Item: Identifiable, Equatable {
        public let id: String
        public let title: String

        public init(id: String, title: String) {
            self.id = id
            self.title = title
        }
    }
}

//
//  PokitAlertBottomSheet.swift
//  FeatureCategorySetting
//
//  Created by 김도형 on 12/16/25.
//

import SwiftUI

import ComposableArchitecture
import DSKit

struct PokitAlertBottomSheet: View {
    @State
    private var height: CGFloat = 439
    
    private let store: StoreOf<PokitCategorySettingFeature>
    
    init(store: StoreOf<PokitCategorySettingFeature>) {
        self.store = store
    }
    
    var body: some View {
        GeometryReader { proxy in
            let bottomSafeArea = proxy.safeAreaInsets.bottom
            let topSafeArea = proxy.safeAreaInsets.top
            
            VStack(spacing: 20) {
                title
                    .padding(.top, 36)
                
                Image(.image(.alertExplain))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                
                buttons
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 36 - bottomSafeArea)
            .padding(.top, 12 - topSafeArea)
            .ignoresSafeArea(edges: [.bottom, .top])
            .readHeight()
            .onPreferenceChange(HeightPreferenceKey.self) { height in
                if let height { self.height = height }
            }
        }
        .presentationDragIndicator(.visible)
        .pokitPresentationCornerRadius()
        .pokitPresentationBackground()
        .presentationDetents([.height(height)])
        
    }
}

// MARK: - Configure Views
private extension PokitAlertBottomSheet {
    var title: some View {
        VStack(spacing: 8) {
            Text("포킷 앱 알림을 켜주세요!")
                .pokitFont(.title2)
                .foregroundStyle(.pokit(.text(.primary)))
            
            Text("시스템 알림이 꺼져 있어요.\n포킷 앱 알림을 허용해 주시면 알림을 보내드려요.")
                .pokitFont(.b2(.m))
                .foregroundStyle(.pokit(.text(.secondary)))
        }
    }
    
    var buttons: some View {
        HStack(spacing: 8) {
            PokitBottomButton("다음에", state: .default(.primary)) {
                store.send(.view(.알림_바텀시트_다음에_버튼_눌렀을떼))
            }
            
            PokitBottomButton("알림 켜기", state: .filled(.primary)) {
                store.send(.view(.알림_바텀시트_알림켜기_버튼_눌렀을떼))
            }
        }
        .padding(.vertical, 16)
    }
}

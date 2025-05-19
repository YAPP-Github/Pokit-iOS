//
//  PokitLinkEditFloatView.swift
//  Feature
//
//  Created by 김민호 on 12/27/24.
//

import SwiftUI

/// `포킷` -> `미분류` -> `편집하기` -> `하단 float Button`
public struct PokitLinkEditFloatView: View {
    /// 전체 선택/해제 toggle
    @State private var isChecked: Bool = false
    @Binding private var isActive: Bool
    private let delegateSend: ((PokitLinkEditFloatView.Delegate) -> Void)?
    
    public init(
        isActive: Binding<Bool>,
        delegateSend: ((PokitLinkEditFloatView.Delegate) -> Void)?
    ) {
        self._isActive = isActive
        self.delegateSend = delegateSend
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(
                isActive
                ? .pokit(.bg(.brand))
                : .pokit(.bg(.disable))
            )
            .frame(height: 84)
            .overlay {
                HStack(spacing: 0) {
                    button(isChecked ? .전체해제 : .전체선택)
                    Spacer()
                    button(.링크삭제)
                    Spacer()
                    button(.포킷이동)
                }
                .padding(.horizontal, 20)
            }
            .pokitShadow(
                x: 0,
                y: -2,
                blur: 20,
                spread: 0,
                color: Color.black,
                colorPercent: 10
            )
            .animation(.pokitSpring, value: isActive)
    }
}
private extension PokitLinkEditFloatView {
    func button(_ type: PokitLinkEditFloatType) -> some View {
        Button {
            if type == .전체선택 || 
               type == .전체해제 {
                isChecked.toggle()
            }
            delegateSend?(type.action)
        } label: {
            VStack(spacing: 4) {
                type.icon
                Text(type.label)
                    .pokitFont(.detail2)
                    .padding(.horizontal, 18)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .disabled(!isActive)
    }
}
public extension PokitLinkEditFloatView {
    enum PokitLinkEditFloatType: String {
        case 전체해제 = "전체 해제"
        case 전체선택 = "전체 선택"
        case 링크삭제 = "링크 삭제"
        case 포킷이동 = "포킷 이동"
        
        var label: String { self.rawValue }
        
        var icon: Image {
            switch self {
            case .전체해제:
                return Image(.icon(.allUncheck))
            case .전체선택:
                return Image(.icon(.allCheck))
            case .링크삭제:
                return Image(.icon(.trash))
            case .포킷이동:
                return Image(.icon(.movePokit))
            }
        }
        
        var action: Delegate {
            switch self {
            case .전체해제:
                return .전체해제_버튼_눌렀을때
            case .전체선택:
                return .전체선택_버튼_눌렀을때
            case .링크삭제:
                return .링크삭제_버튼_눌렀을때
            case .포킷이동:
                return .포킷이동_버튼_눌렀을때
            }
        }
    }
    
    enum Delegate {
        case 전체선택_버튼_눌렀을때
        case 전체해제_버튼_눌렀을때
        case 링크삭제_버튼_눌렀을때
        case 포킷이동_버튼_눌렀을때
    }
}
#Preview {
    PokitLinkEditFloatView(
        isActive: .constant(true),
        delegateSend: {_ in }
    ).padding(20)
}

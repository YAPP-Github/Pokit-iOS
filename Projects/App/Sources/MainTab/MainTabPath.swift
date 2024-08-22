//
//  MainTabPath.swift
//  App
//
//  Created by 김민호 on 7/29/24.
//

import Foundation

import ComposableArchitecture
import FeatureSetting
import FeatureCategoryDetail
import FeatureCategorySetting
import FeatureContentDetail
import FeatureContentSetting
import FeatureContentList
import FeatureCategorySharing

@Reducer
public struct MainTabPath {
    @ObservableState
    public enum State: Equatable {
        case 알림함(PokitAlertBoxFeature.State)
        case 검색(PokitSearchFeature.State)
        case 설정(PokitSettingFeature.State)
        case 포킷추가및수정(PokitCategorySettingFeature.State)
        case 링크추가및수정(ContentSettingFeature.State)
        case 카테고리상세(CategoryDetailFeature.State)
        case 링크목록(ContentListFeature.State)
        case 링크공유(CategorySharingFeature.State)
    }

    public enum Action {
        case 알림함(PokitAlertBoxFeature.Action)
        case 검색(PokitSearchFeature.Action)
        case 설정(PokitSettingFeature.Action)
        case 포킷추가및수정(PokitCategorySettingFeature.Action)
        case 링크추가및수정(ContentSettingFeature.Action)
        case 카테고리상세(CategoryDetailFeature.Action)
        case 링크목록(ContentListFeature.Action)
        case 링크공유(CategorySharingFeature.Action)
    }

    public var body: some Reducer<State, Action> {
        Scope(state: \.알림함, action: \.알림함) { PokitAlertBoxFeature() }
        Scope(state: \.검색, action: \.검색) { PokitSearchFeature() }
        Scope(state: \.설정, action: \.설정) { PokitSettingFeature() }
        Scope(state: \.포킷추가및수정, action: \.포킷추가및수정) { PokitCategorySettingFeature() }
        Scope(state: \.링크추가및수정, action: \.링크추가및수정) { ContentSettingFeature() }
        Scope(state: \.카테고리상세, action: \.카테고리상세) { CategoryDetailFeature() }
        Scope(state: \.링크목록, action: \.링크목록) { ContentListFeature() }
        Scope(state: \.링크공유, action: \.링크공유) { CategorySharingFeature() }
    }
}

public extension MainTabFeature {
    var navigationReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            /// - 네비게이션 바 `알림`버튼 눌렀을 때
            case .pokit(.delegate(.alertButtonTapped)),
                 .remind(.delegate(.alertButtonTapped)):
                state.path.append(.알림함(PokitAlertBoxFeature.State()))
                return .none

            /// - 네비게이션 바 `검색`버튼 눌렀을 때
            case .pokit(.delegate(.searchButtonTapped)),
                 .remind(.delegate(.searchButtonTapped)):
                state.path.append(.검색(PokitSearchFeature.State()))
                return .none

            /// - 네비게이션 바 `설정`버튼 눌렀을 때
            case .pokit(.delegate(.settingButtonTapped)):
                state.path.append(.설정(PokitSettingFeature.State()))
                return .none

            /// - 포킷 `수정`버튼 눌렀을 때
            case let .pokit(.delegate(.수정하기(category))),
                 let .path(.element(_, action: .카테고리상세(.delegate(.포킷수정(category))))):
                state.path.append(.포킷추가및수정(PokitCategorySettingFeature.State(
                    type: .수정,
                    categoryId: category.id,
                    categoryImage: category.categoryImage,
                    categoryName: category.categoryName
                )))
                return .none

            /// - 포킷 `추가` 버튼 눌렀을 때
            case .delegate(.포킷추가하기),
                 .path(.element(_, action: .링크추가및수정(.delegate(.포킷추가하기)))):
                state.path.append(.포킷추가및수정(PokitCategorySettingFeature.State(type: .추가)))
                return .none

            /// - 포킷 `추가` or `수정`이 성공적으로 `완료`되었을 때
            case let .path(.element(id: stackElementItem, action: .포킷추가및수정(.delegate(.settingSuccess(categoryName, categoryId))))):
                state.path.removeLast()
                guard let lastPath = state.path.last else { return .none }
                switch lastPath {
                case .링크공유:
                    return .send(.path(.element(id: stackElementItem, action: .링크공유(.delegate(.공유받은_카테고리_저장(categoryName: categoryName))))))
                default: return .none
                }

            /// - 포킷 카테고리 아이템 눌렀을 때
            case let .pokit(.delegate(.categoryTapped(category))):
                state.path.append(.카테고리상세(CategoryDetailFeature.State(category: category)))
                return .none

            case .path(.element(_, action: .카테고리상세(.delegate(.포킷삭제)))):
                /// Todo: id값을 받아와 삭제API 보내기
                state.path.removeLast()
                return .none

            /// - 링크 상세
            case let .path(.element(_, action: .카테고리상세(.delegate(.contentItemTapped(content))))),
                 let .pokit(.delegate(.contentDetailTapped(content))),
                 let .remind(.delegate(.링크상세(content))),
                 let .path(.element(_, action: .링크목록(.delegate(.링크상세(content: content))))),
                 let .path(.element(_, action: .검색(.delegate(.linkCardTapped(content: content))))):
                
                state.contentDetail = ContentDetailFeature.State(contentId: content.id)
                return .none

            /// - 링크상세 바텀시트에서 링크수정으로 이동
            case let .contentDetail(.presented(.delegate(.editButtonTapped(id)))),
                 let .pokit(.delegate(.링크수정하기(id))),
                 let .remind(.delegate(.링크수정(id))),
                 let .path(.element(_, action: .카테고리상세(.delegate(.링크수정(id))))),
                 let .path(.element(_, action: .링크목록(.delegate(.링크수정(id))))),
                 let .path(.element(_, action: .검색(.delegate(.링크수정(id))))),
                 let .path(.element(_, action: .알림함(.delegate(.moveToContentEdit(id))))):
                return .run { send in await send(.inner(.링크추가및수정이동(contentId: id))) }
            
            /// - 컨텐츠 상세보기 닫힘
            case .contentDetail(.dismiss):
                guard let stackElementId = state.path.ids.last,
                      let lastPath = state.path.last else {
                    switch state.selectedTab {
                    case .pokit:
                        return .send(.pokit(.delegate(.미분류_카테고리_컨텐츠_조회)))
                    case .remind:
                        return .send(.remind(.delegate(.컨텐츠목록_조회)))
                    }
                }
                switch lastPath {
                case .링크목록:
                    return .send(.path(.element(id: stackElementId, action: .링크목록(.delegate(.컨텐츠_목록_조회)))))
                case .검색:
                    return .send(.path(.element(id: stackElementId, action: .검색(.delegate(.컨텐츠_검색)))))
                case .카테고리상세:
                    return .send(.path(.element(id: stackElementId, action: .카테고리상세(.delegate(.카테고리_내_컨텐츠_목록_조회)))))
                default: return .none
                }

            case let .inner(.링크추가및수정이동(contentId: id)):
                state.path.append(.링크추가및수정(
                    ContentSettingFeature.State(contentId: id)
                ))
                return .send(.contentDetail(.dismiss))

            /// - 링크 추가하기
            case .delegate(.링크추가하기):
                state.path.append(.링크추가및수정(ContentSettingFeature.State(urlText: state.link)))
                state.link = nil
                return .none

            /// - 링크추가 및 수정에서 저장하기 눌렀을 때
            case let .path(.element(stackElementId, action: .링크추가및수정(.delegate(.저장하기_완료)))):
                state.path.removeLast()
                switch state.path.last {
                case .검색:
                    return .send(.path(.element(id: stackElementId, action: .검색(.delegate(.컨텐츠_검색)))))
                default:
                    return .none
                }
            /// - 각 화면에서 링크 복사 감지했을 때 (링크 추가 및 수정 화면 제외)
            case let .path(.element(_, action: .알림함(.delegate(.linkCopyDetected(url))))),
                 let .path(.element(_, action: .검색(.delegate(.linkCopyDetected(url))))),
                 let .path(.element(_, action: .설정(.delegate(.linkCopyDetected(url))))),
                 let .path(.element(_, action: .카테고리상세(.delegate(.linkCopyDetected(url))))),
                 let .path(.element(_, action: .포킷추가및수정(.delegate(.linkCopyDetected(url))))),
                 let .path(.element(_, action: .링크목록(.delegate(.linkCopyDetected(url))))):
                return .run { send in await send(.inner(.linkCopySuccess(url)), animation: .pokitSpring) }
            /// 링크목록 `안읽음`
            case .remind(.delegate(.링크목록_안읽음)):
                state.path.append(.링크목록(ContentListFeature.State(contentType: .unread)))
                return .none
            /// 링크목록 `즐겨찾기`
            case .remind(.delegate(.링크목록_즐겨찾기)):
                state.path.append(.링크목록(ContentListFeature.State(contentType: .favorite)))
                return .none
                
            case .path(.element(_, action: .설정(.delegate(.로그아웃)))):
                return .send(.delegate(.로그아웃))
            case .path(.element(_, action: .설정(.delegate(.회원탈퇴)))):
                return .send(.delegate(.회원탈퇴))
            
            case let .inner(.공유포킷_이동(categoryId: categoryId)):
                state.path.append(.링크공유(CategorySharingFeature.State(catgoryId: categoryId)))
                return .none
                
            /// 링크 공유에서 컨텐츠 상세보기
            case let .path(.element(_, action: .링크공유(.delegate(.컨텐츠_아이템_클릭(categoryId: categoryId, content: content))))):
                state.contentDetail = ContentDetailFeature.State(content: .init(
                    id: content.id,
                    category: .init(
                        categoryId: categoryId,
                        categoryName: content.categoryName
                    ),
                    title: content.title,
                    data: content.data,
                    memo: content.memo,
                    createdAt: content.createdAt,
                    favorites: nil,
                    alertYn: .no
                ))
                return .none
            
            case let .path(.element(_, action: .링크공유(.delegate(.공유받은_카테고리_수정(categoryName: categoryName))))):
                state.path.append(.포킷추가및수정(.init(type: .수정, categoryName: categoryName)))
                return .none
            default: return .none
            }
        }
        .forEach(\.path, action: \.path) { MainTabPath() }
    }
}


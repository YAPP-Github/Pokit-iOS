generate:
	make templates_delete
	make templates

	make clean
	make download
	tuist install
	tuist generate

release:
	make clean
	make download
	tuist install
	TUIST_DEVELOPMENT_TEAM=$(DEVELOPMENT_TEAM) tuist generate

test:
	make clean
	make download
	tuist install
	tuist cache
	TUIST_DEVELOPMENT_TEAM=$(DEVELOPMENT_TEAM) tuist generate App
	
clean:
	tuist clean
	rm -rf **/*.xcodeproj
	rm -rf *.xcworkspace
	
download:
	make download-privates

INSTALL_DIR := $(HOME)/Library/Developer/Xcode/Templates/File\ Templates/Pokit_TCA.xctemplate

FILES := templates/Pokit_TCA.xctemplate/___FILEBASENAME___Feature.swift \
	templates/Pokit_TCA.xctemplate/___FILEBASENAME___View.swift \
         templates/Pokit_TCA.xctemplate/TemplateIcon.png \
         templates/Pokit_TCA.xctemplate/TemplateInfo.plist

templates: $(FILES)
	@echo "📚 Template file 설치 중"
	@mkdir -p $(INSTALL_DIR)
	@cp -r $(FILES) $(INSTALL_DIR)

templates_delete:
	@echo "🚜 설치되어 있는 Pokit Template file을 우선 삭제합니다."
	@rm -rf $(INSTALL_DIR)

.PHONY: templates generate clean download download-privates

# 2) Private repository로부터 파일 다운로드
download-privates:
	@echo "🤫 Private repository에서 파일을 다운로드 합니다."
	@if [ ! -d "Pokit_iOS_Private" ]; then \
		git clone git@github.com:stealmh/Pokit_iOS_Private.git; \
	fi
	@if [ -f "Pokit_iOS_Private/xcconfig/Debug.xcconfig" ] && [ -f "Pokit_iOS_Private/xcconfig/Release.xcconfig" ]; then \
		mkdir -p xcconfig; \
		cp Pokit_iOS_Private/xcconfig/Debug.xcconfig xcconfig/Debug.xcconfig; \
		cp Pokit_iOS_Private/xcconfig/Release.xcconfig xcconfig/Release.xcconfig; \
		cp Pokit_iOS_Private/auth/AuthKey.p8 Projects/CoreKit/Resources/AuthKey.p8; \
		cp Pokit_iOS_Private/GoogleService-Info.plist Projects/App/Resources/GoogleService-Info.plist; \
		cp Pokit_iOS_Private/GoogleService-Info.plist Projects/App/ShareExtension/Resources/GoogleService-Info.plist; \
		rm -rf Pokit_iOS_Private; \
		echo "✅ Debug.xcconfig와 Release.xcconfig 파일을 성공적으로 다운로드하고 Pokit_iOS_Private 폴더를 삭제했습니다."; \
	else \
		echo "❌ Debug.xcconfig 또는 Release.xcconfig 파일을 찾을 수 없습니다." && exit 1; \
	fi

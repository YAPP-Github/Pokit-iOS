generate:
	make clean
	make templates

	tuist clean
	tuist install
	tuist generate

release:
	tuist clean
	tuist install
	TUIST_DEVELOPMENT_TEAM=$(DEVELOPMENT_TEAM) tuist generate

test:
	tuist clean
	tuist install
	tuist cache
	TUIST_DEVELOPMENT_TEAM=$(DEVELOPMENT_TEAM) tuist generate App
	
download:
	make download-privates

# 1) 템플릿을 다운받음
# 2) Private repository로부터 파일 다운로드
# 3) tuist clean -> install -> generate

# 1)
# File Templates 설치 경로 지정
INSTALL_DIR := $(HOME)/Library/Developer/Xcode/Templates/File\ Templates/Pokit_TCA.xctemplate

# 파일 목록 지정
FILES := templates/Pokit_TCA.xctemplate/___FILEBASENAME___Feature.swift \
	templates/Pokit_TCA.xctemplate/___FILEBASENAME___View.swift \
         templates/Pokit_TCA.xctemplate/TemplateIcon.png \
         templates/Pokit_TCA.xctemplate/TemplateInfo.plist

templates: $(FILES)
	@echo "📚 Template file 설치 중"
	@mkdir -p $(INSTALL_DIR)
	@cp -r $(FILES) $(INSTALL_DIR)

clean:
	@echo "🚜 설치되어 있는 Pokit Template file을 우선 삭제합니다."
	@rm -rf $(INSTALL_DIR)

.PHONY: templates generate clean download download-privates

# 2) Private repository로부터 파일 다운로드
download-privates:
	@echo "🤫 Private repository에서 파일을 다운로드 합니다."
	@if [ ! -d "Pokit_iOS_Private" ]; then \
		git clone git@github.com:stealmh/Pokit_iOS_Private.git; \
	fi
	@cp Pokit_iOS_Private/xcconfig/Secret.xcconfig Projects/App/Resources/Secret.xcconfig

generate:
	make clean
	make templates

	tuist clean
	tuist install
	tuist generate

release:
	tuist clean
	tuist install
	# tuist cache
	# TUIST_DEVELOPMENT_TEAM=$(DEVELOPMENT_TEAM) tuist generate App
	TUIST_DEVELOPMENT_TEAM=$(DEVELOPMENT_TEAM) tuist generate

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

.PHONY: templates generate clean

# 2) Private repository로부터 파일 다운로드
BASE_URL=https://raw.githubusercontent.com/stealmh/Pokit_iOS_Private/main

XCCONFIG_PATHS = \
    xcconfig Secret.xcconfig \

define download_file
	mkdir -p $(1)
	curl -H "Authorization: token $(2)" -o $(1)/$(3) $(BASE_URL)/$(1)/$(3)
endef

download-privates:
	@echo "🤫 Private repository에서 파일을 다운로드 합니다."
	@if [ ! -f .env ]; then \
		read -p "GitHub access token값을 입력 해주세요: " token; \
		echo "GITHUB_ACCESS_TOKEN=$$token" > .env; \
	else \
		/bin/bash -c "source .env; make _download-privates"; \
		exit 0; \
	fi

	make _download-privates

_download-privates:

	$(eval export $(shell cat .env))

	 $(call download_file,fastlane,$$GITHUB_ACCESS_TOKEN,.env)

	$(eval TOTAL_ITEMS = $(words $(XCCONFIG_PATHS)))
	$(foreach index, $(shell seq 1 2 $(TOTAL_ITEMS)), \
		$(eval DIR = $(word $(index), $(XCCONFIG_PATHS))) \
		$(eval FILE = $(word $(shell expr $(index) + 1), $(XCCONFIG_PATHS))) \
		$(call download_file,$(DIR),$$GITHUB_ACCESS_TOKEN,$(FILE)); \
	)

CI ?= false
BUILD_TYPE ?= Debug
FLAVOR ?= Staging
GRADLE_ARGS ?= --build-cache

ifeq ($(CI), true)
  GRADLE_ARGS += --console 'plain'
  BUILD_TYPE = Release
endif

# iOS
DEVICE ?= iPhone 16
SCHEME ?= ios
PROJECT_ARGS ?= -scheme ${SCHEME} -sdk iphonesimulator -destination 'platform=iOS Simulator,name=${DEVICE}'
TESTING_ARGS ?= -enableCodeCoverage YES -derivedDataPath ../build/derived-data-ios

# TODO: Remove this and enable code signing on CI
SIGNING_CONFIG ?= CODE_SIGNING_ALLOWED=NO

all: clean format lint all-android all-ios all-shared report
.PHONY: all

all-android: clean-gradle test-android assemble
.PHONY: all-android

all-ios: clean-ios analyze-ios test-ios build-ios
.PHONY: all-ios

all-shared: test-shared lint-shared
.PHONY: all-shared

clean: clean-gradle clean-ios
.PHONY: clean

format:
	./gradlew formatKotlin
.PHONY: format

lint: lint-android lint-shared
.PHONY: lint

test: test-android test-shared test-ios
.PHONY: test

# Android
assemble:
	./gradlew assemble${FLAVOR}${BUILD_TYPE} ${GRADLE_ARGS}
.PHONY: assemble

bundle:
	./gradlew bundle${FLAVOR}${BUILD_TYPE} ${GRADLE_ARGS}
.PHONY: bundle

clean-gradle:
	./gradlew clean ${GRADLE_ARGS}
.PHONY: clean-gradle

lint-android:
	./gradlew lint${FLAVOR}${BUILD_TYPE} detekt ${GRADLE_ARGS} android:lintKotlin
.PHONY: lint-android

test-android:
	./gradlew test${FLAVOR}${BUILD_TYPE}UnitTest ${GRADLE_ARGS}
.PHONY: test-android

# iOS
analyze-ios:
	(cd ios && xcodebuild analyze ${PROJECT_ARGS} ${SIGNING_CONFIG})
.PHONY: analyze

build-ios:
	(cd ios && xcodebuild build ${PROJECT_ARGS} ${SIGNING_CONFIG})
.PHONY: build

clean-ios:
	(cd ios && xcodebuild -scheme ${SCHEME} clean)
.PHONY: clean-ios

clear-derived-data:
	rm -rf ~/Library/Developer/Xcode/DerivedData
.PHONY: clear-derived-data

clear-module-cache:
	rm -rf ~/Library/Developer/Xcode/ModuleCache
.PHONY: clear-module-cache

clear-simulator-data:
	xcrun simctl erase all
.PHONY: clear-simulator-data

clear-test-derived-data:
	./scripts/ios-clean-derived-data.sh
.PHONY: clear-test-derived-data

report-ios:
	./scripts/ios-coverage-report.sh
.PHONY: report-ios

test-ios: clear-test-derived-data /
	(cd ios && xcodebuild test ${PROJECT_ARGS} ${TESTING_ARGS} ${SIGNING_CONFIG})
.PHONY: test-ios

# Shared
lint-shared: lint-shared-android lint-shared-common lint-shared-ios lint-shared-kotlinter
.PHONY: lint-shared

lint-shared-android:
	./gradlew :shared:detektAndroid${BUILD_TYPE} ${GRADLE_ARGS}
.PHONY: lint-shared-android

lint-shared-common:
	./gradlew :shared:detektMetadataCommonMain ${GRADLE_ARGS}
.PHONY: lint-shared-common

lint-shared-ios:
	./gradlew :shared:detektMetadataIosMain ${GRADLE_ARGS}
.PHONY: lint-shared-ios

lint-shared-kotlinter:
	./gradlew shared:lintKotlin
.PHONY: lint-shared-kotlinter

test-shared: test-shared-android test-shared-ios
.PHONY: test-shared

test-shared-android:
	./gradlew :shared:test${BUILD_TYPE}UnitTest ${GRADLE_ARGS}
.PHONY: test-shared-android

test-shared-ios:
	./gradlew :shared:cleanIosX64Test :shared:iosX64Test ${GRADLE_ARGS}
.PHONY: test-shared-ios

# Report
report: report-android report-shared report-html
.PHONY: report

report-html:
	./gradlew koverHtmlReport ${GRADLE_ARGS}
.PHONY: report-html

report-android:
	./gradlew :android:koverXmlReport ${GRADLE_ARGS}
.PHONY: report-android

report-shared:
	./gradlew :shared:koverXmlReport ${GRADLE_ARGS}
.PHONY: report-shared

cd "$(dirname "$0")"
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
jazzy \
  --objc \
  --clean \
  --author "Atelier Shiori" \
  --author_url https://ateliershiori.moe \
  --github_url https://github.com/Atelier-Shiori/Streamlinkdetect \
  --github-file-prefix https://github.com/Atelier-Shiori/Streamlinkdetect \
  --module-version 1.0 \
  --xcodebuild-arguments --objc,streamlinkdetect/streamlinkdetect.h,--,-x,objective-c,-isysroot,$(xcrun --show-sdk-path),-I,$(pwd) \
  --module Streamlinkdetect \
  --root-url http://atelier-shiori.github.io/Streamlinkdetect \
  --output docs/
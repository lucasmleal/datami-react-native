# react-native-rn-smi-sdk

yarn add patch-package postinstall-postinstall

In package.json

"scripts": {
+  "postinstall": "patch-package"
}


yarn add file:/path/to/react-native-rn-smi-sdk

cd ios
pod install

cd ..
npx react-native run-ios

{ pkgs, ... }: {
  channel = "stable-23.11";
  packages = [ pkgs.nodejs_20 pkgs.jdk21_headless pkgs.gradle ];
  env = { EXPO_USE_FAST_RESOLVER = "1"; };
  idx = {
    extensions = [
      "msjsdiag.vscode-react-native"
      "fwcd.kotlin"
    ];
    workspace = {
      onCreate = {
        install-and-prebuild = ''
          npm ci --prefer-offline --no-audit --no-progress --timing && npm i @expo/ngrok@^4.1.0 && npx -y expo install expo-dev-client && npx -y expo prebuild --platform android
          sed -i 's/org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m/org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m/' "android/gradle.properties"
        '';
      };
      onStart = {
        android = ''
          echo -e "\033[1;33mWaiting for Android emulator to be ready...\033[0m"
          adb -s emulator-5554 wait-for-device && \
          npm run android
        '';
      };
    };
    previews = {
      enable = true;
      previews = {
        web = {
          command = [ "npm" "run" "web" "--" "--port" "$PORT" ];
          manager = "web";
        };
        android = {
          command = [ "tail" "-f" "/dev/null" ];
          manager = "web";
        };
      };
    };
  };
}

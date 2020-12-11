# ChatApp
![alt text](https://travis-ci.org/strunailustra1/ChatApp.svg?branch=hw13)
### Приложение предназначено для обмена текстовыми сообщениями
#### Разработано в рамках школы Тинькофф Финтех
#### Описание
![chat list view](https://raw.githubusercontent.com/strunailustra1/ChatApp/master/Images/Simulator1.png)
![chat view](https://raw.githubusercontent.com/strunailustra1/ChatApp/master/Images/Simulator2.png)
![chat theme](https://raw.githubusercontent.com/strunailustra1/ChatApp/master/Images/Simulator3.png)
![chat profile](https://raw.githubusercontent.com/strunailustra1/ChatApp/master/Images/Simulator4.png)
![chat image](https://raw.githubusercontent.com/strunailustra1/ChatApp/master/Images/Simulator5.png)
#### Требования
Для работы необходим iOS версии 12.0 и выше.
#### Зависимости
- Firebase/Firestore ~> 6.32
- SwiftLint ~> 0.40
- iOSSnapshotTestCase ~> 6.2
#### Сборка 
* Установить зависимости для сборки 
  * ruby 2.6
  * libsodium
```sh
brew install libsodium
```
  * bundler 
```sh
gem install bundler
```
  * fastlane, cocoapods
```sh
bundle install
```
  * ruby-build (требуется для компиляции gem json, [инструкция по установке rbenv для MacOS 10 (Catalina) и MacOS 11 (Big Sur)](https://ernestojeh.com/fix-jekyll-on-macos-big-sur))
```sh
#fix error on bundle install
#fatal error: 'ruby/config.h' file not found #include "ruby/config.h"

git clone https://github.com/rbenv/rbenv.git ~/.rbenv

cd ~/.rbenv && src/configure && make -C src

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile

source ~/.bash_profile

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

rbenv install 2.6.6
rbenv global 2.6.6

xcode-select --switch /Applications/Xcode.app/Contents/Developer

bundle install
```

* Установить environment variables для fastlane
  * DISCORD_WEBHOOK_URL -- для оповещения в discord после сборки
  * PIXABAY_API_KEY -- токен сервиса с картинками для профиля
  * FIREBASE_API_KEY -- токен для доступа к firebase
```sh
cat << EOT > fastlane/.env
DISCORD_WEBHOOK_URL="%first secret token%"
PIXABAY_API_KEY="%second secret token%"
FIREBASE_API_KEY="%third secret token%"
EOT
```
* Сборка проекта для тестирования с генерацией config file
```sh
    bundle exec fastlane build_for_testing 
```
* Прогон unit/ui тестов на собранной сборке 
```sh
    bundle exec fastlane run_app_tests 
```
* Сборка и последующий прогон unit/ui тестов 
```sh
    bundle exec fastlane build_and_test 
```
#### Authors
**Natalia Mirnaya** strunailustra@gmail.com
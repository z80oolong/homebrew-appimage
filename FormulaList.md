# z80oolong/appimage に含まれる Formula 一覧

## 概要

本文書では、 [Linuxbrew][BREW] 向け Tap リポジトリ z80oolong/appimage に含まれる Formula 一覧を示します。各 Formula の詳細等については ```brew info <formula>``` コマンドも参照して下さい。

## Formula 一覧

### z80oolong/appimage/appimagetool

[AppImage][APPI] 向けに作成したディレクトリから [AppImage][APPI] ファイルを生成するためのアプリケーション ```appimagetool``` を導入するための Formula です。

この Formula は、 [Linuxbrew][BREW] の拡張コマンド ```brew appimage-build``` の実行時に必要に応じてインストールされるため、予めインストールする必要はありません。

### z80oolong/appimage/appimage-runtime

[AppImage][APPI] 向けに作成したディレクトリから [AppImage][APPI] ファイルの先頭に組み込む為のランタイムコードであり、 [AppImage][APPI] ファイル内のアプリケーションを起動する為に使用する ```runtime-x86_64``` を [Linuxbrew][BREW] に導入する為の Formula です。

この Formula は、 [Linuxbrew][BREW] の拡張コマンド ```brew appimage-build``` の実行時に必要に応じてインストールされるため、予めインストールする必要はありません。

<!-- 外部リンク一覧 -->

[BREW]:https://linuxbrew.sh/
[APPI]:https://appimage.org/

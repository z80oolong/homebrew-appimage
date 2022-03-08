# z80oolong/appimage において拡張される Formula クラスのメソッド一覧

## 概要

[Linuxbrew][BREW] の拡張コマンドである ```brew appimage-build``` は、既にインストール済の Formula 名を引数に取り、引数として与えられた Formula によって導入されたアプリケーションを起動するための [AppImage][APPI] ファイルを生成する為のコマンドです。

ここで、既にインストールされた Formula 名を引数に ```brew appimage-build``` コマンドを起動した時、当該 Formula から [AppImage][APPI] ファイルを生成する為に必要となる各種処理を行う事を目的として、 ``brew appimage-build``` コマンドに引数として渡された Formula 名に対応する ```Formula``` クラスについて、これらの処理を行うインスタンスメソッドの拡張を行います。

本文書では、 ```brew appimage-build``` コマンドの起動時に拡張される ```Formula``` クラスのインスタンスメソッドの一覧を示します。なお、実際の ```brew appimage-build``` コマンドの起動時に伴う ```Formula``` クラスのインスタンスメソッドの拡張は、実際には ```AppImage::Mixin``` モジュールの Mixin によって行われるため、本文書では、これらのインスタンスメソッドは ```AppImage::Mixin``` モジュールのメソッドとして扱うことに留意して下さい。

なお、 ```brew appimage-build``` コマンドの実行時に、ユーザ自身でこれらのインスタンスメソッドの挙動の変更を行う際は、 [AppImage][APPI] ファイルの生成の対象となる ```Formula``` ファイルの修正を行う必要が有ります。

## メソッド一覧

### ```AppImage::Mixin#appimage_name```

```brew appimage-build``` コマンドによって出力される [AppImage] ファイルのパッケージ名を返します。

```brew appimage-build``` コマンドの実行時にオプション ```-o, --output``` が指定されない場合は、 ```brew appimage-build``` コマンドは、出力先の [AppImage][APPI] ファイルのファイル名を ```<AppImage::Mixin#appimage_name の返値>-<AppImage::Mixin#appimage_version の返り値>-<uname -m コマンド等で示されるアーキテクチャ名>.AppImage``` とします。

### ```AppImage::Mixin#appimage_version```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルのバージョン番号を返します。

```brew appimage-build``` コマンドの実行時にオプション ```-o, --output``` が指定されない場合は、 ```brew appimage-build``` コマンドは、出力先の [AppImage][APPI] ファイルのファイル名を ```<AppImage::Mixin#appimage_name の返値>-<AppImage::Mixin#appimage_version の返り値>-<uname -m コマンド等で示されるアーキテクチャ名>.AppImage``` とします。

### ```AppImage::Mixin#exclude_list```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルへの同梱の除外対象とする動的ライブラリのリストを返します。返り値の形式は、除外対象とする動的ライブラリからディレクトリパスを除いたファイル名を表す文字列の配列として下さい。

```AppImage::Mixin#exclude_list``` メソッドによって返される動的ライブラリの除外対象リストは、 ```brew appimage-build``` コマンドの ```-g, --global-exclude``` 及び ```-c, --core-include``` オプションの影響を受けません。

### ```AppImage::Mixin#include_list```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルへの同梱対象とする動的ライブラリのリストを返します。返り値の形式は、同梱対象とする動的ライブラリからディレクトリパスを除いたファイル名を表す文字列の配列として下さい。

```AppImage::Mixin#include_list``` メソッドによって返される動的ライブラリの同梱対象リストは、 ```brew appimage-build``` コマンドの ```-g, --global-exclude``` 及び ```-c, --core-include``` オプションの影響を受けません。

### ```AppImage::Mixin#exec_path_list```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルへ同梱する実行ファイルのリストを返します。返り値の形式は、 [AppImage][APPI] ファイルへの同梱対象とするファイルの絶対パスを表す ```Pathname``` クラスのインスタンスのリストであることに留意する必要があります。

```AppImage::Mixin#exec_path_list``` の返り値には、生成された [AppImage][APPI] の実行によって起動されるアプリケーションの実行ファイルや、これらの起動等を補助するための実行ファイルのパスを列挙するようにして下さい。

### ```AppImage::Mixin#apprun```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルの実行時に最初に実行されるスクリプトファイルである ```AppRun``` の内容を文字列で返します。

```AppImage::Mixin#apprun``` メソッドで出力される ```AppRun``` スクリプトファイルには、 [AppImage][APPI] ファイルの実行によって起動される各種アプリケーションの初期化等に必要な処理等を記述するようにして下さい。

### ```AppImage::Mixin#desktop(exec_path)```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルに同梱される実行ファイルに対応する ```*.desktop``` ファイルの内容を文字列で返します。

なお、 ```AppImage::Mixin#desktop(exec_path)``` メソッドの引数 ```exec_path``` には、 [AppImage][APPI] ファイルに同梱される実行ファイルの絶対パスを表す ```Pathname``` クラスのインスタンスが渡されます。

### ```AppImage::Mixin#pre_build_appimage(appdirpath, verbose)```

```AppImage::Mixin#pre_build_appimage(appdirpath, verbose)``` メソッドは、 [AppImage][APPI] ファイルに同梱する実行ファイルと動的ライブラリ及び初期化スクリプトファイル ```AppRun``` と ```*.desktop``` ファイル等を作業用ディレクトリに配置した後、 [AppImage][APPI] ファイルを生成するアプリケーション ```appimagetool``` を実行する直前に呼ばれるメソッドです。

```AppImage::Mixin#pre_build_appimage(appdirpath, verbose)``` メソッドでは、 [AppImage][APPI] ファイルの実行時に起動されるアプリケーションの設定等に必要となるファイル群の作業用ディレクトリへの配置及び、 [AppImage][APPI] ファイルに設定するアイコンファイルの修正等、 [AppImage][APPI] ファイルの生成に必要な処理を記述するようにして下さい。

<!-- 外部リンク一覧 -->

[BREW]:https://linuxbrew.sh/
[APPI]:https://appimage.org/

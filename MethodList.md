# z80oolong/appimage において使用される AppImage::Builder クラスのメソッド一覧

## 概要

[Linuxbrew][BREW] の拡張コマンドである ```brew appimage-build``` は、既にインストール済の Formula 名を引数に取り、引数として与えられた Formula によって導入されたアプリケーションを起動するための [AppImage][APPI] ファイルを生成する為のコマンドです。

ここで、既にインストールされた Formula 名を引数に ```brew appimage-build``` コマンドを起動した時、当該 Formula から [AppImage][APPI] ファイルを生成する為に必要となる各種設定及び処理を行う事を目的として、 ```brew appimage-build``` コマンドの ```-r, --load-file``` オプションに、これらの処理を行うクラスである ```AppImage::Builder``` クラスの派生クラスを記述した Ruby スクリプトファイルのパスを渡します。

本文書では、 ```brew appimage-build``` コマンドによって、 [AppImage][APPI] ファイルを生成する為に必要となる各種設定及び処理を記述するためのクラスの派生元となる ```AppImage::Builder``` クラスのインスタンスメソッドの一覧を示します。

なお、 ```AppImage::Builder``` クラス及び派生クラスのインスタンスは、その生成時に ```brew appimage-build``` の引数として渡された ```Formula``` クラスのインスタンスを、 ```AppImage::Builder``` クラス及び派生クラスのインスタンス変数の値として、そのインスタンスの内部に保持します。

そして、本文書に述べるインスタンスメソッド以外のメソッドについては、 Object クラスで定義されるメソッドを除き、 ```AppImage::Builder``` クラス及び派生クラスのインスタンスの内部に保持した ```Formula``` クラスのインスタンスにメソッドを移譲します。

即ち、 ```AppImage::Builder``` クラスのインスタンスは、本文書で述べるメソッドの他に、 ```AppImage::Builder#prefix, AppImage::Builder#opt_bin``` 等のメソッドを呼び出すことが出来、これらのメソッドは、 ```AppImage::Builder``` クラス及び派生クラスのインスタンスの内部に保持した ```Formula``` クラスのインスタンスメソッドを呼び出した結果の返り値を返します。

## メソッド一覧

### ```AppImage::Builder#appimage_name```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルのパッケージ名を返します。

```brew appimage-build``` コマンドの実行時にオプション ```-o, --output``` が指定されない場合は、 ```brew appimage-build``` コマンドは、出力先の [AppImage][APPI] ファイルのファイル名を ```<AppImage::Builder#appimage_name の返値>-<AppImage::Builder#appimage_version の返り値>-<uname -m コマンド等で示されるアーキテクチャ名>.AppImage``` とします。

### ```AppImage::Builder#appimage_version```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルのバージョン番号を返します。

```brew appimage-build``` コマンドの実行時にオプション ```-o, --output``` が指定されない場合は、 ```brew appimage-build``` コマンドは、出力先の [AppImage][APPI] ファイルのファイル名を ```<AppImage::Builder#appimage_name の返値>-<AppImage::Builder#appimage_version の返り値>-<uname -m コマンド等で示されるアーキテクチャ名>.AppImage``` とします。

### ```AppImage::Builder#exclude_list```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルへの同梱の除外対象とする動的ライブラリのリストを返します。返り値の形式は、除外対象とする動的ライブラリからディレクトリパスを除いたファイル名を表す文字列の配列として下さい。

```AppImage::Builder#exclude_list``` メソッドによって返される動的ライブラリの除外対象リストは、 ```brew appimage-build``` コマンドの ```-g, --global-exclude``` 及び ```-c, --core-include``` オプションの影響を受けません。

### ```AppImage::Builder#include_list```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルへの同梱対象とする動的ライブラリのリストを返します。返り値の形式は、同梱対象とする動的ライブラリからディレクトリパスを除いたファイル名を表す文字列の配列として下さい。

```AppImage::Builder#include_list``` メソッドによって返される動的ライブラリの同梱対象リストは、 ```brew appimage-build``` コマンドの ```-g, --global-exclude``` 及び ```-c, --core-include``` オプションの影響を受けません。

### ```AppImage::Builder#exec_path_list```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルへ同梱する実行ファイルのリストを返します。返り値の形式は、 [AppImage][APPI] ファイルへの同梱対象とするファイルの絶対パスを表す ```Pathname``` クラスのインスタンスのリストであることに留意する必要があります。

```AppImage::Builder#exec_path_list``` の返り値には、生成された [AppImage][APPI] の実行によって起動されるアプリケーションの実行ファイルや、これらの起動等を補助するための実行ファイルのパスを列挙するようにして下さい。

### ```AppImage::Builder#sign_key```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルに GPG2 に基づく電子署名を行う際に使用する公開鍵の user ID を返します。 GPG2 に基づく電子署名を行わない場合は空文字列を返します。

なお、返り値の形式は、前述の通り空文字列若しくは、 user ID を表す 16 進コードの文字列であることに留意する必要があります。

### ```AppImage::Builder#sign_args```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルに GPG2 に基づく電子署名を行う際に、 ```brew appimage-build``` コマンドにおいて使用されるアプリケーション ```appimagetool``` の内部で起動される ```gpg``` コマンドに渡す残りの引数及びオプションを返します。

なお、返り値の形式は、 ```gpg``` コマンドに渡す各引数を表す文字列のリストであることに留意する必要があります。

### ```AppImage::Builder#runtime_path```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルを生成する際に、 [AppImage][APPI] ファイルの先頭部分に組み込む為のランタイムコードであり、 [AppImage][APPI] ファイル内のアプリケーションを起動する為に使用する ```runtime-x86_64``` 若しくはそれに類するランタイムコードのバイナリファイルが置かれている絶対パスを返します。

返り値の形式は、ランタイムコードのバイナリファイルの絶対パスを表す ```Pathname``` クラスのインスタンスであることに留意する必要があります。

### ```AppImage::Builder#extra_args```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルを生成する為に起動されるアプリケーションである ```appimagetool``` に渡す残りその他の引数及びオプションを返します。

なお、返り値の形式は、アプリケーション ```appimagetool``` に渡す各引数を表す文字列のリストであることに留意する必要があります。

### ```AppImage::Builder#apprun```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルの実行時に最初に実行されるスクリプトファイルである ```AppRun``` の内容を文字列で返します。

即ち、 ```AppImage::Builder#apprun``` メソッドの返り値には、 [AppImage][APPI] ファイルの実行によって起動される各種アプリケーションの初期化等に必要となる処理が記述された ```AppRun``` スクリプトファイルの内容を文字列として返す必要があります。

### ```AppImage::Builder#desktop(exec_path)```

```brew appimage-build``` コマンドによって出力される [AppImage][APPI] ファイルに同梱される実行ファイルに対応する ```*.desktop``` ファイルの内容を文字列で返します。

なお、 ```AppImage::Builder#desktop(exec_path)``` メソッドの引数 ```exec_path``` には、 [AppImage][APPI] ファイルに同梱される実行ファイルの絶対パスを表す ```Pathname``` クラスのインスタンスが渡されます。即ち、 ```AppImage::Builder#desktop(exec_path)``` メソッドの返り値には、引数 ```exec_path``` を起動する際に適切な設定が為された ```*.desktop``` の内容を文字列で返す必要があります。

### ```AppImage::Builder#pre_build_appimage(appdir, verbose)```

```AppImage::Builder#pre_build_appimage(appdir, verbose)``` メソッドは、 [AppImage][APPI] ファイルに同梱する実行ファイルと動的ライブラリ及び初期化スクリプトファイル ```AppRun``` と ```*.desktop``` ファイル等を作業用ディレクトリに配置した後、 [AppImage][APPI] ファイルを生成するアプリケーション ```appimagetool``` を実行する直前に呼ばれるメソッドです。

なお、 ```AppImage::Builder#desktop(appdir, verbose)``` メソッドの引数 ```appdir``` には、 [AppImage][APPI] ファイルに同梱するファイル群が格納された作業用ディレクトリの絶対パスを表す ```AppImage::AppDirPath``` クラスのインスタンスが渡されます。

ここで、 ```AppImage::AppDirPath``` クラスとは、 ```Pathname``` クラスの派生クラスであり、 ```Pathname``` クラスのインスタンスメソッドの他に以下のインスタンスメソッドが使用できます。 (なお、以下の ```AppImage::AppDirPath``` クラスのインスタンスメソッドの説明については、作業用ディレクトリの絶対パスを ```/path/to/AppDir``` と表記します。)

- **```AppImage::AppDirPath#bin```** … 絶対パス ```/path/to/AppDir/usr/bin``` を表す ```Pathname``` クラスのインスタンスを返します。
- **```AppImage::AppDirPath#lib```** … 絶対パス ```/path/to/AppDir/usr/lib``` を表す ```Pathname``` クラスのインスタンスを返します。
- **```AppImage::AppDirPath#share```** … 絶対パス ```/path/to/AppDir/usr/share``` を表す ```Pathname``` クラスのインスタンスを返します。

また、引数 ```verbose``` には、 ```brew appimage-build``` コマンドに ```-v --verbose``` オプションが指定された時に true が渡されます。

```AppImage::Builder#pre_build_appimage(appdir, verbose)``` メソッドでは、 [AppImage][APPI] ファイルの実行時に起動されるアプリケーションの設定等に必要となるファイル群を作業用ディレクトリ ```appdir``` へ配置する処理及び、 [AppImage][APPI] ファイルに設定するアイコンファイルの修正等、 [AppImage][APPI] ファイルの生成に必要な処理を記述する必要があります。

## ```AppImage::Builder``` クラスの派生クラスの実例

以下に、 ```brew appimage-build``` コマンドによって使用される ```AppImage::Builder``` クラスの派生クラスの実例を示します。本文書では、疑似端末の多重化ソフトである tmux の [AppImage][APPI] ファイルを生成するための ```TmuxBuilder``` を示します。

```
  # AppImage::Builder クラスの派生クラスとして TmuxBuilder を定義。
  class TmuxBuilder < AppImage::Builder
    # TmuxBuilder#apprun メソッドで AppRun スクリプトの内容を返す。
    def apprun; <<~EOS
      #!/bin/sh
      #export APPDIR="/tmp/.mount-tmuxXXXXXX"
      if [ "x${APPDIR}" = "x" ]; then
        export APPDIR="$(dirname "$(readlink -f "${0}")")"
      fi
      export PATH="${APPDIR}/usr/bin/:${PATH:+:$PATH}"
      export LD_LIBRARY_PATH="${APPDIR}/usr/lib/:${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      export XDG_DATA_DIRS="${APPDIR}/usr/share/${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
      export TERMINFO="${APPDIR}/usr/share/terminfo"
      unset ARGV0

      exec "tmux" "$@"
      EOS
    end

    # TmuxBuilder#exec_path_list メソッドで、作業用ディレクトリ /path/to/AppDir/usr/bin に
    # 配置する実行ファイルを Pathname クラスのインスタンスのリストの形式で返す。
    def exec_path_list
      # TmuxBuilder#opt_bin メソッドで、引数に渡された Formula クラスのインスタンスメソッド
      # Formula#opt_bin の返り値を得る。
      return [opt_bin/"tmux"]
    end

    # TmuxBuilder#pre_build_appimage メソッドで、 AppImage ファイルの生成直前の処理を行う。
    def pre_build_appimage(appdir, verbose)
      # ここでは、 ncurses の設定ファイルを /path/to/AppDir/usr/share 以下に配置する。
      system("cp -pRv #{Formula["z80oolong/tmux/tmux-ncurses@6.2"].opt_share}/terminfo #{appdir}/usr/share")
    end

    def extra_args
      # brew appimage-build によって起動される appimagetool に渡す残りの引数及びオプションを指定する
      return ["--verbose"]
    end
  end
```

<!-- 外部リンク一覧 -->

[BREW]:https://linuxbrew.sh/
[APPI]:https://appimage.org/

# z80oolong/appimage に含まれる ```brew``` の拡張コマンド一覧

## 概要

本文書では、 [Linuxbrew][BREW] 向け Tap リポジトリ z80oolong/appimage によって拡張される ```brew``` コマンド一覧を示します。各コマンドの詳細等については ```brew <command> --help``` の出力も併せて参照して下さい。

## 拡張コマンド一覧

### ```brew appimage-build```

既にインストール済の Formula 名を引数に取り、引数として与えられた Formula によって導入されたアプリケーションを起動するための [AppImage][APPI] ファイルを生成する為のコマンドです。

以下に、 ```brew appimage-build``` コマンドが取る主なオプションを示します。

- ```-o, --output``` … 生成する [AppImage][APPI] ファイルの出力先のパスを指定します。
- ```-g, --global-exclude``` … [AppImage][APPI] ファイルの実行によって起動される実行ファイルが依存する動的ライブラリのうち、 [AppImage][APPI] ファイルへの同梱の除外対象となる動的ライブラリを厳密に除外します。このオプションを指定しないと、 ```brew appimage-build``` コマンドは、 [AppImage][APPI] ファイルへの同梱の除外対象となる動的ライブラリであっても、 [Linuxbrew][BREW] に導入されており、かつ実行ファイルが依存する動的ライブラリであれば、その動的ライブラリを同梱の対象とします。ここで、 ```brew appimage-build``` コマンドにおいて、 [AppImage][APPI] ファイルへの同梱の除外対象となる動的ライブラリのファイル名は以下の通りです。
  ```
  libanl.so.1, libBrokenLocale.so.1, libcidn.so.1, libc.so.6, libdl.so.2, libm.so.6, libmvec.so.1, libnss_compat.so.2, libnss_dns.so.2, libnss_files.so.2,
  libnss_hesiod.so.2, libnss_nisplus.so.2, libnss_nis.so.2, libpthread.so.0, libresolv.so.2, librt.so.1, libthread_db.so.1, libutil.so.1, libstdc++.so.6,
  libGL.so.1, libEGL.so.1, libGLdispatch.so.0, libGLX.so.0, libOpenGL.so.0, libdrm.so.2, libglapi.so.0, libgbm.so.1, libxcb.so.1, libX11.so.6, libgio-2.0.so.0,
  libasound.so.2, libfontconfig.so.1, libthai.so.0, libfreetype.so.6, libharfbuzz.so.0, libcom_err.so.2, libexpat.so.1, libgcc_s.so.1, libglib-2.0.so.0,
  libICE.so.6, libp11-kit.so.0, libSM.so.6, libusb-1.0.so.0, libuuid.so.1, libz.so.1, libgobject-2.0.so.0, libpangoft2-1.0.so.0, libpangocairo-1.0.so.0,
  libpango-1.0.so.0, libgpg-error.so.0, libjack.so.0, libxcb-dri3.so.0, libxcb-dri2.so.0, libfribidi.so.0, libgmp.so.10
  ```
  ここで、動的ライブラリのファイル名の判別については、**動的ライブラリのディレクトリパスを除いたファイル名の完全一致に依ることに留意する必要があります。**
- ```-c, --core-include``` … [AppImage][APPI] ファイルへの同梱の除外対象となる動的ライブラリであるかどうかに関わらず、 [AppImage][APPI] ファイルの実行によって起動される実行ファイルが依存する動的ライブラリを全て [AppImage][APPI] ファイルに同梱します。
- ```-v, --verbose``` … [AppImage][APPI] ファイルの生成過程の詳細を表示します。

例えば、 [AppImage][APPI] ファイルの生成過程の詳細を表示しながら、 ```z80oolong/tmux/tmux@2.6``` によって導入された tmux を、 tmux が依存する動的ライブラリを全て [AppImage][APPI] ファイルに同梱するようにして、 [AppImage][APPI] ファイルをファイル名 ```tmux-eaw-2.6-glibc-2.34-x86_64.[AppImage][APPI]``` に出力するには以下のようにして、 ```brew appimage-build``` コマンドを実行します。

```
 $ brew appimage-build -v -c -o tmux-eaw-2.6-glibc-2.34-x86_64.AppImage z80oolong/tmux/tmux@2.6
```

なお、 **```brew appimage-build``` コマンドが実行する [AppImage][APPI] ファイルの生成に関する処理は、以下に述べる処理に留まることに留意して下さい。**

- 指定された Formula によって導入された**実行ファイル (具体的には、ディレクトリ ```$HOMEBREW_PREFIX/opt/<formula_name>/bin``` 以下の実行ファイル) を作業用のディレクトリに配置し、当該実行ファイルが依存する動的ライブラリの rpath を書き換える。**
- **上記の実行ファイルが依存する動的ライブラリのうち、 [AppImage][APPI] への同梱の除外対象とならないものを作業用のディレクトリに配置する。**
- [AppImage][APPI] ファイルの実行時に最初に起動されるスクリプトファイル ```AppRun``` について、デフォルトの ```AppRun``` を作業用のディレクトリに配置する。
- [AppImage][APPI] ファイルのアイコンファイル及び実行ファイルに対応した ```*.desktop``` ファイルについて、デフォルトのファイルを作業用のディレクトリに配置する。
- 以上によって配置した**作業用のディレクトリに対して、 [AppImage][APPI] ファイルを生成するアプリケーション ```appimagetool``` を実行し、[AppImage][APPI] ファイルを生成する。**

従って、アプリケーションが適切に動作する [AppImage][APPI] ファイルの生成の為に必要となる以下の処理等に関しては、当該 Formula ファイルを別のディレクトリにコピーして修正する等して、**ユーザ自身によって行う必要があります。**

- ディレクトリ ```$HOMEBREW_PREFIX/opt/<formula_name>/share``` 以下等に置かれているような、 [AppImage][APPI] ファイルの実行時に起動される各種アプリケーションに必要となる設定ファイル等の作業用のディレクトリへの配置。
- [AppImage][APPI] ファイルの実行時に起動されるスクリプトファイル ```AppRun``` について、 [AppImage][APPI] ファイルの実行時に起動される各種アプリケーションに応じた修正。
- 設定ファイル等の各種ファイルパス名が、絶対パスとして実行ファイルのソースコード等にハードコードされている場合、相対パス若しくは環境変数 ```$APPDIR``` を参照するようにソースコード等の修正。
- [AppImage][APPI] ファイルで使用するアイコンファイル及び実行ファイルに対応した ```*.desktop``` ファイルについて、各種アプリケーションに応じた修正。

なお、ユーザ自身によって行う処理に関しては、主に ```brew appimage-build``` コマンドによって拡張される各種 ```Formula``` クラスのインスタンスメソッドの再定義によって行います。 ```Formula``` クラスのインスタンスメソッドの再定義に関する詳細は、ファイル ```MethodList.md``` を参照して下さい。

### ```brew appimage-install```

[AppImage][APPI] ファイルのパス若しくは [AppImage][APPI] が置かれている URL を引数に取り、引数によって指定された [AppImage][APPI] ファイルを [Linuxbrew][BREW] にインストールする為のコマンドです。

以下に、 ```brew appimage-install``` コマンドが取るオプションについて示します。

- ```-e, --extract``` … 引数で指定された [AppImage][APPI] ファイルのインストール時に、 [AppImage][APPI] ファイルに ```--appimage-extract``` オプションを付与して、 [Linuxbrew][BREW] に [AppImage][APPI] ファイルの展開を行います。
- ```-n, --name``` … 引数で指定された [AppImage][APPI] ファイルのインストール先とする為の [Linuxbrew][BREW] の Formula 名を ```"<name>@<version>``` の形式で指定します。**このオプションの指定は必須であることに留意して下さい。**
- ```-c, --command``` … [AppImage][APPI] ファイルを実行するために用いるコマンド名を指定します。**このオプションの指定は必須であることに留意して下さい。**
- ```-O, --output``` … [AppImage][APPI] ファイルのインストールを行わず、標準出力に [AppImage][APPI] ファイルをインストールする為の Formula ファイルを出力します。
- ```-v, --verbose``` … [AppImage][APPI] ファイルのインストールの過程の詳細を表示します。

例えば、 ```https://example.com/download/foo-1.0-x86_64.AppImage``` なる URL に置かれた [AppImage][APPI] ファイルを ```foo@1.0``` なる Formula 名で [Linuxbrew][BREW] にインストールし、これを ```foo``` なるコマンド名にて実行させるようにするには、以下のように ```brew appimage-install``` コマンドを実行します。

```
 $ brew appimage-install -n foo@1.0 -c foo https://example.com/download/foo-1.0-x86_64.AppImage
```

なお、 ```brew appimage-install``` コマンドによってインストールされた [AppImage][APPI] ファイルは、以下のように ```brew remove``` コマンドを用いてアンインストールを行うことが可能です。

```
 $ brew remove <name>@<version>
```

<!-- 外部リンク一覧 -->

[BREW]:https://linuxbrew.sh/
[APPI]:https://appimage.org/

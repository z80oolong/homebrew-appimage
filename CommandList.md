# z80oolong/appimage に含まれる ```brew``` の拡張コマンド一覧

## 概要

本文書では、 [Linuxbrew][BREW] 向け Tap リポジトリ z80oolong/appimage によって拡張される ```brew``` コマンド一覧を示します。各コマンドの詳細等については ```brew <command> --help``` の出力も併せて参照して下さい。

## 拡張コマンド一覧

### ```brew appimage-build```

既にインストール済の Formula 名を一つだけ引数に取り、引数として与えられた Formula によって導入されたアプリケーションを起動するための [AppImage][APPI] ファイルを生成する為のコマンドです。

以下に、 ```brew appimage-build``` コマンドが取る主なオプションを示します。

- ```-o, --output``` … 生成する [AppImage][APPI] ファイルの出力先のパスを指定します。
- ```-g, --global-exclude``` … [AppImage][APPI] ファイルの実行によって起動される実行ファイルが依存する動的ライブラリのうち、 [AppImage][APPI] ファイルへの同梱の除外対象となる動的ライブラリを厳密に除外します。  
  このオプションを指定しないと、 ```brew appimage-build``` コマンドは、 [AppImage][APPI] ファイルへの同梱の除外対象となる動的ライブラリであっても、 [Linuxbrew][BREW] に導入されており、かつ実行ファイルが依存する動的ライブラリであれば、その動的ライブラリを同梱の対象とします。  
  ここで、 ```brew appimage-build``` コマンドにおいて、 [AppImage][APPI] ファイルへの同梱の除外対象となる動的ライブラリのファイル名は以下の通りです。
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
- ```-r, --load-file``` … 同梱ファイルの ```MethodList.md``` で詳述する通り、引数で指定した ```Formula``` クラスから [AppImage][APPI] ファイルを生成するために必要な設定及び処理に関するクラスである ```AppImage::Builder``` クラスの派生クラスが記述された Ruby スクリプトファイルを読み込みファイルとして指定します。
- ```-v, --verbose``` … [AppImage][APPI] ファイルの生成過程の詳細を表示します。

例えば、 [AppImage][APPI] ファイルの生成過程の詳細を表示しながら、 ```z80oolong/tmux/tmux@2.6``` によって導入された tmux を、 tmux が依存する動的ライブラリを全て [AppImage][APPI] ファイルに同梱するようにして、生成された [AppImage][APPI] ファイルをファイル名 ```tmux-eaw-2.6-glibc-2.34-x86_64.[AppImage][APPI]``` に出力するには以下のようにして、 ```brew appimage-build``` コマンドを実行します。

```
 $ brew appimage-build -v -c -o tmux-eaw-2.6-glibc-2.34-x86_64.AppImage z80oolong/tmux/tmux@2.6
```

なお、ここで **```brew appimage-build``` コマンドが実行する [AppImage][APPI] ファイルの生成に関する処理は、デフォルトの設定では最低限以下に述べる処理に留まることに留意して下さい。**

- 引数で指定された Formula によって導入された**実行ファイル (具体的には、ディレクトリ ```$HOMEBREW_PREFIX/opt/<formula_name>/bin``` 以下の実行ファイル) を作業用のディレクトリに配置し、当該実行ファイルが依存する動的ライブラリの rpath を書き換える。**
- **上記の実行ファイルが依存する動的ライブラリのうち、 [AppImage][APPI] への同梱の除外対象とならないものを作業用のディレクトリに配置する。**
- [AppImage][APPI] ファイルの実行時に最初に起動されるスクリプトファイル ```AppRun``` について、デフォルトの ```AppRun``` を作業用のディレクトリに配置する。
- [AppImage][APPI] ファイルのアイコンファイル及び実行ファイルに対応した ```*.desktop``` ファイルについて、デフォルトのファイルを作業用のディレクトリに配置する。
- 以上によって配置した**作業用のディレクトリに対して、 [AppImage][APPI] ファイルを生成するアプリケーション ```appimagetool``` を実行し、[AppImage][APPI] ファイルを生成する。**

従って、アプリケーションが適切に動作する [AppImage][APPI] ファイルの生成の為に必要となる以下の処理等に関しては、 ```-r, --load-file``` オプションで指定する Ruby スクリプトファイルに、以下に述べる設定及び処理を定義するためのクラスである ```AppImage::Builder``` クラスの派生クラスを記述するか、特段の必要があれば、別途以下に述べるソースコード等の修正等を施すための Formula クラスを定義するための Formula ファイルを用意する等の手法により、**ユーザ自身によって行う必要があります。**

- ディレクトリ ```$HOMEBREW_PREFIX/opt/<formula_name>/share``` 以下等に置かれているような、 [AppImage][APPI] ファイルの実行時に起動される各種アプリケーションに必要となる設定ファイル等の作業用のディレクトリへの配置。
- [AppImage][APPI] ファイルの実行時に起動されるスクリプトファイル ```AppRun``` について、 [AppImage][APPI] ファイルの実行時に起動される各種アプリケーションに応じた修正。
- [AppImage][APPI] ファイルで使用するアイコンファイル及び実行ファイルに対応した ```*.desktop``` ファイルについて、各種アプリケーションに応じた修正。
- 設定ファイル等の各種ファイルパス名が、絶対パスとして実行ファイルのソースコード等にハードコードされている場合、相対パス若しくは環境変数 ```$APPDIR``` を参照するようにソースコード等の修正。

なお、ユーザ自身によって行う設定及び処理を定義するためのクラスである ```AppImage::Builder``` クラスの派生クラスについての詳細は、 ```AppImage::Builder``` クラスのインスタンスメソッドについて詳述した同梱ファイル ```MethodList.md``` を参照して下さい。

### ```brew appimage-install```

[AppImage][APPI] ファイルのパス若しくは [AppImage][APPI] が置かれている URL を一つだけ引数に取り、引数によって指定された [AppImage][APPI] ファイルを [Linuxbrew][BREW] にインストールする為のコマンドです。

以下に、 ```brew appimage-install``` コマンドが取るオプションについて示します。

- ```-e, --extract``` … 引数で指定された [AppImage][APPI] ファイルのインストール時に、 [AppImage][APPI] ファイルに ```--appimage-extract``` オプションを付与して、 [Linuxbrew][BREW] に [AppImage][APPI] ファイルの展開を行います。
- ```-n, --dry-run``` … ```brew appimage-install``` コマンドの実行の際、実際に [Linuxbrew][BREW] への [AppImage] ファイルの導入は行われず、導入先の Cellar 名及びバージョン番号等を画面に表示して ```brew appimage-install``` コマンドを終了します。このオプションは、 ```brew appimage-install``` コマンドの Cellar 名及びバージョン番号の解析結果の確認の為に使用されます。
- ```-N, --name``` … 引数で指定された [AppImage][APPI] ファイルのインストール先とする為の [Linuxbrew][BREW] の Cellar の名前を明示的に指定します。
- ```-V, --version``` … 引数で指定された [AppImage][APPI] ファイルのインストール先とする為の [Linuxbrew][BREW] の Cellar のバージョン番号を明示的に指定します。
- ```-c, --command``` … [AppImage][APPI] ファイルを実行するために用いるコマンド名を明示的に指定します。
- ```-O, --output``` … [AppImage][APPI] ファイルのインストールを行わず、標準出力に [AppImage][APPI] ファイルをインストールする為の Formula ファイルを出力します。
- ```-v, --verbose``` … [AppImage][APPI] ファイルのインストールの過程の詳細を表示します。

なお、 ```brew appimage-install``` コマンドによる [AppImage][APPI] ファイルのインストールのインストール先となる Cellar の名前及びバージョン番号は、 ```--name, --version`` によって明示的に指定されなければ、引数によって指定された [AppImage][APPI] ファイル名より自動的に抽出されたものが用いられます。

ここに、 ```brew appimage-install``` コマンドによる [AppImage][APPI] ファイルのインストールのインストール先となる Cellar のバージョン番号を決定する順序について示します。

- ```brew appimage-install``` コマンドで ```--version``` オプションにより明示的に指定した文字列。
- ```--version``` オプションによりバージョン番号が指定されなければ、 [AppImage][APPI] ファイルのファイル名中において、数字及びピリオドが連続する文字列。

なお、 ```brew appimage-install``` コマンドで [AppImage][APPI] ファイルをインストールした場合、 [AppImage][APPI] ファイルのインストール先となる Cellar の名前は以下のようにして決められます。

- ```brew appimage-install``` コマンドで ```--name``` により明示的に指定した文字列。
- ```--name``` オプションが指定されない場合は、 ```brew appimage-install``` コマンドにより自動的に抽出される [AppImage][APPI] ファイル名の先頭の英数字及びハイフン等より構成される文字列に (もし存在しなければ) "appimage-" を付加した文字列。例えば、 ```foo-bar-0.0.1.AppImage``` の場合は、 ```appimage-foo-bar``` となる。

ここで、 ```--version``` オプションが明示的に指定されず、 [AppImage][APPI] ファイルのファイル名等よりバージョン番号及び Cellar 名の解析に失敗した場合は、 ```brew appimage-install``` はエラーを返します。この場合は、 ```brew appimage-install``` に ```--name``` 及び ```--version``` オプションを明示的に指定するようにして下さい。

なお、 ```brew appimage-install``` コマンドによってインストールされた [AppImage][APPI] ファイルは、 [Linuxbrew][BREW] からは、 **Keg only としてインストールされることに留意して下さい。実際に ```foo``` コマンドを使用する際は、 ```brew link --force``` コマンドを実行する必要があります。**

以下に、 ```https://example.com/download/foo-1.0.2-x86_64.AppImage``` に存在する [AppImage][APPI] ファイルを Cellar 名 ```foo@1.0``` に導入する場合の ```brew appimage-install``` の実行方法について示します。

```
 $ brew appimage-install -N foo@1.0 -c foo https://example.com/download/foo-1.0.2-x86_64.AppImage
 $ brew link --force foo@1.0    # (foo コマンドを使用する場合に必要。)
```

なお、 ```brew appimage-install``` コマンドによってインストールされた [AppImage][APPI] ファイルは、以下のように ```brew remove``` コマンドを用いてアンインストールを行うことが可能です。

```
 $ brew remove foo@1.0
```

<!-- 外部リンク一覧 -->

[BREW]:https://linuxbrew.sh/
[APPI]:https://appimage.org/

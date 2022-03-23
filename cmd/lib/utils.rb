module AppImage
  module Utils
    SHELL = ShellCommands.instance
    HOMEBREW_PREFIX = ENV["HOMEBREW_PREFIX"]

    def depend_so_path_list(exec_path, option = {})
      result = []
      option[:verbose] ||= false; option[:exclude_list] ||= []
      option[:include_list] ||= []; option[:global_exclude] ||= false
      option[:core_include] ||= false

      %x{#{SHELL.ldd} #{exec_path}}.each_line do |line|
        if %r{^\s*\S* => (\S*) \(0x[0-9a-f]*\)$} === line then
          so_path = Pathname.new($1); so_path_base = so_path.basename
          so_path_dir = so_path.dirname; so_path_real = so_path.realpath

          if /^ld-linux.*\.so/ === so_path_base.to_s then
            ohai "LISTED (ld-linux.so.2) #{so_path}" if option[:verbose]
            result << [so_path_base, so_path]
          elsif option[:include_list].member?(so_path_base.to_s) then
            ohai "LISTED (Formula#include_list) #{so_path}" if option[:verbose]
            result << [so_path_base, so_path_real]
          elsif option[:exclude_list].member?(so_path_base.to_s) then
            ohai "Skip   (Formula#exclude_list) #{so_path}" if option[:verbose]
          elsif EXCLUDE_LIST.member?(so_path_base.to_s) && !option[:core_include] then
            if (%r{^#{HOMEBREW_PREFIX}} === so_path_dir.to_s) && !option[:global_exclude] then
              ohai "LISTED (Global excluded, but installed in Homebrew) #{so_path}" if option[:verbose]
              result << [so_path_base, so_path_real]
            else
              ohai "Skip   (Global excluded) #{so_path}" if option[:verbose]
            end
          else
            unless %r{^#{HOMEBREW_PREFIX}} === so_path_dir.to_s then
              ohai "LISTED (Core included) #{so_path}" if option[:verbose]
            else
              ohai "LISTED (Installed in Homebrew) #{so_path}" if option[:verbose]
            end
            result << [so_path_base, so_path_real]
          end
        end
      end

      return result
    end

    def install_apprun_icons_to_appdir(builder, verbose = false)
      appimage_icon_path = ((Pathname.new(__FILE__).realpath.dirname)/"../icons/appimage.png").realpath
      appdir = builder.appdir

      ohai "Install #{appdir}/AppRun." if verbose
      (appdir/"AppRun").write(builder.apprun)
      (appdir/"AppRun").chmod(0755)

      ["128x128", "16x16", "256x256", "32x32", "512x512", "64x64", "scalable"].each do |d|
        ohai "Create path #{appdir.share}/icons/hicolor/#{d}/apps" if verbose
        (appdir.share/"icons/hicolor/#{d}/apps").mkpath
      end

      ohai "Install #{appdir.share}/icons/hicolor/128x128/apps/appimage.png" if verbose
      system "#{SHELL.cp} -pR #{appimage_icon_path} #{appdir.share}/icons/hicolor/128x128/apps/appimage.png"
      Dir.chdir(appdir.to_s) do
        system "#{SHELL.ln} -sf usr/share/icons/hicolor/128x128/apps/appimage.png ."
      end
    end

    def install_bin_lib_to_appdir(builder, exec_path, so_path_list, verbose = false)
      exec_base = exec_path.basename
      appdir_bin = builder.appdir.bin
      appdir_lib = builder.appdir.lib
      appdir_share = builder.appdir.share

      ohai "Install #{exec_path}." if verbose
      system("#{SHELL.cp} -pR #{exec_path.realpath} #{appdir_bin}")
      (appdir_bin/exec_base).chmod(0755)

      ohai "PatchELF --set-rpath '${ORIGIN}/../lib:#{HOMEBREW_PREFIX}/lib' #{appdir_bin}/#{exec_base}" if verbose
      system("#{SHELL.patchelf} --set-rpath '${ORIGIN}/../lib:#{HOMEBREW_PREFIX}/lib' #{appdir_bin}/#{exec_base}")

      Dir.chdir(appdir_lib.to_s) do
        so_path_list.each do |so_base, so_real|
          realbase = so_real.basename
          if /^ld-linux.*\.so/ === so_base.to_s then
            ohai "PatchELF --set-interpreter #{so_real} #{appdir_bin}/#{exec_base}" if verbose
            system("#{SHELL.patchelf} --set-interpreter #{so_real} #{appdir_bin}/#{exec_base}")
          elsif (Pathname.pwd/realbase).exist? then
            ohai "Skip, #{realbase} exists." if verbose
          else
            ohai "Install #{so_real}" if verbose
            system("#{SHELL.cp} -pR #{so_real} .")
            (Pathname.pwd/realbase).chmod(0755)
            unless realbase == so_base then
              ohai "Link #{realbase} -> #{so_base}" if verbose
              system("#{SHELL.ln} -sf #{realbase} #{so_base}")
            end

            ohai "PatchELF --set-rpath '${ORIGIN}:#{HOMEBREW_PREFIX}/lib' ./#{realbase}" if verbose
            system("#{SHELL.patchelf} --set-rpath '${ORIGIN}:#{HOMEBREW_PREFIX}/lib' ./#{realbase}")
          end
        end
      end

      ohai "Install #{appdir_share}/applications/#{exec_base}.desktop" if verbose
      (appdir_share/"applications/#{exec_base}.desktop").write(builder.desktop(exec_path))

      Dir.chdir(builder.appdir.to_s) do
        system("#{SHELL.ln} -sf usr/share/applications/#{exec_base}.desktop .")
      end
    end

    def build_appimage(builder, output_file, verbose = false)
      ohai "AppImageTool -n #{builder.appdir} #{output_file}" if verbose
      system "#{SHELL.appimagetool} -n #{builder.appdir} #{output_file}"
    end
  end
end

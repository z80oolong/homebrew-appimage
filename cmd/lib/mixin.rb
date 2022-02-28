module AppImage
  module Mixin
    def appdirpath
      @appdirpath ||= AppDirPath.new
      return @appdirpath
    end

    def appimage_name
      return self.name.gsub(/@.*$/, "")
    end

    def appimage_version
      keg = Keg.new((opt_bin/"..").realpath)
      return keg.version.to_s.gsub(/_[0-9]*$/, "")
    end

    def appimage_arch
      return RUBY_PLATFORM.gsub(/-linux$/, "")
    end

    def exclude_list
      return []
    end

    def include_list
      return []
    end

    def exec_path_list
      return opt_bin.glob("*")
    end

    def apprun; <<~EOS
      #!/bin/sh
      if [ "x${APPDIR}" = "x" ]; then
        export APPDIR="$(dirname "$(readlink -f "${0}")")"
      fi
      export PATH="${APPDIR}/usr/bin/:${PATH:+:$PATH}"
      export LD_LIBRARY_PATH="${APPDIR}/usr/lib/:${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      export XDG_DATA_DIRS="${APPDIR}/usr/share/${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

      EXEC=$(grep -e '^Exec=.*' "${APPDIR}"/*.desktop | head -n 1 | cut -d "=" -f 2 | cut -d " " -f 1)
      exec "${EXEC}" "$@"
      EOS
    end

    def desktop(exec_path); <<~EOS
      [Desktop Entry]
      Type=Application
      Name=#{exec_path.basename}
      Exec=#{exec_path.basename}
      Comment=#{desc}
      Icon=appimage
      Categories=Development;
      Terminal=true
      EOS
    end

    def pre_build_appimage(appdirpath, verbose = false)
      ohai "pre_build_appimage: Noop." if verbose
    end
  end
end

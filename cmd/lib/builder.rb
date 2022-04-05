module AppImage
  class Builder
    module NameSpace; end

    class << self
      @@builder_class = self

      def inherited(subklass)
        @@builder_class = subklass
      end

      def builder_class
        return @@builder_class
      end
    end

    def initialize(formula)
      @formula = formula
      @appdir  = AppDirPath.new
    end
    attr_reader :appdir

    def appimage_name
      return @formula.name.gsub(/@.*$/, "")
    end

    def appimage_version
      keg = Keg.new((@formula.opt_bin/"..").realpath)
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
      return @formula.opt_bin.glob("*")
    end

    def apprun; <<~EOS
      #!/bin/sh
      if [ "x${APPDIR}" = "x" ]; then
        export APPDIR="$(dirname "$(readlink -f "${0}")")"
      fi

      if [ "x${HOMEBREW_PREFIX} = "x" ]; then
        export PATH="${APPDIR}/usr/bin/:${PATH:+:$PATH}"
        export LD_LIBRARY_PATH="${APPDIR}/usr/lib/:${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        export XDG_DATA_DIRS="${APPDIR}/usr/share/:${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
      else
        export PATH="${APPDIR}/usr/bin/:${HOMEBREW_PREFIX}/bin/:${PATH:+:$PATH}"
        export LD_LIBRARY_PATH="${APPDIR}/usr/lib/:${HOMEBREW_PREFIX}/lib/:${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        export XDG_DATA_DIRS="${APPDIR}/usr/share/:${HOMEBREW_PREFIX}/share/:${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
      fi

      EXEC=$(grep -e '^Exec=.*' "${APPDIR}"/*.desktop | head -n 1 | cut -d "=" -f 2 | cut -d " " -f 1)
      exec "${EXEC}" "$@"
      EOS
    end

    def desktop(exec_path); <<~EOS
      [Desktop Entry]
      Type=Application
      Name=#{exec_path.basename.to_s.capitalize}
      Exec=#{exec_path.basename}
      Comment=#{@formula.desc}
      Icon=appimage
      Categories=Development;
      Terminal=true
      EOS
    end

    def appdata_xml(exec_path); <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <component type="desktop">
        <id>appimagetool.desktop</id>
        <metadata_license>#{@formula.license}</metadata_license>
        <project_license>MIT</project_license>
        <name>#{exec_path.basename.to_s.capitalize}</name>
        <summary>#{@formula.desc}</summary>
        <description>
          <p>
          `#{appimage_name}-#{appimage_version}-#{appimage_arch}.AppImage` is
          a AppImage package file for execting `#{exec_path.basename}` command.
          </p>
          <p>
          This AppImage package file is that #{@formula.desc}.
          </p>
        </description>
        <url type="homepage">#{@formula.homepage}</url>
        <project_group>#{@formula.name.to_s.capitalize}</project_group>
        <provides>
          <binary>#{exec_path.basename}</binary>
        </provides>
      </component>
      EOS
    end

    def pre_build_appimage(appdir, verbose = false)
      ohai "pre_build_appimage: Noop." if verbose
    end

    def method_missing(name, *args, &block)
      return @formula.send(name, *args, &block)
    end

    def respond_to_missing?(sym, include_private = nil)
      return @formula.respond_to?(sym, include_private)
    end
  end
end

module AppImage
  class AppDirPath < Pathname
    def initialize
      tmpdir = Dir.mktmpdir("appimage-build-d")
      super("#{tmpdir}/AppDir")

      (self/"usr/bin").mkpath
      (self/"usr/lib").mkpath
      (self/"usr/share").mkpath
      (self/"usr/share/icons/hicolor").mkpath
      (self/"usr/share/applications").mkpath
      (self/"usr/share/metainfo").mkpath

      @tmpdir = Pathname.new(tmpdir)
    end

    def bin
      return (self/"usr/bin")
    end

    def lib
      return (self/"usr/lib")
    end

    def share
      return (self/"usr/share")
    end

    def icons_128x128
      return (share/"icons/hicolor/128x128/apps")
    end

    def icons_16x16
      return (share/"icons/hicolor/16x16/apps")
    end

    def icons_256x256
      return (share/"icons/hicolor/256x256/apps")
    end

    def icons_32x32
      return (share/"icons/hicolor/32x32/apps")
    end

    def icons_512x512
      return (share/"icons/hicolor/512x512/apps")
    end

    def icons_64x64
      return (share/"icons/hicolor/64x64/apps")
    end

    def icons_scalable
      return (share/"icons/hicolor/scalable/apps")
    end

    def applications
      return (share/"applications")
    end

    def metainfo
      return (share/"metainfo")
    end

    def realpath
      return (Pathname.new(self.to_s).realpath)
    end

    def destroy
      @tmpdir.rmtree
    end
  end
end

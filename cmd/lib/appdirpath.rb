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

      @tmpdir = Pathname.new(tmpdir)
    end
    attr_reader :tmpdir

    def bin
      return (self/"usr/bin")
    end

    def lib
      return (self/"usr/lib")
    end

    def share
      return (self/"usr/share")
    end

    def destroy
      @tmpdir.rmtree
    end
  end
end

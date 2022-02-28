module AppImage
  class ShellCommands
    def initialize
      @patchelf ||= (Formula["patchelf"].opt_bin/"patchelf")
      @appimagetool ||= (Formula["z80oolong/appimage/appimagetool"].opt_bin/"appimagetool")
      @curl ||= Pathname.new(%x{which curl}.chomp!)
      @sha256sum ||= Pathname.new(%x{which sha256sum}.chomp!)
      @ldd ||= Pathname.new(%x{which ldd}.chomp!)
      @cp ||= Pathname.new(%x{which cp}.chomp!)
      @ln ||= Pathname.new(%x{which ln}.chomp!)

      unless @patchelf.executable? then
        system "brew reinstall -s patchelf"
      end

      unless @appimagetool.executable? then
        system "brew reinstall appimagetool"
      end

      unless @curl.executable? then
        system "brew reinstall curl"
        @curl = (Formula["curl"].opt_bin/"curl")
      end

      unless @ldd.executable? then
        system "brew reinstall glibc"
        @ldd = (Formula["glibc"].opt_bin/"ldd")
      end

      unless (@sha256sum.executable? || @cp.executable? || @ln.executable?) then
        system "brew reinstall coreutils"
        @sha256sum = (Formula["coreutils"].opt_bin/"gsha256sum")
        @cp = (Formula["coreutils"].opt_bin/"gcp")
        @ln = (Formula["coreutils"].opt_bin/"gln")
      end
    end

    attr_reader :patchelf, :appimagetool, :curl, :ldd
    attr_reader :sha256sum, :cp, :ln
  end
end

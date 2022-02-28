$:.unshift(Pathname.new(__FILE__).realpath.dirname.to_s)

require "cli/parser"
require "formula"
require "lib/shellcommands"

module Homebrew
  PROGS = AppImage::ShellCommands.new

  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }

  def formula_rb(option); <<~EOS
    class #{option[:klass]} < Formula
      url "#{option[:url]}"
      version "#{option[:version]}"
      sha256 "#{option[:sha256]}"

      keg_only :versioned_formula

      option "with-extract", "Extract appimagetool AppImage."

      def install
        (buildpath/"#{option[:basename]}").chmod(0755)
        bin.mkdir; libexec.mkdir

        if build.with?("extract") then
          libexec.cd do
            system "\#{buildpath}/#{option[:basename]}", "--appimage-extract"
          end
          bin.install_symlink (libexec/"squashfs-root/AppRun") => "#{option[:command]}"
        else
          (libexec/"bin").mkpath
          (libexec/"bin").install "\#{buildpath}/#{option[:basename]}"
          bin.install_symlink (libexec/"bin/#{option[:basename]}") => "#{option[:command]}"
        end
      end
    end
    EOS
  end

  def appimage_install_args
    Homebrew::CLI::Parser.new do
      description <<~EOS
        Brew test command.
      EOS

      switch "-e", "--extract",  description: "Extract Install."
      flag   "-n", "--name=",    description: "Formula name."
      flag   "-c", "--command=", description: "command for running AppImage."

      named_args [:url, :file], max: 1
    end
  end

  def appimage_install
    args = appimage_install_args.parse
    option = {}; verbose = args.verbose?

    url = Pathname.new(args.named.first)
    if %r[^[a-zA-Z]*://] === url.to_s then
      option[:url] = URL.new(url.to_s)
    else
      option[:url] = URL.new("file://#{url.realpath}")
    end
    ohai "AppImage URL = #{option[:url]}" if verbose

    unless option[:name] = args.name then
      raise "`--name` option must be specified."
    end
    ohai "Cellar Name = #{option[:name]}" if verbose

    unless option[:command] = args.command then
      raise "`--command` option must be specified."
    end
    ohai "Command of running AppImage = #{option[:command]}" if verbose

    unless /.+@.+/ === option[:name] then
      raise "`--name` option must be `NAME@VERSION`."
    end

    sha256 = %x{#{PROGS.curl} -s -L -o - #{option[:url]} | #{PROGS.sha256sum} -}
    sha256.gsub!(/^([0-9a-f]*).*/) { $1 }
    option[:sha256] = sha256.chomp!
    ohai "SHA256 Checksum of AppImage file = #{option[:sha256]}" if verbose

    option[:basename] = Pathname.new(option[:url].to_s).basename
    option[:klass] = Formulary.class_s(option[:name])
    option[:version] = option[:name].split("@")[1]
    ohai "Version of Cellar = #{option[:version]}" if verbose

    tmpdir = Pathname.new(Dir.mktmpdir("appimage-install-d"))
    (tmpdir/"#{option[:name]}.rb").write(formula_rb(option))
    ohai "Create Formula File, #{tmpdir}/#{option[:name]}.rb" if verbose

    extract = args.extract? ? "--with-extract" : ""
    ohai "Exec: brew reinstall --formula #{extract} #{tmpdir}/#{option[:name]}.rb" if verbose
    system "brew reinstall --formula #{extract} #{tmpdir}/#{option[:name]}.rb"
    tmpdir.rmtree
    ohai "Delete #{tmpdir}" if verbose
  end
end

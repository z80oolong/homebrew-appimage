$:.unshift(Pathname.new(__FILE__).realpath.dirname.to_s)

require "cli/parser"
require "formula"
require "lib/shellcommands"

module Homebrew
  SHELL = AppImage::ShellCommands.instance

  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }

  def formula_rb(option); <<~EOS
    class #{option[:klass]} < Formula
      desc "Formula to install AppImage #{option[:basename]}, generated by `brew appimage-install` command."
      homepage "#{option[:url]}"

      url "#{option[:url]}"
      sha256 "#{option[:sha256]}"
      version "#{option[:version]}"
      #revision 0

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
        Brew command for installing AppImage file.
      EOS

      switch "-n", "--dry-run",  description: "Dry run, AppImage is not installed."
      flag   "-N", "--name=",    description: "Specify Formula name."
      flag   "-V", "--version=", description: "Specify Formula version."
      flag   "-c", "--command=", description: "Specify command name for running AppImage."
      switch "-e", "--extract",  description: "Extract Install."
      switch "-O", "--output",   description: "Print formula for installing AppImage to stdout."

      named_args [:url, :file], max: 1
    end
  end

  def appimage_install
    args = appimage_install_args.parse
    option = {}; verbose = args.verbose?; dry_run = args.dry_run?
    arch_exp = %r{-*(aarch64|armhf|i686|x86_x?64)}

    odie "URL or file path must be specified." unless url = Pathname.new(args.named.first)
    option[:url] = URL.new((%r[^[a-zA-Z]*://] === url.to_s) ? url.to_s : "file://#{url.realpath}")

    option[:basename] = Pathname.new(option[:url].path).basename
    name = Pathname.new(option[:basename].to_s.gsub(arch_exp, ""))
    option[:version] = ((name.to_s)[/-?(HEAD-[0-9a-f]+)/, 1] || name.version).to_s
    name = (name.to_s)[/^([^\.]*?)-?#{Regexp.escape(option[:version])}/, 1] || ""
    option[:command] = (name[/^([a-zA-Z]+).*/, 1] || "").downcase
    option[:name] = (name.empty? || (/^appimage-/ === name)) ? name : ("appimage-" + name)

    if (option[:version].empty? && !args.version) then
      odie "Failed to detect AppImage's version number. `--version` option must be specified."
    end

    if (option[:name].empty? && !args.name) then
      odie "Failed to detect AppImage's Cellar name. `--name` option must be specified."
    end

    if args.name then
      option[:name] = args.name.to_s
      odie "Failed to specify AppImage's Cellar name." unless (/^[a-zA-Z0-9\.@-]+$/ === option[:name])

      if command = option[:name][/^(?:appimage-)?([a-zA-Z]+).*/, 1] then
        option[:command] = command.downcase
      end
    end 

    if args.version then
      option[:version] = Pathname.new("#{option[:name]}-#{args.version}.AppImage").version.to_s
      odie "Failed to specify AppImage's version number." if option[:version].empty?
    end

    if args.command then
      command = (args.command.to_s)[/^([a-zA-Z_\-]+).*/, 1] || ""
      odie "Failed to specify command name for running AppImage." if command.empty?
      option[:command] = command.downcase
    end

    if verbose || dry_run then
      ohai "URL of AppImage = #{option[:url]}"
      ohai "Basename of AppImage = #{option[:basename]}"
      ohai "Cellar Name of AppImage = #{option[:name]}"
      ohai "Cellar Version of AppImage = #{option[:version]}"
      ohai "Command name for running AppImage = #{option[:command]}"
      return if dry_run
    end

    option[:klass] = Formulary.class_s(option[:name])
    puts "Calcalating SHA256 Checksum of AppImage file..." if verbose
    sha256 = %x{#{SHELL.curl} -s -L -o - #{option[:url]} | #{SHELL.sha256sum} -}
    sha256.gsub!(/^([0-9a-f]*).*/) { $1 }
    option[:sha256] = sha256.chomp!
    ohai "SHA256 Checksum of AppImage file = #{option[:sha256]}" if verbose

    if args.output? then
      puts formula_rb(option)
      return
    end

    tmpdir = Pathname.new(Dir.mktmpdir("appimage-install-d"))
    (tmpdir/"#{option[:name]}.rb").write(formula_rb(option))
    ohai "Create Formula File, #{tmpdir}/#{option[:name]}.rb" if verbose

    extract = args.extract? ? "--with-extract" : ""
    ohai "Exec: brew reinstall --formula #{extract} #{tmpdir}/#{option[:name]}.rb" if verbose
    system "brew reinstall --formula #{extract} #{tmpdir}/#{option[:name]}.rb"
    tmpdir.rmtree
    ohai "Delete #{tmpdir}" if verbose
    ohai "AppImage `#{option[:basename]}` is installed in Cellar `#{option[:name]}`"
  end
end

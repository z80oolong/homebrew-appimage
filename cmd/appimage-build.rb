$:.unshift(Pathname.new(__FILE__).realpath.dirname.to_s)

require "formula"
require "cli/parser"
require "lib/appdirpath"
require "lib/shellcommands"
require "lib/builder"
require "lib/exclude_list"
require "lib/utils"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }

  def appimage_build_args
    Homebrew::CLI::Parser.new do
      description <<~EOS
        This is the brew extension command to create the AppImage package from the specified Formula.
      EOS

      switch "-g", "--global-exclude", description: "Exclude the excluded libraries from the AppImage package, "\
                                                    "even if they are dynamic libraries installed in Linuxbrew."
      switch "-c", "--core-include",   description: "Add all libraries, including the excluded libraries, "\
                                                    "to the AppImage package."
      flag   "-o", "--output=",        description: "Specifies the file name of the output AppImage package."
      flag   "-r", "--load-file=",     description: "Load file."

      named_args :installed_formula, min: 1, max: 1
    end
  end

  def appimage_build
    extend AppImage::Utils

    args = appimage_build_args.parse
    formula = args.named.to_formulae.first

    begin
      if args.load_file then
        loadfile = Pathname.new(args.load_file).realpath
        AppImage::Builder::NameSpace.module_eval(loadfile.read)
        ohai "Load #{loadfile}" if args.verbose?
        builder = AppImage::Builder.builder_class.new(formula)
      else
        builder = AppImage::Builder.new(formula)
      end

      install_apprun_icons_to_appdir(builder, args.verbose?)
      builder.exec_path_list.each do |exec_path|
        so_path_list = depend_so_path_list(exec_path,
                        :verbose        => args.verbose?,
                        :exclude_list   => builder.exclude_list,
                        :include_list   => builder.include_list,
                        :global_exclude => args.global_exclude?,
                        :core_include   => args.core_include?)
        install_bin_lib_to_appdir(builder, exec_path, so_path_list, args.verbose?)
      end

      ohai "Call method #{builder.class.name}#pre_build_appimage" if args.verbose?
      builder.pre_build_appimage(builder.appdir, args.verbose?)

      if args.output then
        output_file = Pathname.new(args.output)
        output_file = (output_file.dirname.realpath/output_file.basename)
      else
        appname = builder.appimage_name
        appversion = builder.appimage_version
        apparch = builder.appimage_arch
        output_file = (Pathname.pwd/"#{appname}-#{appversion}-#{apparch}.AppImage")
      end
      build_appimage(builder, output_file, args.verbose?)
    ensure
      ohai "Delete #{(builder.appdir/"..").realpath}" if args.verbose?
      builder.appdir.destroy
    end
  end
end

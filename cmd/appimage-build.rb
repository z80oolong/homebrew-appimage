$:.unshift(Pathname.new(__FILE__).realpath.dirname.to_s)

require "cli/parser"
require "formula"
require "lib/appdirpath"
require "lib/shellcommands"
require "lib/mixin"
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

      named_args :installed_formula, min: 1
    end
  end

  def appimage_build
    extend AppImage::Utils

    args = appimage_build_args.parse

    formulae = args.named.to_formulae.map do |formula|
      formula.class.include(AppImage::Mixin); formula
    end

    if args.output && (formulae.length >= 2) then
      raise "If the `--output` option is specified, then only one Formula must be specified."
    end

    formulae.each do |formula|
      install_apprun_icons_to_appdir(formula, args.verbose?)
      formula.opt_bin.glob("*") do |exec_path|
        so_path_list = depend_so_path_list(exec_path,
                        :verbose        => args.verbose?,
                        :exclude_list   => formula.exclude_list,
                        :include_list   => formula.include_list,
                        :global_exclude => args.global_exclude?,
                        :core_include   => args.core_include?)
        install_bin_lib_to_appdir(formula, exec_path, so_path_list, args.verbose?)
      end

      ohai "Call method Formula#pre_build_appimage" if args.verbose?
      formula.pre_build_appimage(formula.appdirpath, args.verbose?)

      if args.output then
        output_file = Pathname.new(args.output)
        output_file = (output_file.dirname.realpath/output_file.basename)
      else
        output_file = (Pathname.pwd/"#{formula.appimage_name}-#{formula.appimage_version}-#{formula.appimage_arch}.AppImage")
      end
      build_appimage(formula, output_file, args.verbose?)

      ohai "Delete #{formula.appdirpath.tmpdir}" if args.verbose?
      formula.appdirpath.destroy
    end
  end
end

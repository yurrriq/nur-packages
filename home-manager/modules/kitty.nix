{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.kitty;

  configModule = types.submodule {
    options = {
      editor = mkOption {
        type = types.str;
        default = ".";
        example = "vim";
        description = ''
          The console editor to use when editing the kitty config file or
          similar tasks.  A value of . means to use the environment variables
          VISUAL and EDITOR in that order. Note that this environment variable
          has to be set not just in your shell startup scripts but system-wide,
          otherwise kitty will not see it.
        '';
      };
      modifier = mkOption {
        type = types.str;
        default = "ctrl+shift";
        description = "The modifier for all default shortcuts.";
      };
      scrollbackLines = mkOption {
        type = types.int;
        default = 2000;
        example = -1;
        description = ''
          Number of lines of history to keep in memory for scrolling
          back. Memory is allocated on demand. Negative numbers are
          (effectively) infinite scrollback. Note that using very large
          scrollback is not recommended as it can slow down resizing of the
          terminal and also use large amounts of RAM.
        '';
      };
      shell = mkOption {
        type = types.str;
        default = ".";
        example = "fish";
        description = ''
          The shell program to execute. The default value of . means to use
          whatever shell is set as the default shell for the current user. Note
          that on macOS if you change this, you might need to add --login to
          ensure that the shell starts in interactive mode and reads its startup
          rc files.
        '';
      };
      term = mkOption {
        type = types.str;
        default = "xterm-kitty";
        example = "xterm";
        description = "The value of the TERM environment variable to set.";
      };
    };
  };

  # NOTE: https://raw.githubusercontent.com/dexpota/kitty-themes/c4bee86/themes/Solarized_Dark_Higher_Contrast.conf
  configFile = pkgs.writeText "kitty.conf" (optionalString (cfg.config != null) ''
    scrollback_lines ${toString cfg.config.scrollbackLines}
    editor ${cfg.config.editor}
    shell ${cfg.config.shell}
    term ${cfg.config.term}
    background            #001e26
    foreground            #9bc1c2
    cursor                #f34a00
    selection_background  #003747
    color0                #002731
    color8                #006388
    color1                #d01b24
    color9                #f4153b
    color2                #6bbe6c
    color10               #50ee84
    color3                #a57705
    color11               #b17e28
    color4                #2075c7
    color12               #178dc7
    color5                #c61b6e
    color13               #e14d8e
    color6                #259185
    color14               #00b29e
    color7                #e9e2cb
    color15               #fcf4dc
    selection_foreground #001e26
    kitty_mod ${cfg.config.modifier}
    map kitty_mod+enter new_window_with_cwd
    map kitty_mod+k combine : clear_terminal scrollback active : send_text normal \x0c
  '' + (optionalString (hasSuffix "darwin" builtins.currentSystem) ''
    macos_option_as_alt yes
  ''));
in
{

  options.programs.kitty = {
    enable = mkEnableOption "kitty - the fast, featureful, GPU based terminal emulator";
    package = mkOption {
      type = types.package;
      default = pkgs.kitty;
      defaultText = literalExample "pkgs.kitty";
      description = "The kitty package to use.";
    };
    config = mkOption {
      type = types.nullOr configModule;
      default = { };
      description = "kitty configuration options.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."kitty/kitty.conf" = {
      source = configFile;
    };
  };

}

{
  flake.homeModules.davidutzDesktop =
    { lib, pkgs, ... }:
    {
      home.packages = [ pkgs.mpv ];

      xdg.mimeApps.enable = true;
      xdg.mimeApps.defaultApplications = lib.genAttrs [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/quicktime"
        "video/x-msvideo"
        "video/vnd.avi"
        "video/mpeg"
        "video/ogg"
        "video/x-flv"
        "video/x-ms-wmv"
        "video/3gpp"
        "video/mp2t"
        "video/x-m4v"
        "audio/mpeg"
        "audio/flac"
        "audio/ogg"
        "audio/opus"
        "audio/wav"
        "audio/x-wav"
        "audio/mp4"
        "audio/x-m4a"
        "audio/aac"
        "audio/webm"
        "audio/x-matroska"
      ] (_: "mpv.desktop");
    };
}

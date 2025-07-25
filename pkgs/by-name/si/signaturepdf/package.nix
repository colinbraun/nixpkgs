{
  lib,
  stdenv,
  fetchFromGitHub,
  php,
  makeWrapper,
  imagemagick,
  librsvg,
  potrace,
  pdftk,
  ghostscript,
}:

stdenv.mkDerivation rec {
  pname = "signaturepdf";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "24eme";
    repo = "signaturepdf";
    rev = "v${version}";
    hash = "sha256-Sk59yHnLSmO/Dd+cAntiAXzYyo6Rsp779Q+SszonbMc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/signaturepdf $out/bin

    cp --target-directory=$out/share/signaturepdf --recursive \
      app.php config locale public templates vendor lib

    makeWrapper ${lib.getExe php} $out/bin/signaturepdf \
      --inherit-argv0 \
      --chdir $out/share/signaturepdf \
      --prefix PATH : ${
        lib.makeBinPath [
          imagemagick
          librsvg
          potrace
          pdftk
          ghostscript
        ]
      } \
      --run 'port=$1' \
      --run '[ $# -ge 1 ] || ( echo "Usage $0 <port> -d upload_max_filesize=24M -d post_max_size=24M -d max_file_uploads=201" >&2 && exit 1 )' \
      --run 'shift' \
      --run 'echo "You may now open a web browser on http://localhost:$port"' \
      --add-flags '-S "localhost:$port" -t public'

    runHook postInstall
  '';

  meta = {
    description = "Web software for signing PDFs and also organize pages, edit metadata and compress pdf";
    mainProgram = "signaturepdf";
    homepage = "https://pdf.24eme.fr/";
    changelog = "https://github.com/24eme/signaturepdf/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ DamienCassou ];
  };
}

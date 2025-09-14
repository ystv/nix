{
  lib,
  cacert,
  curl,
  unzip,
  runCommandLocal,
  stdenv,
  autoPatchelfHook,
  libcxx,
  # libcxxabi,
  libGL,
# gcc7,
}:

stdenv.mkDerivation rec {
  pname = "decklink-sdk";
  version = "14.0";

  buildInputs = [
    autoPatchelfHook
    libcxx
    # libcxxabi
    libGL
    # gcc7.cc.lib
    unzip
  ];

  # yes, the below download function is an absolute mess.
  # blame blackmagicdesign.
  src =
    runCommandLocal "${pname}-${lib.versions.majorMinor version}-src.zip"
      rec {
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = "sha256-gKUx9bvvLK9Ay0tCq3rWXkoDTtFIE+K3XkomU/zHwLA=";

        impureEnvVars = lib.fetchers.proxyImpureEnvVars;

        nativeBuildInputs = [
          curl
          unzip
        ];

        # ENV VARS
        SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

        # from the URL that the POST happens to, see browser console
        DOWNLOADID = "3b7958a069be4705abed586abf06b4b4";
        # from the URL the download page where you click the "only download" button is at
        REFERID = "916fbc626dea4bb6a4f54a443e3e1c22";
        SITEURL = "https://www.blackmagicdesign.com/api/register/us/download/${DOWNLOADID}";

        USERAGENT = builtins.concatStringsSep " " [
          "User-Agent: Mozilla/5.0 (X11; Linux ${stdenv.targetPlatform.linuxArch})"
          "AppleWebKit/537.36 (KHTML, like Gecko)"
          "Chrome/77.0.3865.75"
          "Safari/537.36"
        ];

        REQJSON = builtins.toJSON {
          platform = "Linux";
          policy = true;
          hasAgreedToTerms = true;
          country = "us";
          firstname = "test";
          lastname = "test2";
          email = "test@test.com";
          phone = "1234123";
          street = "2345";
          city = "234";
          zip = "2344";
          state = "Alaska";
          product = "Desktop Video 14.0 SDK";
          origin = "www.blackmagicdesign.com";
        };

      }
      ''
        RESOLVEURL=$(curl \
          -s \
          -H "$USERAGENT" \
          -H 'Content-Type: application/json;charset=UTF-8' \
          -H "Referer: https://www.blackmagicdesign.com/support/download/$REFERID/Linux" \
          --data-ascii "$REQJSON" \
          --compressed \
          "$SITEURL")

        curl \
          --retry 3 --retry-delay 3 \
          --compressed \
          "$RESOLVEURL" \
          > $out
      '';

  installPhase = ''
    runHook preInstall

    echo $NIX_BUILD_TOP

    mkdir -p $out/include
    cp -r $NIX_BUILD_TOP/Blackmagic\ DeckLink\ SDK\ 14.0/Linux/include $out

    runHook postInstall
  '';
}

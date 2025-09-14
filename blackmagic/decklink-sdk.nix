{
  lib,
  cacert,
  curl,
  unzip,
  runCommandLocal,
  stdenv,
  autoPatchelfHook,
  libcxx,
  libcxxabi,
  libGL,
  gcc7,
}:

stdenv.mkDerivation rec {
  pname = "decklink-sdk";
  version = "15.0";

  buildInputs = [
    autoPatchelfHook
    libcxx
    libcxxabi
    libGL
    gcc7.cc.lib
    unzip
  ];

  # yes, the below download function is an absolute mess.
  # blame blackmagicdesign.
  src =
    runCommandLocal "${pname}-${lib.versions.majorMinor version}-src.zip"
      rec {
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = "sha256-0YyOh1CJA0l+vvrEnIXVTBvbZm4V/2x2VAXMqAO7DGs=";

        impureEnvVars = lib.fetchers.proxyImpureEnvVars;

        nativeBuildInputs = [
          curl
          unzip
        ];

        # ENV VARS
        SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

        # from the URL that the POST happens to, see browser console
        DOWNLOADID = "d3a03e1609584ce6bee2f73813cc8a89";
        # from the URL the download page where you click the "only download" button is at
        REFERID = "31336991b8b64380bc79e94faf971126";
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
          product = "Desktop Video 12.5 SDK";
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
    cp -r $NIX_BUILD_TOP/Blackmagic\ DeckLink\ SDK\ 15.0/Linux/include $out

    runHook postInstall
  '';
}

# Build a snapshot of synapse from the current git working copy.

with import <nixpkgs> { };

let
  myGems = recurseIntoAttrs (callPackage ./.nix/rubylibs.nix { });
  synapse_requirements = [
    rubyLibs.aws_sdk
    myGems.zk
    myGems.docker_api
    haproxy
  ];
in
  stdenv.mkDerivation rec {
    name = "synapse-git";
    version = "0.11.2.1";

    src = ./.;

    meta = {
      description = "Development build of synapse from git";
      homepage = "https://github.com/benley/synapse";
    };

    buildInputs = [ ruby rubygems git makeWrapper ];
    propagatedBuildInputs = synapse_requirements;

    buildPhase = "gem build synapse.gemspec";

    installPhase = ''
      export HOME=$TMP/home; mkdir -pv "$HOME"

      gem install \
        --ignore-dependencies \
        --install-dir "$out/${ruby.gemPath}" \
        --bindir "$out/bin" \
        "synapse-aurora-${version}.gem" $gemFlags -- $buildFlags

      # Don't keep the .gem file in the finished package
      rm -frv "$out/${ruby.gemPath}/cache"

      addToSearchPath GEM_PATH "$out/${ruby.gemPath}"

      for prog in $out/bin/*; do
        wrapProgram "$prog" \
          --prefix GEM_PATH : "$GEM_PATH" \
          --prefix RUBYLIB : "${rubygems}/lib" \
          --set RUBYOPT rubygems \
          $extraWrapperFlags ''${extraWrapperFlagsArray[@]}
      done

      # Make sure all the executables are actually in the package
      for prog in $out/gems/*/bin/*; do
        [[ -e "$out/bin/$(basename $prog)" ]]
      done

      # looks like useless files which break build repeatability and consume space
      rm $out/${ruby.gemPath}/doc/*/*/created.rid \
         $out/${ruby.gemPath}/gems/*/ext/*/mkmf.log || true

      runHook postInstall
    '';

    propagatedUserEnvPkgs = synapse_requirements;

    passthru.isRubyGem = true;
  }

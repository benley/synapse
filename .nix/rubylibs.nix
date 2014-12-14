{ stdenv, config, fetchurl, callPackage
, gemfile ? ./Gemfile.nix
, patches ? null
, overrides ? null
}:

let
  inherit (stdenv.lib) fold optional;
  gemsMergeableFun = { generatedFuns ? [], patchFuns ? [], overrideFuns ? [] }:
  let
    generatedAttrs = map (f: f customGems) generatedFuns;
    generatedGems = map (a: a.gems) generatedAttrs;
    gem = callPackage <nixpkgs/pkgs/development/interpreters/ruby/gem.nix> {
      patches = map (f: callPackage f { inherit gems; }) patchFuns;
      overrides = map (f: callPackage f { }) overrideFuns;
    };
    customGems = stdenv.lib.mapAttrs gem (fold (x: y: x // y) { } generatedGems);
    gems = fold (x: y: x // y) customGems (map (a: a.aliases) generatedAttrs);
  in
  gems // {
    merge = { generated ? null, patches ? null, overrides ? null }:
      gemsMergeableFun {
        generatedFuns = generatedFuns ++ optional (generated != null) generated;
        patchFuns = patchFuns ++ optional (patches != null) patches;
        overrideFuns = overrideFuns ++ optional (overrides != null) overrides;
      };
  };
in
  ((gemsMergeableFun { }).merge {
    generated = import gemfile;
    inherit patches;
    inherit overrides;
  }).merge (
    let
      getLocalGemFun = name: stdenv.lib.attrByPath [ "gems" name ] null config;
    in
    {
      generated = getLocalGemFun "generated";
      patches = getLocalGemFun "patches";
      overrides = getLocalGemFun "overrides";
    }
  )

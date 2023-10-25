final: prev:

{
  useLldLinker = stdenv:
  let
    lld = prev.buildPackages.llvmPackages_16.lld;
    bintools = stdenv.cc.bintools.override {
      extraBuildCommands = ''
        wrap ${stdenv.cc.bintools.targetPrefix}ld.lld ${prev.path}/pkgs/build-support/bintools-wrapper/ld-wrapper.sh ${lld}/bin/ld.lld
        wrap ${stdenv.cc.bintools.targetPrefix}ld ${prev.path}/pkgs/build-support/bintools-wrapper/ld-wrapper.sh ${lld}/bin/ld.lld
      '';
    };
  in stdenv.override (old: {
    allowedRequisites = null;
    cc = stdenv.cc.override { inherit bintools; };
  });

  mkShell = prev.mkShell.override {
    stdenv = final.useLldLinker prev.stdenv;
  };

  my-project = prev.callPackage ./my-project {
    stdenv = final.useLldLinker prev.stdenv;
  };

  windows = prev.windows.overrideScope (wfinal: _: {
    libtre = wfinal.callPackage ./libtre {};
    libsystre = wfinal.callPackage ./libsystre {};
  });
}

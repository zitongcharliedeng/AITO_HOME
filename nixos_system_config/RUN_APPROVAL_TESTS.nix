{ lib, writeShellApplication, approvalTests }:

let
  testResults = lib.attrValues approvalTests;
in
writeShellApplication {
  name = "RUN_APPROVAL_TESTS";
  text = ''
    OUTPUT_DIR="''${1:-./screenshots}"
    mkdir -p "$OUTPUT_DIR"
    ${lib.concatMapStringsSep "\n" (drv: "cp ${drv}/*.png \"$OUTPUT_DIR/\"") testResults}
    echo "Screenshots saved to $OUTPUT_DIR"
  '';
}

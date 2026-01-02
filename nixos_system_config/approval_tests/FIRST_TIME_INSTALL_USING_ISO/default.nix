{ pkgs, systemModules, impermanence, self, disko, installerSystem }:

let
  iso = installerSystem.config.system.build.isoImage;
in
pkgs.runCommand "FIRST_TIME_INSTALL_USING_ISO" {
  nativeBuildInputs = [ pkgs.qemu pkgs.expect ];
} ''
  mkdir -p $out
  qemu-img create -f qcow2 disk.qcow2 20G
  ISO_FILE=$(ls ${iso}/iso/*.iso | head -1)
  export ISO_FILE

  timeout 600 expect << 'SCENARIO' | tee $out/test.log
    set timeout 300
    set iso_file $env(ISO_FILE)

    puts "\n--- USER BOOTS FROM ISO ---"
    puts "Using GENERIC_LINUX_PC fixture"
    spawn qemu-system-x86_64 \
      -m 4096 \
      -smp 2 \
      -nographic \
      -cdrom $iso_file \
      -drive file=disk.qcow2,format=qcow2 \
      -boot d

    expect {
      "automatic login" {
        puts "System booted - user auto-logged in"
      }
      timeout {
        puts "FAIL: System did not boot"
        exit 1
      }
    }

    expect "\$"

    puts "\n--- USER IS IN HOME DIRECTORY ---"
    send "pwd\r"
    expect {
      "/home/nixos" { puts "User starts in home directory" }
      timeout {
        puts "FAIL: User not in home directory"
        exit 1
      }
    }

    puts "\n--- USER SEES INSTALL SCRIPT ---"
    send "ls\r"
    expect {
      "INSTALL_SYSTEM" { puts "Install script is visible" }
      timeout {
        puts "FAIL: Install script not visible"
        exit 1
      }
    }

    puts "\n--- USER RUNS INSTALL SCRIPT ---"
    send "sudo ./INSTALL_SYSTEM.sh\r"
    expect {
      "Available machines" { puts "Script shows available machines" }
      "Usage:" { puts "Script shows usage instructions" }
      timeout {
        puts "FAIL: Script did not show help"
        exit 1
      }
    }

    puts "\n=== FIRST TIME INSTALL JOURNEY COMPLETE ==="
    exit 0
SCENARIO

  grep "JOURNEY COMPLETE" $out/test.log || (echo "Test failed" && cat $out/test.log && exit 1)
''

{ pkgs, systemModules, impermanence, self, disko, installerSystem }:

let
  iso = installerSystem.config.system.build.isoImage;
in
pkgs.runCommand "FIRST_TIME_INSTALL_USING_ISO" {
  nativeBuildInputs = [ pkgs.qemu pkgs.expect ];
  __network = true;
} ''
  mkdir -p $out
  qemu-img create -f qcow2 disk.qcow2 20G
  ISO_FILE=$(ls ${iso}/iso/*.iso | head -1)
  export ISO_FILE

  timeout 1800 expect << 'SCENARIO' | tee $out/test.log
    set timeout 600
    set iso_file $env(ISO_FILE)

    puts "\n--- USER BOOTS FROM ISO ---"
    puts "Using GENERIC_LINUX_PC fixture"
    spawn qemu-system-x86_64 \
      -m 4096 \
      -smp 2 \
      -nographic \
      -cdrom $iso_file \
      -drive file=disk.qcow2,format=qcow2 \
      -nic user,model=virtio-net-pci \
      -boot d

    expect {
      ":~\]" {
        puts "System booted - user auto-logged in"
      }
      timeout {
        puts "FAIL: System did not boot to shell prompt"
        exit 1
      }
    }

    sleep 1

    puts "\n--- USER IS IN HOME DIRECTORY ---"
    send "pwd\r"
    expect {
      "/home/nixos" { puts "User starts in home directory" }
      timeout {
        puts "FAIL: User not in home directory"
        exit 1
      }
    }
    expect ":~\]"

    puts "\n--- USER SEES INSTALL SCRIPT ---"
    send "ls\r"
    expect {
      "INSTALL_SYSTEM" { puts "Install script is visible" }
      timeout {
        puts "FAIL: Install script not visible"
        exit 1
      }
    }
    expect ":~\]"

    puts "\n--- USER RUNS INSTALL SCRIPT WITHOUT ARGS ---"
    send "sudo ./INSTALL_SYSTEM.sh\r"
    expect {
      "Available machines" { puts "Script shows available machines" }
      "Usage:" { puts "Script shows usage instructions" }
      timeout {
        puts "FAIL: Script did not show help"
        exit 1
      }
    }
    expect ":~\]"

    puts "\n--- USER RUNS INSTALL SCRIPT WITH MACHINE NAME ---"
    send "sudo ./INSTALL_SYSTEM.sh TEST_VM\r"
    expect {
      "Network OK" {
        puts "Install script verified network connectivity"
        puts "Continuing with full installation test..."

        puts "\n--- DISKO STARTS ---"
        expect {
          "Running disko to partition disk" { puts "Disko starting" }
          timeout {
            puts "FAIL: Disko did not start"
            exit 1
          }
        }

        puts "\n--- DISKO PARTITIONS DISK ---"
        expect {
          "Installing NixOS" { puts "Disko completed successfully, nixos-install starting" }
          timeout {
            puts "FAIL: Disko did not complete"
            exit 1
          }
        }

        puts "\n--- NIXOS-INSTALL DOWNLOADS AND INSTALLS SYSTEM ---"
        expect {
          "Installation complete" { puts "NixOS installation finished successfully" }
          timeout {
            puts "FAIL: nixos-install did not complete"
            exit 1
          }
        }
      }
      "No internet connection detected" {
        puts "Script correctly detected no network and showed user instructions"
        puts "NOTE: Full install test skipped - no network in sandbox"
        puts "User would see: connect via Ethernet or run nmtui for WiFi"
      }
      "Cloning" {
        puts "FAIL: Script tried to clone from GitHub instead of using embedded flake"
        exit 1
      }
      timeout {
        puts "FAIL: Script did not start or check network"
        exit 1
      }
    }

    puts "\n=== FIRST TIME INSTALL JOURNEY COMPLETE ==="
    exit 0
SCENARIO

  grep "JOURNEY COMPLETE" $out/test.log || (echo "Test failed" && cat $out/test.log && exit 1)
''

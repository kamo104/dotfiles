{ pkgs, lib, config, ...}: 

{
  options = {
    virt.enable = lib.mkEnableOption "enables virtualisation";
    virt.users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "The users to add to the virtualisation group";
    };
  };

  config = lib.mkIf config.virt.enable {
    virtualisation.libvirtd.enable = true;
    virtualisation.libvirtd.allowedBridges = [ "vibr0" ];
    virtualisation.spiceUSBRedirection.enable = true;

    # virtualisation.sharedDirectories = {
    #   share = {
    #     source = "/home/kamo/Downloads";
    #     target = "C:/Users/kamo/Desktop/share";
    #   };
    # };
    programs.virt-manager.enable = true;
  
    # environment.systemPackages = with pkgs; [
    #   virglrenderer
    # ];

    # boot.kernelParams = [ "amd_iommu=on" "iommu=1" "rd.driver.pre=vfio-pci" ];
    # boot.kernelModules = [ "kvm_amd" "vfio_pci" "vfio_virqfd" "vfio_iommu_type1" "vfio" ];
    
    # users.users.kamo.extraGroups = ["libvirtd"];
    users.users = lib.genAttrs config.virt.users (user: {
      extraGroups = [ "libvirtd" ];
    });
  };
}

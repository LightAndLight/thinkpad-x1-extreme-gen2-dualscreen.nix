# Dualscreen configuration for Thinkpad X1 Extreme (gen2)

## Usage

1. `$ sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware`

1. `$ sudo nix-channel --update`

1. Clone this repository to a convenient location

   `$ git clone https://github.com/LightAndLight/thinkpad-x1-extreme-gen2-dualscreen.nix`

1. Add this repository into your `configuration.nix`'s imports

   ```nix
   # configuration.nix
   
   imports = [
     /path/to/this/repository
   ];
   ```

## Example Configuration

```nix
# configuration.nix

thinkpad.dualscreen = {
  enable = true;
  outputs = {
    # the laptop's built-in screen
    eDP1 = {
      primary = false;
      mode = "3840x2160";
      
      # positioned underneath another 4k screen
      pos = "0x2160";
      rotate = "normal";
    };
    
    # use `xrandr -q` to find your additional screen's name
    VIRTUAL1 = {
      # primary screen
      primary = true;
      
      # use `xrandr -q` to find your additional screen's modes, 
      # and pick one.
      mode = "VIRTUAL1.446-3840x2160";
      
      # positioned at the top
      pos = "0x0";
      rotate = "normal";
    };
  };
};
```

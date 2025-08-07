{...}: {
  #lib = {
  #  path = ./lib;
  #};
  module = {
    path = ./module;
    description = "Snowfall module";
  };
  overlay = {
    path = ./overlay;
    description = "Snowfall overlay";
  };
  system = {
    path = ./system;
    description = "Snowfall system(host)";
  };
  home = {
    path = ./home;
    description = "Snowfall home";
  };
  user = {
    path = ./user;
    description = "Snowfall user";
  };
}

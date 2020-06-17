{
  sb = {
    isNormalUser = true;
    extraGroups = ["wheel" "plugdev" "dialout"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyPk5WyFoWSvF4ozehxcVBoZ+UHgrI7VW/OoQfFFwIQe0qvetUZBMZwR2FwkLPAMZV8zz1v4EfncudEkVghy4P+/YVLlDjqDq9zwZnh8Nd/ifu84wmcNWHT2UcqnhjniCdshL8a44memzABnxfLLv+sXhP2x32cJAamo5y6fukr2qLp2jbXzR+3sv3klE0ruUXis/BR1lLqNJEYP8jB6fLn2sLKinnZPfn6DwVOk10mGeQsdME/eGl3phpjhODH9JW5V2V5nJBbC0rBnq+78dyArKVqjPSmIcSy72DEIpTctnMEN1W34BGrnsDd5Xd/DKxKxHKTMCHtZRwLC2X0NWN"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCMALVC8RDTHec+PC8y1s3tcpUAODgq6DEzQdHDf/cyvDMfmCaPiMxfIdmkns5lMa03hymIfSmLUF0jFFDc7biRp7uf9AAXNsrTmplHii0l0McuOOZGlSdZM4eL817P7UwJqFMxJyFXDjkubhQiX6kp25Kfuj/zLnupRCaiDvE7ho/xay6Jrv0XLz935TPDwkc7W1asLIvsZLheB+sRz9SMOb9gtrvk5WXZl5JTOFOLu+JaRwQLHL/xdcHJTOod7tqHYfpoC5JHrEwKzbhTOwxZBQBfTQjQktKENQtBxXHTe71rUEWfEZQGg60/BC4BrRmh4qJjlJu3v4VIhC7SSHn1"
    ];
  };
  rj = {
    isNormalUser = true;
    extraGroups = ["wheel" "plugdev" "dialout"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZOitjBp9uB+Hldt5M040Jq/3rVFBbw40Xemkau3BLvMn8TzkJs5NLrlNa4vcwFecA/nh7aPzdGHc1b/E2EYCfM29oo/oVBJsp/L66YUbnYrneFNVp8Ccw3tZPPAiADjLZWta0JQLVVY6Dqtt0SH/oU5jC1F1qCa+krWqkKAVE8rfxYVspBGagxlpZuE83UC0j2yXrbHq6ZrAW917wXUEpcIR+mKalDM2Aa1FAZZH9upty2yysyOHh6/ljurz6tMRqjzjdJtVJ2YXf4GZpIuYcxCU1kvLKPLN0MZA+aXtraCGmEdjdx38sfRqHBnffXhCkJIo+W4aw4Xae2xplmGeInWqnUwsWxuVJENdPfbBOBdMRuFemuPZdmBcohczDygOC3h+oljBvQF6Ffyvk38pVLbd91p1+qgvtW7OcXTUjm17K1Oa54RGUcm1W2w3yJKCc8RQZXlwVtneTX0VoK39LC1yWfyMBg8sWeT66oE+v2CCEzsB0A1xZx/dK0r5bdfv8uNAH5d8RGL++zNEVrsA4iZF6FEeXgaoje3tKMqKTgOx4EDh93ie2rv7oE8xrPL5g0vb8wBQ1Kf4rukd7FPVu+E4+W5oSnQ42BJ9Z4sFCLQ9Dnhbg4VvREzAe9rVzfAG368iCVKkFcSq+AaLquqrBpwLbz10V3GLDARlF2IZZGQ== rj@lab.m-labs.hk"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC27krR8G8Pb59YuYm7+X2mmNnVdk/t9myYgO8LH0zfb2MeeXX5+90nW9kMjKflJss/oLl8dkD85jbJ0fRbRkfJd20pGCqCUuYAbYKkowigFVEkbrbWSLkmf+clRjzJOuBuUA0uq0XKS17uMC3qhu+dDdBOAIKb3L83NfVE8p8Pjb4BPktQrdxefM43/x4jTMuc7tgxVmTOEge3+rmVPK2GnLkUBgBn8b6S+9ElPd63HXI5J5f61v21l5N9V0mhTu1pv6PiDRdFIlFDK9dLVZcZ2qlzpKmCnFrOoreBEgre44SpfFe5/MMItxvWiVsj/rij/rHZZiol1k7JiQCnEHeCCbjjvcBBka5HxZgcb3vBZVceTOawrmjbdbA2dq35sUptz/bEgdZ1UVCmVpWsdROAlEDBmSSbcVwxzcvhoKnkpbuP4Q0V3tVKSLW053ADFNB4frtwY5nAZfsVErFLLphjwb8nlyJoDRNapQrn5syEiW0ligX2AAskZTYIl2A5AYyWPrmX6HJOPqZGatMU3qQiRMxs+hFqhyyCmBgl0kcsgW09MBKtJWk1Fbii98MHqgRUN9R7AUiYy5p78Pnv9DC8DT8Ubl9zoP0g5d40P9NGK2LAhMxLXvtckJ4ERqbSEcNZJw+q4jBrOHnMTz+NLdAUiEtru+6T2OdhaHv+eiNlFQ== robert-jordens-rsa4096"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUdbne3NtIG+iy/jer76/OY+IksuS3BDLSXPnWrGejWnig9h+L6sUV0lEVI6dqp+W/b8jWqPB8nh5S0NZsCd3Ta3Go82k/SPPkh9lB2PpfquhCjLnmC/RNc3TgC4FuiS+NZHqXaTggYHubNwEK+8gynMqkMQXjOGU02U0CtUfsYdAm75AW60DySZCRNwOcU0Ndpn1UCpha7fL1k179Dd/OtArkYsIL24ohlfxFeOB3jGYQK6ATmzbvCRjwIKXcyECuajWwfnDg9FtDWrqHNzu5dJlvmxoWm8zCDgMj53uiA7TjujQN81MYrIJNeEwSr5jXQMqzA3mzlk4k3Z0qs3TP robert-jordens-64FEFBAF-4D0749B2-rsa2048"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUaB2G1jexxfkdlly3fdWslH54/s/bOuvk9AxqpjtAY robert-jordens-ed25519"
    ];
  };
  harry = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout" "wireshark"];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBDcPNCgtdz8erFPRrAwCr4JrkeYXJUUvoRBgP0X2HlzJgDe1Inuo6sC6CGcO3IXbf4MwVA9XEp8BYPHARVeEHhufg/0wnIABLx2GcK99yxOLDUe4h/3YwtqvOcqHEsDx7w=="
    ];
  };
  astro = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJJTSJdpDh82486uPiMhhyhnci4tScp5uUe7156MBC8 a"
    ];
  };
  pca006132 = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBE/sPOOiw3843+rrcYV2pOVkffNc1xsOgnuCUmy1Fa2VF8x9kqmgQv61sxsuKRkKKoinvqrASxLkWVd6nkiiDuEISibEXs8r1BwuT05cS7RkEhCakSMZ6y/iqOtjt2bx+A=="
    ];
  };
  occheung = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBPEvmWmxpFpMgp5fpjKud8ev0cyf/+X5fEpQt/YD/+u4mbvZYPE300DLqQ0h/qjgvaGMz1ndf4idYnRdy+plJEC/+hmlRW5NlcpAr3S/LYAisacgKToFVl+MlBo+emS9Ig=="
    ];
  };
  dsleung = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBDbE7HzZKSwGbgRnzwrzCzb3gZKLSritwnEpHS4sa9oXJ5oLFkuFZOpPYDeiMlbUJ9jCk5FRmkLYIkrbz06SUr7P/eUjxu79ENi3RhfVu+ZrrPvgkhKvM/CiXvw3xCOu0w=="
    ];
  };
}

{
  sb = {
    isNormalUser = true;
    extraGroups = ["wheel" "plugdev" "dialout"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyPk5WyFoWSvF4ozehxcVBoZ+UHgrI7VW/OoQfFFwIQe0qvetUZBMZwR2FwkLPAMZV8zz1v4EfncudEkVghy4P+/YVLlDjqDq9zwZnh8Nd/ifu84wmcNWHT2UcqnhjniCdshL8a44memzABnxfLLv+sXhP2x32cJAamo5y6fukr2qLp2jbXzR+3sv3klE0ruUXis/BR1lLqNJEYP8jB6fLn2sLKinnZPfn6DwVOk10mGeQsdME/eGl3phpjhODH9JW5V2V5nJBbC0rBnq+78dyArKVqjPSmIcSy72DEIpTctnMEN1W34BGrnsDd5Xd/DKxKxHKTMCHtZRwLC2X0NWN"
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
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfZGegJYOV2qCdTf2R54thWt0UjH/ycarugV5UWrdql7w9yqaGwqeadRIVoz9IH++AB8NFxPzxMiQzOH5TI4r5hVjconslSeucMvh9u/GPJqQk94uZayodgfqCeBL5v8RqW4kJE1CHrSbKhzLrtWsTsju2XFidLGqBg1v7HWmSB6UqzqmQWqPLxDCi7/JW2ECuKjYlOJY+uzGFz5cxOtJO/lUNSXT3ZSWF/VLscuMmLsdyocdVwZANgPS7A0/wArlbZZMNw72CHuWsh8WVxarKIRwhoaBgXv7Oj3ohi6fVRGo1DOC3ucDGCDNjaQG2gbXGHEiPtrpz43I7BcCeJqNH harry@juno"
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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqkGZIb57sjzcnYg6tJXrK1iPKnIP6iYkcc2h/cf4rknvOT9ZkeUra7hCTjQDCiC168Lxcdx2wQciuq2SypoUMFytQoLphGHKWpgLB6yoaQgwCUW+To55kJlbs/rOywfwaRAtiyNsCtf+1FTbl0X0mKNIibjDqVyawXaUhfDLNB0TPg1yhhHdi/fqDgq+9kI/2E++8k9TZ2SUZ6vLbERU0cRkGCrVhqR7QEV+Oqa0uFBvNzc+tp/L3BKUUOCiSThNOtUHR9mSx9/Yq31tQ/I+l+oDcJyDiQlrFvDTBRbaDiMDwTFZolsQ8pFR0aJXHOrWRP11LF/EibjqbiK6WHDG/2mTnkREgGOElbOhg4yypMg5KXPY3JhjNibXV8p4GHjRb9g59N7F0s+ez44uS85fXUVVf840+mOx7W+9hGxK5ALr1I5EjUz8q2/SsF4eYuD44xCPK5rrKP0BYjnEQcDQEe5aZ2KyX+aSBF8jeiZsXti6x3Jg7ces6zlBWOoBNOPqTug4eNtkNmmPaoAzVeiItTJZBUAehLUAzyRD+8aTyB4DWAvesHPan+uQb9HvPH0rgymSEGxTi5280VWwvEpKHTGbuB0eYNFffDYVW0Y6xx3K4mZi71r6yCRdC/tsQEyM7N/dtoknvf77+iXCpb5yVSj0j5IAIVhlyszVMiW2qmw=="
    ];
  };
  occheung = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXYSxgxfvdHswDRhh30Qr3vTl6LCO9oTD0sVh/nRMjO+BgQ8HDst6jvolh/Ny6bQ710QLIthGtZxX8umFcoVebFkuAqenlXFXIpM86CYOST3zej/fRXmcvqJ2WV8EQzQGk5hLL/91bfpiYT1QQ0hg3/8x9ZVY5OkB2ehNZhFlZDBVqIPPOPYywMuaY7EXf5lHOX206kUeTygzrJFbHwX2du8/xZhcyqrgqVtN4+xy0q2OUDc3hrcSnxwdoSivbgl4LmQM5VWgOW/9fK0ji9naah9cFHNWv/lyz4uJYYttyx1C8jiqRZ7A1bhvemTK1VOvDZwVOp/o4ArjENgYIifzl" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFljU/TppiVf8G8yORVZYpzmDtHeTV6sjnWyAl5B5//MKz7xoeg6Ear0ft35GXgFQ5mg+kUGptE+qpAuD1l5NdXuE1Qve9mIl5Gffn02HOdt4qyy8W4HX/GY7VPz1QQNWZmasYnqBiWWsFwsORhXYI8xN6LYL0UzhxS8EXGs36yC/pUn8CNS+c1f4sHJ00h+wIfn9nbypSXbxYE50IYPZlUWKfAxFaZrE7/G3/PQTIIRqI1b6+6hBmcyKfj55/URGeN8Z0Zkp1neJ2laXz/kAzct7PDteLx++ACH+U10/uT1KSQt7zhJkPdvJ2FOUBRygVYUB4w8Wo79Jr5WntH5xb"
    ];
  };
  dsleung = {
    isNormalUser = true;
    extraGroups = ["plugdev" "dialout"];
  };
}

{ stdenv, fetchFromGitHub, autoreconfHook, pkg-config, openssl, libp11, pam }:

stdenv.mkDerivation rec {
  pname = "pam_p11";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "OpenSC";
    repo = "pam_p11";
    rev = "pam_p11-${version}";
    sha256 = "1caidy18rq5zk82d51x8vwidmkhwmanf3qm25x1yrdlbhxv6m7lk";
  };

  patchPhase =
    ''
    substituteInPlace src/match_openssh.c --replace \
      '"%s/.ssh/authorized_keys", pw->pw_dir)' \
      '"/etc/ssh/authorized_keys.d/%s", pw->pw_name)'
    '';

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [ pam openssl libp11 ];
}

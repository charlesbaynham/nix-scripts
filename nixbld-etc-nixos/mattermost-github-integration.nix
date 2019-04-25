{ fetchFromGitHub, python3Packages }:
with python3Packages;

let
  config = builtins.toFile "config.py" ''
    USERNAME = "Github"
    ICON_URL = ""

    # Repository settings
    MATTERMOST_WEBHOOK_URLS = {
        'default' : ("yourdomain.org/hooks/hookid", "off-topic"),
    }

    # Ignore specified event actions
    GITHUB_IGNORE_ACTIONS = {
        "pull_request": ["synchronize"]
    }

    # Ignore events from specified users
    IGNORE_USERS = {
        "someuser": ["push"],
        "anotheruser": ["push", "create"]
    }

    # Redirect events to different channels
    REDIRECT_EVENTS = {
        "push": "commits"
    }
    SECRET = ""
    SHOW_AVATARS = True
    SERVER = {
        'hook': "/",
        'address': "0.0.0.0",
        'port': 5000,
    }
  '';
in

buildPythonApplication rec {
  pname = "mattermost-github-integration";
  version = "0.0.0-unstable";
  src = fetchFromGitHub {
    owner = "softdevteam";
    repo = "mattermost-github-integration";
    rev = "master";
    sha256 = "1hfvjaxjhliy8sv9j3616fkdwd2jqhfsj9ai7ggx88zhxknrfx85";
  };
  propagatedBuildInputs = [
    appdirs
    click
    flask
    itsdangerous
    jinja2
    markupsafe
    olefile
    packaging
    pillow
    pyparsing
    requests
    six
    werkzeug
  ];
  checkInputs = [
    pytest
  ];
  preBuild = ''
    cp ${config} mattermostgithub/config.py
  '';
  postInstall = ''
    mkdir $out/bin
    echo "#!#{python}/bin/python" > $out/bin/server
    cat server.py >> $out/bin/server
    chmod a+x $out/bin/server
  '';
  doCheck = true;
}

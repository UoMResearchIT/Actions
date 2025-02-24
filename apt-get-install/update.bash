echo ::group::Update base system
sudo apt-get -c "$CFGFILE" update
echo "uomRIT_aptget_update=done" >> $GITHUB_ENV
echo ::endgroup::

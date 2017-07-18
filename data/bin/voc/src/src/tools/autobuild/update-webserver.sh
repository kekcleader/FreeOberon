# Push buildall and postpush to postpush server

set -x
for f in *.pl build-oberon.sh; do
  scp -P 5922 $f root@www:/var/lib/nethserver/ibay/githubhook/$f
  ssh -p 5922 root@www "chmod +x /var/lib/nethserver/ibay/githubhook/$f"
done;
ssh -p 5922 root@www "ls -lap /var/lib/nethserver/ibay/githubhook"


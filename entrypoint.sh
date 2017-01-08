#!/bin/bash
set -u -e -x

cd /var/lib/zerotier-one

if [ ! -e zerotier-cli ]; then
    tar -C / -xvf /zerotier.tar
fi

if [ ! -f identity.secret -o ! -f identity.public ]; then
  zerotier-idtool generate identity.secret identity.public
fi
echo >&2 "*** Zerotier address: $(cut -d: -f1 identity.public)"

zerotier-one -d

n_attempts=30
until zerotier-cli info >&/dev/null; do
  if [[ --n_attempts -eq 0 ]]; then
    echo >&2 "*** Failed to start zerotier-one"
    exit 1
  fi
  sleep 1
done

if [ -n "${ZEROTIER_JOIN_NET:-}" ]; then
    until zerotier-cli join "${ZEROTIER_JOIN_NET}"; do
        echo >&2 "*** Warning: failed to join zerotier network: ${ZEROTIER_JOIN_NET}. Retrying in 10 seconds"
        sleep 10
    done
fi

echo >&2 "*** Zerotier started"
sleep infinity

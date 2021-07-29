# ----------------------
# adding resolver for loca.lt domain
# ----------------------
[ -d /etc/resolver ] || sudo mkdir -v /etc/resolver

if [ ! -e /etc/resolver/loca.lt ]
then
    sudo bash -c 'echo -e "nameserver 127.0.0.1\nport 53535" > /etc/resolver/loca.lt'
else
    echo "loca.lt resolver already created"
fi

# ----------------------
# create cert for loca.lt domain
# ----------------------
if [ ! -d ./nginx/ssl ]; then
    mkdir -vp ./nginx/ssl
fi

if [ ! -e ./nginx/ssl/loca.lt.cert ] || [ ! -e ./nginx/ssl/loca.lt.key ]
then
    openssl req \
        -new \
        -newkey rsa:4096 \
        -days 3652 \
        -nodes \
        -x509 \
        -subj "/C=US/ST=Georgia/L=Atlanta/O=MiradorLLC/CN=loca.lt" \
        -keyout ./nginx/ssl/loca.lt.key \
        -out ./nginx/ssl/loca.lt.cert \
        -config ./openssl/loca.lt.conf
else
    echo "loca.lt cert already created. They last for 10 years"
fi

# ----------------------
# loca.lt.cert as a trusted cert to system
# ----------------------
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./nginx/ssl/loca.lt.cert

# ----------------------
# create start docker containers for dnsmasq and nginx
# ----------------------
docker-compose up -d
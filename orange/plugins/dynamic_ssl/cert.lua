local cache = ngx.shared.ssl_cert_pkey

local function my_load_certificate_chain(key)
    return cache:get(key..'cert')
end

local function my_load_private_key(key)
    return cache:get(key..'pkey')
end

local ssl = require "ngx.ssl"

local name,err = ssl.server_name()
if not name then
    ngx.log(ngx.ERR,name)
    return
end
-- clear the fallback certificates and private keys
-- set by the ssl_certificate and ssl_certificate_key
-- directives above:
local ok, err = ssl.clear_certs()
if not ok then
    ngx.log(ngx.ERR, "failed to clear existing (fallback) certificates")
    return ngx.exit(ngx.ERROR)
end

-- assuming the user already defines the my_load_certificate_chain()
-- herself.
local pem_cert_chain = (my_load_certificate_chain(name))
ngx.log(ngx.ERR,name,"[",pem_cert_chain,']')
assert(pem_cert_chain)
local der_cert_chain, err = ssl.cert_pem_to_der(pem_cert_chain)
if not der_cert_chain then
    ngx.log(ngx.ERR, "failed to convert certificate chain ",
        "from PEM to DER: ", err)
    return ngx.exit(ngx.ERROR)
end

local ok, err = ssl.set_der_cert(der_cert_chain)
if not ok then
    ngx.log(ngx.ERR, "failed to set DER cert: ", err)
    return ngx.exit(ngx.ERROR)
end

-- assuming the user already defines the my_load_private_key()
-- function herself.
local pem_pkey = assert(my_load_private_key(name))
local der_pkey,err = ssl.priv_key_pem_to_der(pem_pkey)
if not der_pkey then
    ngx.log(ngx.ERR, "failed to convert private key ",
        "from PEM to DER: ", err)
    return ngx.exit(ngx.ERROR)
end

local ok, err = ssl.set_der_priv_key(der_pkey)
if not ok then
    ngx.log(ngx.ERR, "failed to set DER private key: ", err)
    return ngx.exit(ngx.ERROR)
end
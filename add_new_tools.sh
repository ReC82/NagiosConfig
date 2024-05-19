
url="https://exchange.nagios.org/components/com_mtree/attachment.php?link_id=910&cf_id=24"
file="/usr/local/nagios/libexec/check_cpu.sh"

sudo wget "${url}" -O ${file} && sudo chown nagios:nagios ${file} && sudo chmod +x ${file}

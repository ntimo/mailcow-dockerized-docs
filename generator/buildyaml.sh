#!/bin/bash

GENERATOR_DIR="generator"

docs_dir="${1}"
site_dir="${2}"
language="${3}"

cd ${GENERATOR_DIR}/${docs_dir}

# create yaml nav subtree with all the files directly under a specific directory
# arguments:
# tabs - how deep do we show it in the hierarchy. Level 1 is the top level, max should probably be 3
# directory - to get mds from to add them to the yaml
# file - can be left empty to include all files
# name - what do we call the relevant section on the navbar. Empty if no new section is required
# maxdepth - how many levels of subdirectories do I include in the yaml in this section. 1 means just the top level and is the default if left empty
# excludefirstlevel - Optional param. If passed, mindepth is set to 2, to exclude the READMEs in the first directory level

navpart() {
	tabs=$1
	dir=$2
	file=$3
	section=$4
	maxdepth=$5
	excludefirstlevel=$6
	spc=""

	i=1
	while [ ${i} -lt ${tabs} ]; do
		spc="    $spc"
		i=$((i + 1))
	done

	if [ -z "$file" ]; then file='*'; fi
	if [[ -n $section ]]; then echo "$spc- ${section}:"; fi
	if [ -z "$maxdepth" ]; then maxdepth=1; fi
	if [[ -n $excludefirstlevel ]]; then mindepth=2; else mindepth=1; fi

	for f in $(find $dir -mindepth $mindepth -maxdepth $maxdepth -name "${file}.md" -printf '%h\0%d\0%p\n' | sort -t '\0' -n | awk -F '\0' '{print $3}'); do
		# If I'm adding a section, I need the child links to be one level deeper than the requested level in "tabs"
		if [ -z "$section" ]; then
			echo "$spc- '$f'"
		else
			echo "$spc    - '$f'"
		fi
	done
}

echo -e 'site_name: "mailcow: dockerized documentation"
site_url: https://ntimo.github.io/mailcow-dockerized-docs/
repo_url: https://github.com/mailcow/mailcow-dockerized
repo_name: mailcow/mailcow-dockerized
edit_uri: blob/master
site_description: mailcow Documentation
copyright: "Copyright &copy; 2019 André Peters"
docs_dir: '${docs_dir}'
site_dir: '${site_dir}'
#use_directory_urls: false
strict: true
theme:
    name: "material"
    palette:
      primary: "blue grey"
      accent: "light green"
    custom_dir: custom/themes/material
    favicon: images/favicon.png
    language: '${language}'
extra_javascript:
  - "custom/javascript/clients.js"
extra_css:
  - "custom/css/mailcow.css"
  - "custom/css/extra.css"
markdown_extensions:
  - codehilite:
      guess_lang: true
  - toc:
      permalink: true
  - admonition
  - pymdownx.magiclink
  - pymdownx.tasklist:
      custom_checkbox: true
  - pymdownx.mark
  - pymdownx.tilde
  - pymdownx.extra
  - footnotes
nav:'

navpart 1 . "README" ""

navpart 1 . . "'Information & Support'"

echo -ne "    - 'docs/index.md'
- 'Prerequisites':
  - 'Prepare Your System': 'docs/prerequisite-system.md'
  - 'DNS Setup': 'docs/prerequisite-dns.md'
- 'Installation, Update & Migration':
  - 'Installation': 'docs/i_u_m_install.md'
  - 'Update': 'docs/i_u_m_update.md'
  - 'Migration': 'docs/i_u_m_migration.md'
- 'First Steps (optional)':
  - 'SSL': 'docs/firststeps-ssl.md'
  - 'Rspamd Web UI': 'docs/firststeps-rspamd_ui.md'
  - 'Reverse Proxy': 'docs/firststeps-rp.md'
  - 'SNAT': 'docs/firststeps-snat.md'
  - 'Disable IPv6': 'docs/firststeps-disable_ipv6.md'
  - 'Setup a relayhost': 'docs/firststeps-relayhost.md'
  - 'Logging': 'docs/firststeps-logging.md'
  - 'Local MTA on Docker host': 'docs/firststeps-local_mta.md'
  - 'Sync Jobs Migration': 'docs/firststeps-sync_jobs_migration.md'
- 'Models':
  - 'Sender and receiver model': 'docs/model-sender_rcv.md'
  - 'ACL': 'docs/model-acl.md'
- 'Debugging & Troubleshooting':
    - 'Introduction': 'docs/debug.md'
    - 'Logs': 'docs/debug-logs.md'
    - 'Attach a Container': 'docs/debug-attach_service.md'
    - 'Reset Passwords (incl. SQL)': 'docs/debug-reset_pw.md'
    - 'Manual MySQL upgrade': 'docs/debug-mysql_upgrade.md'
    - 'Remove Persistent Data': 'docs/debug-rm_volumes.md'
    - 'Common Problems': 'docs/debug-common_problems.md'
    - 'Admin login to SOGo': 'docs/debug-admin_login_sogo.md'
- 'Backup & Restore':
  - 'Helper script':
      - 'Backup': 'docs/b_n_r_backup.md'
      - 'Restore': 'docs/b_n_r_restore.md'
  - 'Manually':
      - 'Maildir': 'docs/u_e-backup_restore-maildir.md'
      - 'MySQL': 'docs/u_e-backup_restore-mysql.md'
- 'Usage & Examples':
  - 'mailcow UI':
      - 'Configuration': 'docs/u_e-mailcow_ui-config.md'
      - 'Blacklist / Whitelist': 'docs/u_e-mailcow_ui-bl_wl.md'
      - 'Spamfilter': 'docs/u_e-mailcow_ui-spamfilter.md'
      - 'Temporary email aliase': 'docs/u_e-mailcow_ui-spamalias.md'
      - 'Tagging': 'docs/u_e-mailcow_ui-tagging.md'
      - 'Two-Factor Authentication': 'docs/u_e-mailcow_ui-tfa.md'
  - 'Postfix':
      - 'Custom transport maps': 'docs/u_e-postfix-custom_transport.md' 
      - 'Whitelist IP in Postscreen': 'docs/u_e-postfix-postscreen_whitelist.md'
      - 'Disable Sender Addresses Verification': 'docs/u_e-postfix-disable_sender_verification.md'
      - 'Max. message size (attachment size)': 'docs/u_e-postfix-attachment_size.md'
      - 'Statistics with pflogsumm': 'docs/u_e-postfix-pflogsumm.md'
  - 'Unbound':
      - 'Using an external DNS service': 'docs/u_e-unbound-fwd.md'
  - 'Dovecot':
      - '(Re-)Enable any and all authenticated ACL settings': 'docs/u_e-dovecot-any_acl.md'
      - 'Expunge a Users Mails': 'docs/u_e-dovecot-expunge.md'
      - 'Mail crypt': 'docs/u_e-dovecot-mail-crypt.md'
      - 'More Examples with DOVEADM': 'docs/u_e-dovecot-more.md'
      - 'Move vmail volume': 'docs/u_e-dovecot-vmail-volume.md'
      - 'IMAP IDLE interval': 'docs/u_e-dovecot-idle_interval.md'
      - 'FTS (Solr)': 'docs/u_e-dovecot-fts.md'
  - 'Nginx': 
     - 'Custom sites': 'docs/u_e-nginx.md'
     - 'Create subdomain webmail.example.org': 'docs/u_e-webmail-site.md'
  - 'Redis': 'docs/u_e-redis.md'
  - 'Rspamd': 'docs/u_e-rspamd.md'
  - 'SOGo': 'docs/u_e-sogo.md'
  - 'Docker':
      - 'Customize Dockerfiles': 'docs/u_e-docker-cust_dockerfiles.md'
      - 'Docker Compose Bash Completion': 'docs/u_e-docker-dc_bash_compl.md'
  - 'Why unbound?': 'docs/u_e-why_unbound.md'
  - 'Autodiscover / Autoconfig': 'docs/u_e-autodiscover_config.md'
  - 'Redirect HTTP to HTTPS': 'docs/u_e-80_to_443.md'
  - 'Adjust Service Configurations': 'docs/u_e-change_config.md'
  - 'Deinstall': 'docs/u_e-deinstall.md'
- 'Client Configuration':
  - 'Overview': 'docs/client.md'
  - 'Android': 'docs/client/client-android.md'
  - 'Apple macOS / iOS': 'docs/client/client-apple.md'
  - 'eM Client': 'docs/client/client-emclient.md'
  - 'KDE Kontact': 'docs/client/client-kontact.md'
  - 'Microsoft Outlook': 'docs/client/client-outlook.md'
  - 'Mozilla Thunderbird': 'docs/client/client-thunderbird.md'
  - 'Windows Mail': 'docs/client/client-windows.md'
  - 'Windows Phone': 'docs/client/client-windowsphone.md'
  - 'Manual configuration': 'docs/client/client-manual.md'
- 'Third party apps':
  - 'SOGo Connector for Thunderbird': 'docs/third_party-thunderbird.md'
  - 'Roundcube': 'docs/third_party-roundcube.md'
  - 'Portainer': 'docs/third_party-portainer.md'
  - 'Gogs': 'docs/third_party-gogs.md'
  - 'Gitea': 'docs/third_party-gitea.md'
"

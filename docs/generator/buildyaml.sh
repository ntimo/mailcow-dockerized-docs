#!/bin/bash

GENERATOR_DIR="docs/generator"

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
site_url: https://mailcowdocs.440044.xyz/
repo_url: https://github.com/mailcow/mailcow-dockerized
repo_name: mailcow/mailcow-dockerized
edit_uri: blob/master
site_description: Netdata Documentation
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
extra_css:
  - "custom/css/netdata.css"
markdown_extensions:
 - extra
 - abbr
 - attr_list
 - def_list
 - fenced_code
 - footnotes
 - tables
 - admonition
 - meta
 - sane_lists
 - smarty
 - toc:
    permalink: True
    separator: "-"
 - wikilinks
 - pymdownx.arithmatex
 - pymdownx.betterem:
    smart_enable: all
 - pymdownx.caret
 - pymdownx.critic
 - pymdownx.details
 - pymdownx.highlight:
    pygments_style: manni
    css_class: "highlight codehilite"
    linenums_style: pymdownx-inline
 - pymdownx.inlinehilite
 - pymdownx.magiclink
 - pymdownx.mark
 - pymdownx.smartsymbols
 - pymdownx.superfences
 - pymdownx.tasklist:
    custom_checkbox: true
 - pymdownx.tilde
 - pymdownx.betterem
 - pymdownx.superfences
 - markdown.extensions.footnotes
 - markdown.extensions.attr_list
 - markdown.extensions.def_list
 - markdown.extensions.tables
 - markdown.extensions.abbr
 - pymdownx.extrarawhtml
nav:'

navpart 1 . "README" ""

navpart 1 . . "'Information & Support'"

echo -ne "    - 'docs/index.md'
- 'Prerequisites':
    - 'docs/prerequisite-system.md'
    - 'docs/prerequisite-dns.md'
"


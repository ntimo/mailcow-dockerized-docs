#!/bin/bash

# buildhtml.sh

# Builds the html static site, using mkdocs

set -e

# Assumes that the script is executed either from the htmldoc folder, or from the root repo dir (as originally intended)
currentdir=$(pwd | awk -F '/' '{print $NF}')
echo "$currentdir"
if [ "$currentdir" = "generator" ]; then
	cd ../..
fi
GENERATOR_DIR="generator"
SRC_DIR="${GENERATOR_DIR}/src"

# Copy all docs files to generator/src
echo "Copying files"
rm -rf ${SRC_DIR}
mkdir ${SRC_DIR}
cp -r docs ${SRC_DIR}

# Copy mailcow html resources
cp -a ./${GENERATOR_DIR}/custom ./${SRC_DIR}/

LOC_DIR="localization"

echo "Preparing directories"
MKDOCS_CONFIG_FILE="${GENERATOR_DIR}/mkdocs.yml"
MKDOCS_DIR="doc"
DOCS_DIR=${GENERATOR_DIR}/${MKDOCS_DIR}
rm -rf ${DOCS_DIR}

prep_html() {
	lang="${1}"
	echo "Creating ${lang} mkdocs.yaml"

	if [ "${lang}" == "en" ] ; then
		SITE_DIR="build"
	else
		SITE_DIR="build/${lang}"
	fi

	# Generate mkdocs.yaml
	${GENERATOR_DIR}/buildyaml.sh ${MKDOCS_DIR} ${SITE_DIR} ${lang}>${MKDOCS_CONFIG_FILE}

	echo "Calling mkdocs"

	# Build html docs
	mkdocs build --config-file="${MKDOCS_CONFIG_FILE}"

	# Replace index.html with DOCUMENTATION/index.html. Since we're moving it up one directory, we need to remove ../ from the links
	echo "Replacing index.html with docs/index.html"
	sed 's/\.\.\///g' ${GENERATOR_DIR}/${SITE_DIR}/docs/index.html > ${GENERATOR_DIR}/${SITE_DIR}/index.html

}

for d in "en" $(find ${LOC_DIR} -mindepth 1 -maxdepth 1 -name .git -prune -o -type d -printf '%f ') ; do
	echo "Preparing source for $d"
	cp -r ${SRC_DIR} ${DOCS_DIR}
	if [ "${d}" != "en" ] ; then
		cp -a ${LOC_DIR}/${d}/* ${DOCS_DIR}/
	fi
	prep_html $d
	rm -rf ${DOCS_DIR}
done

# Remove cloned projects and temp directories
rm -rf ${GO_D_DIR} ${DOCS_DIR} ${SRC_DIR}

#cp CNAME ${GENERATOR_DIR}/build

echo "Finished"

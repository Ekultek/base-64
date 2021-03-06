#!/usr/bin/env bash

set -e # Exit upon error

# This script generates a 64-bit system
source variables.sh
source functions.sh

# Remove all the old files/folders
echo warn "Removing old folders"
requireRoot rm -rf "${HOST_TOOLS_DIR}"
requireRoot rm -rf "${HOST_CROSS_TOOLS_DIR}"
echo success "Finished..."
echo empty

# Create installation folder
requireRoot mkdir -p "${INSTALL_DIR}"

# Create necessary directories and symlinks
echo warn "Creating necessary folders. Please wait..."
requireRoot install -d "${TOOLS_DIR}"
requireRoot ln -s "${TOOLS_DIR}" /
requireRoot install -d "${CROSS_TOOLS_DIR}"
requireRoot ln -s "${CROSS_TOOLS_DIR}" /

# Change folder permissions to `whoami`
requireRoot chown -R `whoami` "${INSTALL_DIR}"
requireRoot chown -R `whoami` "${HOST_TOOLS_DIR}"
requireRoot chown -R `whoami` "${HOST_CROSS_TOOLS_DIR}"

echo success "Finished..."
echo empty

# Create new configuration file
cat > "${CONFIG_FILE}" << EOF
#!/usr/bin/env bash

export INSTALL_DIR="${INSTALL_DIR}"
export HOST_TOOLS_DIR="${HOST_TOOLS_DIR}"
export HOST_CROSS_TOOLS_DIR="${HOST_CROSS_TOOLS_DIR}"
export CONFIG_FILE="${CONFIG_FILE}"
export MAKE_TESTS="TRUE"
export MAKE_PARALLEL="-j$(cat /proc/cpuinfo | grep processor | wc -l)"
export TARGET="${TARGET}"
export PATH="${TMP_PATH}"
export HOST="${HOST}"
export BUILD64="${BUILD64}"
export LC_ALL="${LC_ALL}"
export VM_LINUZ="${VM_LINUZ}"
export SYSTEM_MAP="${SYSTEM_MAP}"
export CONFIG_BACKUP="${CONFIG_BACKUP}"
unset CFLAGS CXXFLAGS
EOF

# Make all the configurations available
source "${CONFIG_FILE}"

# Copy the data to the installation directory
echo warn "Copying data to ${INSTALL_DIR}. Please wait..."
cp -ur ./* "${INSTALL_DIR}"
echo empty

#----------------------------------------------------------------------------------------------------#
#                               S T A R T   I N S T A L L A T I O N
#----------------------------------------------------------------------------------------------------#

# Construct cross-compile tools
pushd "${CROSS_COMPILE_TOOLS_DIR}" && bash init.sh && popd
# Build temporary system
pushd "${TEMP_SYSTEM_DIR}" && bash init.sh && popd
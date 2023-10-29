#!/usr/bin/env bash
set -ex

# 1.13.1
tag=${1}
# 1
build_id=${2}
# 1.13.1-1
version="${tag}-${build_id}"

function replace() {
  local old="${1}"
  local new="${2}"
  local fpath="${3}"

  if [ "$(uname)" == "Darwin" ]; then
    # Mac OS X
    sed -e "s#${old}#${new}#g" -i '' ${fpath}
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # GNU/Linux
    sed -e "s#${old}#${new}#g" -i ${fpath}
  fi
  return $?
}

build_dir="$(PWD)/build/$(date +'%Y%m%dT%H%M%S')"
mkdir -p ${build_dir}

# *.orig.tar.gz
cp skopeo-${tag}.tar.gz ${build_dir}/skopeo_${tag}.orig.tar.gz

# *.debian.tar.gz
cp -rp ./debian ${build_dir}
pushd ${build_dir}
replace "__tag__" "${tag}" ./debian/changelog
replace "__build_id__" "${build_id}" ./debian/changelog
tar -zcvf skopeo_${version}.debian.tar.gz ./debian
rm -r ./debian
popd

# *.dsc
dsc_path="${build_dir}/skopeo_${version}.dsc"
cp skopeo.dsc ${dsc_path}
pushd ${build_dir}
replace "__version__" "${version}" "${dsc_path}"

sha1sumstr=$(for i in $(ls | grep tar); do
  sha1sum ${i} | awk '{printf " %s ",$1}';
  wc -c ${i} | awk '{printf $1" " $2"\\n"}';
  # stat --printf="%s" ${i};
done)
sha1sumstr=$(echo -E "${sha1sumstr%??}")
replace "__sha1sumstr__" "${sha1sumstr}" "${dsc_path}"

sha256sumstr=$(for i in $(ls | grep tar); do
  sha256sum ${i} | awk '{printf " %s ",$1}';
  wc -c ${i} | awk '{printf $1" " $2"\\n"}';
done)
sha256sumstr=$(echo -E "${sha256sumstr%??}")
replace "__sha256sumstr__" "${sha256sumstr}" "${dsc_path}"

md5sumstr=$(for i in $(ls | grep tar); do
  md5sum ${i} | awk '{printf " %s ",$1}';
  wc -c ${i} | awk '{printf $1" " $2"\\n"}';
  # stat --printf="%s" ${i};
done)
md5sumstr=$(echo -E "${md5sumstr%??}")
replace "__md5sumstr__" "${md5sumstr}" "${dsc_path}"
popd

# *.spec
spec_path="${build_dir}/skopeo_${version}.spec"
cp skopeo.spec ${spec_path}
pushd ${build_dir}
replace "__tag__" "${tag}" "${spec_path}"
replace "__build_id__" "${build_id}" "${spec_path}"

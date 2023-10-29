%global debug_package %{nil}

Name: skopeo
Epoch: 100
Version: __tag__
Release: __build_id__%{?dist}
Summary: Container image repository tool
License: Apache-2.0
URL: https://github.com/containers/skopeo/tags
Source0: %{name}_%{version}.orig.tar.gz
BuildRequires: golang-1.21
BuildRequires: glibc-static
BuildRequires: glib2-devel
BuildRequires: gpgme-devel
BuildRequires: libassuan-devel
BuildRequires: libgpg-error-devel
BuildRequires: libseccomp-devel
BuildRequires: make
BuildRequires: pkgconfig
Requires: containers-common

%description
skopeo is a command line utility for various operations on container
images and image repositories. skopeo is able to inspect a repository on
a Docker registry and fetch images layers. skopeo can copy container
images between various storage mechanisms.

%prep
%autosetup -T -c -n %{name}_%{version}-%{release}
tar -zx -f %{S:0} --strip-components=1 -C .

%build
mkdir -p bin
set -ex && \
    export CGO_ENABLED=1 && \
    go build \
        -mod vendor -buildmode pie -v \
        -ldflags "-s -w" \
        -tags "netgo osusergo exclude_graphdriver_devicemapper exclude_graphdriver_btrfs containers_image_openpgp" \
        -o ./bin/skopeo ./cmd/skopeo

%install
install -Dpm755 -d %{buildroot}%{_bindir}
install -Dpm755 -d %{buildroot}%{_prefix}/share/bash-completion/completions
install -Dpm755 -t %{buildroot}%{_bindir}/ bin/skopeo
./bin/skopeo completion bash > %{buildroot}%{_prefix}/share/bash-completion/completions/skopeo

%files
%license LICENSE
%{_bindir}/*
%{_prefix}/share/bash-completion/completions/*

%changelog

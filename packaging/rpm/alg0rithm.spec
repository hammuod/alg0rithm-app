Name:           alg0rithm
Version:        3.0.0
Release:        1%{?dist}
Summary:        Learn algorithms – simple, fast, offline-ready
License:        AGPL-3.0
URL:            https://alg0rithm.dev
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
Requires:       xdg-utils

%description
Alg0rithm is a minimalist educational platform for programming logic
and algorithms. Offline-capable PWA packaged as a desktop application.

%prep
%setup -q

%build
# no compilation

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/256x256/apps
mkdir -p %{buildroot}%{_datadir}/doc/%{name}

install -m 755 alg0rithm %{buildroot}%{_bindir}/alg0rithm
install -m 644 alg0rithm.desktop %{buildroot}%{_datadir}/applications/
if [ -f icon.png ]; then
  install -m 644 icon.png %{buildroot}%{_datadir}/icons/hicolor/256x256/apps/alg0rithm.png
fi

%files
%{_bindir}/alg0rithm
%{_datadir}/applications/alg0rithm.desktop
%{_datadir}/icons/hicolor/256x256/apps/alg0rithm.png
%doc

%changelog
* Sat Oct 24 2026 Hammoud <contact@alg0rithm.dev> - 3.0.0-1
- Initial multi-distro package

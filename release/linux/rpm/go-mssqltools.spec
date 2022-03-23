# RPM spec file for go-mssqltools
# Definition of macros used - https://fedoraproject.org/wiki/Packaging:RPMMacros?rd=Packaging/RPMMacros

# .el7.centos -> .el7
%if 0%{?rhel}
  %define dist .el%{?rhel}
%endif

%define name           go-mssqltools
%define release        1%{?dist}
%define version        %{getenv:CLI_VERSION}
%define repo_path      %{getenv:REPO_ROOT_DIR}
%define cli_lib_dir    %{_libdir}/go-mssqltools

%global _python_bytecompile_errors_terminate_build 0
%undefine _missing_build_ids_terminate_build
%global _missing_build_ids_terminate_build 0

# -- SW --
%global __python %{__python3}

Summary:        GO MSSQL Tools
License:        restricted (https://aka.ms/eula-go-mssqltools-en)
Name:           %{name}
Version:        %{version}
Release:        %{release}
Url:            http://www.microsoft.com/sql
BuildArch:      x86_64

%description
MSSQL TOOLS CLI, a multi-platform command line experience for SQL Server and Azure SQL.

%prep
%install

# Create executable
mkdir -p %{buildroot}%{_bindir}
cp %{repo_path}/sqlcmd %{buildroot}%{_bindir}

%files
%attr(0755,root,root) %{_bindir}/sqlcmd

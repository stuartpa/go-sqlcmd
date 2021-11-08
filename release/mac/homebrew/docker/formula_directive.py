# ------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# ------------------------------------------------------------------------------

import os
import requests
import jinja2
import subprocess
import json
import codecs
import pkg_resources

from jinja2 import Environment
from contextlib import closing
from hashlib import sha256
from urllib.request import urlopen

TEMPLATE_FILE_NAME = 'formula.tpl'

RESOURCE_TEMPLATE = Environment(trim_blocks=True).from_string("""\
  resource "{{ resource.name }}" do
    url "{{ resource.url }}"
    {{ resource.checksum_type }} "{{ resource.checksum }}"
  end
""")

COMMENTED_BOTTLE_TEMPLATE = Environment(trim_blocks=True).from_string("""\
  #  bottle do
  #    root_url "{{ root_url }}"
  #    cellar :any
  #    sha256 "{{ sha256_catalina }}" => :catalina
  #    sha256 "{{ sha256_mojave }}" => :mojave
  #    sha256 "{{ sha256_high_sierra }}" => :high_sierra
  #  end
""")


def main():
    """ Driver four building go-mssqltools.rb formular"""
    print('Generate formular for GO MSSQL Tools homebrew release.')

    upstream_url = os.environ['HOMEBREW_UPSTREAM_URL']
    bottle_url = os.getenv('HOMEBREW_BOTTLE_URL', None)

    print('HOMEBREW_UPSTREAM_URL:: ' + upstream_url)

    # -- determine if upstream is a local file or remote URL --
    if not upstream_url.startswith('http'):
        local_src = os.path.join(
            os.path.dirname(__file__),
            os.path.basename(upstream_url)
        )

        if os.path.isfile(local_src):
            upstream_url = 'file://{{PWD}}/' + os.path.basename(upstream_url)
            upstream_sha = compute_sha256(local_src)
        else:
            raise FileNotFoundError(local_src)
    else:
        upstream_sha = compute_sha256(upstream_url)

    template_path = os.path.join(os.path.dirname(__file__), TEMPLATE_FILE_NAME)
    with open(template_path, mode='r') as fq:
        template_content = fq.read()

    template = jinja2.Template(template_content)

    content = template.render(
        cli_version=os.environ['CLI_VERSION'],
        upstream_url=upstream_url,
        upstream_sha=upstream_sha,
        resources=collect_resources(),
        bottle_hash=last_bottle_hash(bottle_url)
    )

    content = content + '\n' if not content.endswith('\n') else content

    with open('azdata-cli.rb', mode='w') as fq:
        fq.write(content)


def compute_sha256(resource: str) -> str:
    import hashlib
    sha256 = hashlib.sha256()

    if os.path.isfile(resource):
        with open(resource, 'rb') as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256.update(byte_block)
    else:
        resp = requests.get(resource)
        resp.raise_for_status()
        sha256.update(resp.content)

    return sha256.hexdigest()


def collect_resources() -> str:
    nodes_render = []
    for node in make_graph():
        nodes_render.append(RESOURCE_TEMPLATE.render(resource=node))
    return '\n\n'.join(nodes_render)


def make_graph() -> list:
    """
    Builds the dependency graph.
    """
    dependencies = []
    p = subprocess.Popen(['pipdeptree', '--json'], stdout=subprocess.PIPE)

    graph = json.loads(p.communicate()[0])
    installed = []
    blacklist = ['enum34', 'pipdeptree', 'setuptools', 'jupyterlab-widgets']

    def install_dependencies_of_the_dependency(name, installed):
        for pkg in graph:
            if pkg['package']['package_name'] == name:
                for dep in pkg['dependencies']:
                    name = dep['package_name']
                    version = dep['installed_version']
                    if name not in installed:
                        print(name + ':' + version + '--installing deps/deps')
                        dependencies.append(research_package(name, version))
                        installed.append(name)
        return installed

    for pkg in graph:
        if pkg['package']['package_name'] in blacklist:
            continue

        print('============================')
        print(pkg['package']['package_name'])
        print('----------------------------')

        for dep in pkg['dependencies']:
            name = dep['package_name']
            version = dep['installed_version']
            if not name.startswith('azdata-'):
                # 1. install dependencies of the dependency
                installed = install_dependencies_of_the_dependency(
                    name,
                    installed
                )

                # 2. install_dependency of the parent dependency
                if name not in installed:
                    print(name + '/' + version + '--installing parent dep')
                    dependencies.append(research_package(name, version))
                    installed.append(name)

        # 3. install parent dependency itself
        name = pkg['package']['package_name']
        if not name.startswith('azdata-') and name not in installed:
            name = pkg['package']['package_name']
            version = pkg['package']['installed_version']
            print(name + '/' + version + '- installing parent...')
            dependencies.append(research_package(name, version))
            installed.append(name)

        print('============================')

    # `ipython` needs to be ordered before `ipykernal`, send it to the end
    # https://github.com/ipython/ipykernel/issues/250
    ipykernel = terminado = None
    ordered_dependencies = []
    for dependency in dependencies:
        if dependency['name'] == 'ipykernel':
            ipykernel = dependency
        else:
            # ignored dependencies
            if dependency['name'] not in blacklist:
                ordered_dependencies.append(dependency)
    ordered_dependencies.append(ipykernel)
    dependencies = ordered_dependencies

    print('Total dependencies: {0}'.format(len(dependencies)))

    return dependencies


def research_package(name, version) -> str:
    """
    Inspect a package's meta-info and assemble.
    """
    with closing(urlopen('https://pypi.io/pypi/{}/json'.format(name))) as f:
        reader = codecs.getreader("utf-8")
        pkg_data = json.load(reader(f))

    pkg = dict()
    pkg['name'] = pkg_data['info']['name']
    pkg['homepage'] = pkg_data['info'].get('home_page', '')
    pkg['checksum_type'] = 'sha256'

    artifact = None
    for pypi_version in pkg_data['releases']:
        if pkg_resources.safe_version(pypi_version) == version:
            for version_artifact in pkg_data['releases'][pypi_version]:
                if version_artifact['packagetype'] == 'sdist':
                    artifact = version_artifact
                    break
            if artifact is None:
                print('Could not find an exact version match for {} version {} '
                      'using newest instead'.format(name, version))

    # @TODO: mssql-cli needs to publish source tar.gz to pypi, so we host it
    # for now, eventually we will remove this
    if name == 'mssql-cli':
        artifact = {'url': os.environ['MSSQL_CLI_SRC_URL']}

    # -- no version given or exact match not found --
    if artifact is None:
        for url in pkg_data['urls']:
            if url['packagetype'] == 'sdist':
                artifact = url
                break

    if not artifact:
        raise ValueError('Package {}:{} release not found.'.
                         format(name, version))

    pkg['url'] = artifact['url']
    tokens = pkg['url'].split('/')
    print('    installed: {0}'.format(tokens[len(tokens) - 1]))

    if 'digests' in artifact and 'sha256' in artifact['digests']:
        pkg['checksum'] = artifact['digests']['sha256']
    else:
        with closing(urlopen(artifact['url'])) as f:
            pkg['checksum'] = sha256(f.read()).hexdigest()

    return pkg


def last_bottle_hash(resource_url: str) -> str:
    """
    Fetch the `bottle do` and end from the latest brew formula
    """
    # if no existing binary bottle supplied then build commented bottle section
    # as a helper to be populated in later
    if not resource_url:
        return COMMENTED_BOTTLE_TEMPLATE.render()

    # -- else extract  bottle hash and reuse --
    resp = requests.get(resource_url)
    resp.raise_for_status()

    lines = resp.text.split('\n')
    look_for_end = False
    start = 0
    end = 0
    for idx, content in enumerate(lines):
        if look_for_end:
            if 'end' in content:
                end = idx
                break
        else:
            if 'bottle do' in content:
                start = idx
                look_for_end = True

    return '\n'.join(lines[start: end + 1])


if __name__ == '__main__':
    main()

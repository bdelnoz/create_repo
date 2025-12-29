# Templates .gitignore - Fichiers essentiels

Copie chaque contenu dans `gitignore_templates/`

---

## python.gitignore

```gitignore
# Template : Python
# Description : Python bytecode, virtual environments, distribution packages
# Maintainer : Bruno DELNOZ
# Last update : 2025-10-25
# Compatible with : Python 3.x, pip, poetry, pipenv

# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/

# Translations
*.mo
*.pot

# Django
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask
instance/
.webassets-cache

# Scrapy
.scrapy

# Sphinx
docs/_build/

# PyBuilder
.pybuilder/
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# pipenv
Pipfile.lock

# poetry
poetry.lock

# pdm
.pdm.toml

# PEP 582
__pypackages__/

# Celery
celerybeat-schedule
celerybeat.pid

# SageMath
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder
.spyderproject
.spyproject

# Rope
.ropeproject

# mkdocs
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre
.pyre/

# pytype
.pytype/

# Cython
cython_debug/
```

---

## web.gitignore

```gitignore
# Template : Web/JavaScript/Node.js
# Description : Node.js dependencies, build outputs, logs
# Maintainer : Bruno DELNOZ
# Last update : 2025-10-25
# Compatible with : Node.js, npm, yarn, pnpm, React, Vue, Angular, Next.js

# Dependencies
node_modules/
jspm_packages/
bower_components/

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage
coverage/
*.lcov
.nyc_output/

# Compiled
build/Release

# TypeScript
*.tsbuildinfo

# Optional caches
.npm
.eslintcache
.stylelintcache

# Microbundle
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of npm pack
*.tgz

# Yarn
.yarn-integrity
.yarn/cache/
.yarn/unplugged/
.yarn/build-state.yml
.yarn/install-state.gz
.pnp.*

# parcel-bundler
.cache
.parcel-cache

# Next.js
.next/
out/

# Nuxt.js
.nuxt/
dist/

# Gatsby
.cache/
public/

# vuepress
.vuepress/dist/
.temp/

# Docusaurus
.docusaurus/

# Serverless
.serverless/

# FuseBox
.fusebox/

# DynamoDB Local
.dynamodb/

# TernJS
.tern-port

# VSCode test
.vscode-test

# yarn v2
.yarn/cache
.yarn/unplugged
.yarn/build-state.yml
.yarn/install-state.gz
.pnp.*

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
.env.*.local

# Build
dist/
build/
```

---

## node.gitignore

```gitignore
# Template : Node.js
# Description : Node.js dependencies, build outputs (copy of web.gitignore)
# Maintainer : Bruno DELNOZ
# Last update : 2025-10-25
# Compatible with : Node.js, npm, yarn, pnpm

# Dependencies
node_modules/
jspm_packages/
bower_components/

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Runtime
pids/
*.pid
*.seed
*.pid.lock

# Coverage
coverage/
*.lcov
.nyc_output/

# Compiled
build/Release

# TypeScript
*.tsbuildinfo

# Caches
.npm
.eslintcache
.stylelintcache

# Microbundle
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# REPL history
.node_repl_history

# npm pack
*.tgz

# Yarn
.yarn-integrity
.yarn/cache/
.yarn/unplugged/
.yarn/build-state.yml
.yarn/install-state.gz
.pnp.*

# Bundlers
.cache
.parcel-cache
.next/
out/
.nuxt/
dist/
.cache/
public/
.vuepress/dist/
.temp/
.docusaurus/
.serverless/
.fusebox/
.dynamodb/
.tern-port
.vscode-test

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
.env.*.local

# Build
dist/
build/
```

---

## vscode.gitignore

```gitignore
# Template : Visual Studio Code
# Description : VSCode workspace and settings
# Maintainer : Bruno DELNOZ
# Last update : 2025-10-25
# Compatible with : Visual Studio Code

# VSCode directories
.vscode/
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
!.vscode/*.code-snippets

# Local History
.history/

# Built Extensions
*.vsix
```

---

## macos.gitignore

```gitignore
# Template : macOS
# Description : macOS system files
# Maintainer : Bruno DELNOZ
# Last update : 2025-10-25
# Compatible with : macOS

# General
.DS_Store
.AppleDouble
.LSOverride

# Icon must end with two \r
Icon

# Thumbnails
._*

# Files in root of volume
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

# Directories on remote AFP share
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk
```

---

**Ces 5 templates sont les plus utilisés. Pour les 20 autres templates, je les mets dans un artefact séparé...**

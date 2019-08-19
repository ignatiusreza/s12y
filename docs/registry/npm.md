# NPM

- Docs: `https://github.com/npm/registry/blob/master/docs/REGISTRY-API.md`

- Available Info:

  - Dependencies: :heavy_check_mark:
  - Maintainers: :heavy_check_mark:
  - Repository: :heavy_check_mark:

- Sample Endpoint:

  - `https://registry.npmjs.org/[packageName]`

    ```js
    {
      "_id": [packageName],
      "_rev": "1281-723cff506762ce198100f53a338b1b71",
      "name": [packageName],
      "description": [blurb],
      "dist-tags": {
        "latest": [version],
        "next": [version],
        "canary": [version],
        "unstable": [version],
        "alpha": [version]
      },
      "versions": {
        [version]: {
          "name": [packageName],
            "description": [blurb],
            "keywords": [],
            "version": [version],
            "homepage": "https://xxx.org/",
            "bugs": {
              "url": "https://github.com/[org]/[packageName]/issues"
            },
            "license": [MIT|GPL|etc],
            "main": "index.js",
            "repository": {
              "type": "git",
              "url": "git+https://github.com/[org]/[packageName].git",
              "directory": "packages/[packageName]"
            },
            "engines": {
              "node": ">=0.10.0"
            },
            "dependencies": {
              [dependencyName]: [semanticVer],
            },
            "readme": [blurb],
            "_id": [_id],
            "_npmVersion": "6.4.1",
            "_nodeVersion": "10.14.2",
            "_npmUser": {
              "name": [handle],
              "email": [email]
            },
            "dist": {
              "integrity": [sha512],
              "shasum": [sha],
              "tarball": "https://registry.npmjs.org/[package]/-/[_id].tgz",
              "fileCount": [number],
              "unpackedSize": [number],
              "npm-signature": [PGP]
            },
            "maintainers": [
              {
                "email": [email],
                "name": [handle]
              },
            ],
            "_npmUser": {
              "name": [handle],
              "email": [email]
            },
            "directories": {},
            "_hasShrinkwrap": false
          }
        },
        "maintainers": [
          {
            "email": [email],
            "name": [handle]
          }
        ],
      "time": {
        "modified": [iso8601],
        "created": [iso8601],
        [version]: [iso8601]
      },
      "repository": {
        "type": "git",
        "url": "git+https://github.com/facebook/react.git",
        "directory": "packages/react"
      },
      "readme": [blurb],
      "readmeFilename": "README.md",
      "homepage": "https://xxx.org/",
      "keywords": [],
      "bugs": {
        "url": "https://github.com/xxx/xxx/issues"
      },
      "users": {
        [handle]: [true|false]
      },
      "license": [MIT|GPL|etc]
    }
    ```

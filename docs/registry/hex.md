# Hex

- Docs: `https://hexpm.docs.apiary.io`

- Available Info:

  - Dependencies: :heavy_check_mark:
  - Maintainers: :heavy_check_mark:
  - Repository: :heavy_check_mark:

- Sample Endpoint:

  - `https://hex.pm/api/packages/[packageName]`

    ```js
    {
      "docs_html_url": "https://hexdocs.pm/[packageName]/",
      "downloads": {
        "all": [number],
        "day": [number],
        "recent": [number],
        "week": [number]
      },
      "html_url": "https://hex.pm/packages/[packageName]",
      "inserted_at": [iso8601],
      "meta": {
        "description": [string],
        "licenses": [[string]],
        "links": {
          "github": "https://github.com/[org]/[packageName]"
        },
        "maintainers": []
      },
      "name": [packageName],
      "owners": [
        {
          "email": [email],
          "url": "https://hex.pm/api/users/[handle]",
          "username": [handle]
        }
      ],
      "releases": [
        {
          "has_docs": [true|false],
          "url": "https://hex.pm/api/packages/[packageName]/releases/[version]",
          "version": [version]
          }
      ],
      "repository": "hexpm",
      "retirements": {},
      "updated_at": [iso8601],
      "url": "https://hex.pm/api/packages/[packageName]"
    }
    ```

  - `https://hex.pm/api/packages/[packageName]/releases/[version]`

    ```js
    {
      "checksum": [hash],
      "docs_html_url": "https://hexdocs.pm/[packageName]/",
      "downloads": [number],
      "has_docs": [true|false],
      "html_url": "https://hex.pm/packages/[packageName]/[version]",
      "inserted_at": [iso8601],
      "meta": {},
      "package_url": "https://hex.pm/api/packages/[packageName]",
      "publisher": {
          "email": [email],
          "url": "https://hex.pm/api/users/[handle]",
          "username": [handle]
      },
      "requirements": {
          [dependencyName]: {
              "app": [dependencyName],
              "optional": [true|false],
              "requirement": [semanticVer]
          },
      },
      "retirement": [iso8601?],
      "updated_at": [iso8601],
      "url": "https://hex.pm/api/packages/[packageName]/releases/[version]",
      "version": [version]
    }
    ```

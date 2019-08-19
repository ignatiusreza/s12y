# RubyGems

- Docs: `https://guides.rubygems.org/rubygems-org-api/`
- Available Info:

  - Dependencies: :heavy_check_mark:
  - Maintainers: :heavy_check_mark:
  - Repository: :heavy_check_mark:

- Sample Endpoint:

  - `https://rubygems.org/api/v1/gems/[packageName]`

    ```js
    {
      "name": [packageName],
      "downloads": [number],
      "version": [version],
      "version_downloads": [number],
      "authors": [fullName],
      "info": [blurb],
      "project_uri": "http://rubygems.org/gems/[packageName]",
      "gem_uri": "http://rubygems.org/gems/[packageName]-[version].gem",
      "homepage_uri": [url],
      "wiki_uri": [url],
      "documentation_uri": [url],
      "mailing_list_uri": [url],
      "source_code_uri": [url],
      "bug_tracker_uri": [url],
      "dependencies": {
        "development": [],
        "runtime": [
          {
            "name": [name],
            "requirements": [semanticVer]
          }
        ]
      }
    }

    ```

  - `https://rubygems.org/api/v1/gems/[packageName]/owners`

    ```js
    [
      {
          "id": [id],
          "handle": [handle?],
          "email": [email]
      },
    ]
    ```

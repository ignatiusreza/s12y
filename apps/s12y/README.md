# S12y

Some applications under this monorepo depends on the database being up and running. To make sure that your database is up to date:

- Install dependencies with `mix deps.get`
- Create your development database `mix ecto.setup`
- Ensure that everything is working by running the test `mix test`

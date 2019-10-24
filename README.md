# Sustainability (s12y) - WIP / Highly Experimental

## Background

A project sustainability depends on not just the people directly working on it, but also on every single person maintaining the project's dependencies. Your project is only possible because so many people has put in the underlying works in place. Help them, help you, making your project sustainable.

## Goal

This project goal is to help bring the human side of open source forward. It does this by allowing you to upload your project configuration (e.g. `mix.exs`, `Gemfile`, `package.json`, etc), analyze it, and return the list of people who helps maintain your project dependencies.

Instead of thinking about "My project have X number of dependencies", think more like "My project is only possible because of the works put in by these number of people". This change in perspective will hopefully help us remember to set aside some time, funds, or effort to help those maintainers, which in the end will help us achieving overall sustainability.

## Technical Details

This project is an example of what some might call a monorepo. Under the apps folder, you'll find several different applications, each serving different purpose:

- [`apps/web`](./apps/web): the web stack, the main entry point on which user will interact, it house no business logic whatsoever
- [`apps/s12y`](./apps/s12y): the business logic, handle communication between apps, database persistence, etc,
- [`apps/parsers`](./apps/parsers): handle parsing user uploaded files
- [`apps/registries`](./apps/registries): handle looking up detailed information about each packages/dependencies found inside the configuration file, including nested and transient dependencies

The project is mainly developed using elixir, phoenix, and elm; but each parsers and registries are planned to be written in the native language under which the configuration file operate, e.g using `ruby` to parse `Gemfile` and `node` to parse `package.json`.

Check the `README.md` file under each applications to see further details of each parts.

## Contribution Welcome

This project is still in its very early stage, any and all contributions is highly appreciated.

Some example on areas you might be able to contribute:

- code review: I came from a Ruby on Rails and React background and was just learning elixir, phoenix, and elm; by the time this project started, as such, I have no idea whether the code written are typical on how these languages are usually written

- design: UI/UX are not really my strong point, if you're a designer or know a designer who's willing to help, by all means, send some help

- additional parsers & registries

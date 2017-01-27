#Running this project

These projects are wired up with hot module reloading using Webpack and Express middleware.

`yarn` or `npm install`

`node server.js`

Browse to:

http://localhost:4000/elm.html
http://localhost:4000/react.html

To see how you might add a feature check out these branches:

`elm-long-tasks`
`redux-long-tasks`

These TodoMVC implementations were borrowed from others and modified to include interacting with a HTTP API.

#Approach to web
##Virtual Dom
* Both have an efficient virtual DOM implementation - ‘nuff said.

##JSX and Elm’s Html module
* Functions instead of stateful components - Pure functions in Elm make it obvious what a view will need in order to render with no surprises.

##State management
* Elm - State is only changed as the result of an action
* Elm - One global state object
* Redux - One global state object (using nested reducers)
* React - State is per component (this.props, this.setState)

##JavaScript Interop
* Elm - Does not speak JavaScript - Instead has the concept of ports. Ports are bidirectional means of communicating between javascript and the Elm app.
* Elm - Received input via subscriptions - Keyboard, Mouse, Websockets
* React and Redux - Easy to interop with JavaScript libraries
* Both - Whether using ports or using JavaScript third party modules directly be very careful about how you manage their state. These components are usually unaware that they exist inside of a virtual dom. Therefore, their parent dom element could vanish without notice  causing potential memory leaks if any child dom nodes were wired with event handlers that weren’t removed along with the dom node. This is definitely a big issue with jQuery modules as it keeps a global list of event handlers.

#On the language

##Syntax
* React - Plain old javascript, who isn’t familiar with this language by now?
* Elm - Functional programming language with no remnants of JavaScript.

##Type system
* Refactoring is incredibly simple - change everything you want. If it compiles, it works.
* Can use Typescript / Flow - however, most usage seems to be just vanilla JavaScript

##Error handling
* Required in Elm but easy to subvert - requires intentional effort to ignore errors.
* JavaScript - Can easily forget to handle errors in callbacks or promise chains.

#Tooling

##IDE
* Elm - VS Code and Atom have decent plugins that are quickly evolving
* Elm - The type system allows for better tooling and refactoring support.
* React - Some good integration with ESLint and similar tools to help prevent obvious errors. Refactoring support is limited to using JavaScript in a way that can be statically analyzed.

##Package management (npm and Elm-package)
* All packages in an Elm project must agree on versions (can be a pain when trying to upgrade a package)
* Elm packages enforce SemVer; breaking changes require Major version.
* React - Upgrade at your own risk - maybe it will work maybe it won’t

##Package ecosystem
* One quadrillion* packages on npm of varying quality. (*number may not reflect reality)
* Elm package doesn’t allow native modules. This ensures code your app consumes is Pure and will not have unintended side-effects. How do you know if that NPM module you just pulled in isn’t sending private data?
* Fewer packages in Elm.
* Elm - Packages are outdated when the language upgrades, both good and bad
* Good for cleaning out the cruft and keeping a good set of up-to-date, maintained packages.
* Bad when new version of Elm is released, requires waiting for your dependencies to be updated. In practice, this usually takes a few days.
* So many choices - React + Redux + Redux Thunk + Axios
* React Saga, React Loop, Redux Promise, etc, etc

#Build toolchains (compiler, Webpack, ESLint)
* Elm - Amazing error messages.
* There is a standard for formatting and it’s aided by Elm-format - to some degree language upgrades can be performed simply by running Elm-format.

#Meta Stuff

##Long term maintenance
* Type system is a very good description of what’s possible Msg and Model are common type names that serve the same purpose in all projects.
* One standard way of architecting Elm projects (TEA), hasn’t changed in over a year.

##Community Involvement
* Elm-conf in STL
* Elm KC!
* Elm Slack

##Corporate sponsor
* NoRedInk (one guy)
* Facebook

##Developer productivity and onboarding
* Elm-format is awesome!
* Elm - Type systems help describe what’s possible
* React + Redux - Where do you start? The language is simple enough but there’s a lot of moving parts.


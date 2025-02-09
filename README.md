# FlowKit

Framework for building modular applications with composable flows.


## Why FlowKit?

The goal of FlowKit is to provide an easy-to-use infrastructure for building modular and composable applications, allowing you to break code into independent packages and build navigation flows and functionality in a modular and flexible way.

### Main advantages of a modular architecture are:

1. **Modularity**: Splitting into independent packages allows you to create separate modules that perform specific functions, making code management and maintenance easier.
2. **Code reusability**: Independent packages allow you to easily reuse specific parts of your application in different contexts or projects.
3. **Simplify development**: Working on smaller packages simplifies development by allowing different teams to work in parallel on separate modules.
4. **Testability**: Splitting the application into independent packages facilitates the creation of specific tests for each module, improving the overall quality of the software.
5. **Scalability**: The modular structure promotes the scalability of the application, allowing you to add new features or modify existing parts more easily.
6. **Dependency management**: Independent packages allow you to more efficiently manage dependencies between the various parts of the application, reducing the risk of conflicts or errors.
7. **Agility in development**: The division into independent packages promotes an agile approach to development, allowing changes to be made more quickly and with fewer impacts on the rest of the application.
8. **Compile times**: Splitting into independent packages reduces compilation times, allowing you to work more efficiently and productively.

### Main advantages of FlowKit are:

1. **Navigation**: A system that allows you to navigate between modules that are not sold to each other, in a transparent and flexible way, using either UIkit or SwiftUI navigation.
2. **Graph**: Each flow has its own navigation graph connected to the others through an enum, thus creating a complete map of the possible navigations that is easily readable.
3. **Enum-based pattern**: Using an enum-based pattern makes the logic easier to understand and test.
4. **Reuse pages and flows**: Makes pages reusable in different flows, speeding up the development of a flow and limiting code duplication.


## Using FlowKit

Using FlowKit is a simple process:

1. [Installation](./Documentation/Installation.md)
2. [Registration](./Documentation/Registration.md)
3. [Page](./Documentation/Page.md)
4. [Flow](./Documentation/Flow.md)
5. [Navigation](./Documentation/Navigation.md)
6. [Test](./Documentation/Test.md)


## Additional Resouces

* [API Documentation](https://gerardogrisolini.github.io/FlowKit/documentation/flowkit)


## Demo Application

I've made my [Example](https://github.com/gerardogrisolini/FlowKit-Example) repository public.


## Author

FlowKit was designed, implemented, documented, and maintained by [Gerardo Grisolini](https://www.linkedin.com/in/gerardo-grisolini-b5900248/), a Senior iOS engineer.
* Email: [gerardo.grisolini@gmail.com](mailto:gerardo.grisolini@gmail.com)


## License

FlowKit is available under the MIT license. See the LICENSE file for more info.


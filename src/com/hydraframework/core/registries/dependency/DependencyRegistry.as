/*
   HydraFramework - Copyright (c) 2012 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.registries.dependency {

    import com.hydraframework.core.HydraFramework;
    import com.hydraframework.core.registries.dependency.descriptor.Dependency;
    import com.hydraframework.core.registries.dependency.interfaces.IDependency;
    import com.hydraframework.core.utils.ClassUtils;

    import flash.utils.getQualifiedClassName;

    public class DependencyRegistry {

        private static const _instance:DependencyRegistry = new DependencyRegistry();

        public static function getInstance():DependencyRegistry {
            return _instance;
        }

        public static function get instance():DependencyRegistry {
            return _instance;
        }

        private var dependencyMap:Array;

        public function DependencyRegistry() {
            super();
            dependencyMap = [];
        }

        /**
         * Registers a dependency.
         *
         * @param interfaceClass Interface class to which the concrete dependency is registered
         * @param concreteClass Concrete implementation being registerd to the interfaceClass
         * @return void
         */
        public function registerDependency(interfaceClass:Class, concreteClass:Class):void {
            var dependency:Dependency = new Dependency(interfaceClass, concreteClass);
            dependencyMap[dependency.interfaceQualifiedClassName] = dependency;
            HydraFramework.log(HydraFramework.DEBUG_SHOW_INFO, "<HydraFramework> Registering dependency: ", dependency.interfaceQualifiedClassName, " <-> ", dependency.concreteQualifiedClassName);
        }

        /**
         * Registers a dependency provider
         *
         * @param interfaceClass Interface class to which dependency provider is registered
         * @param provider Function called upon request of the supplied interfaceClass
         * @return void
         */
        public function registerDependencyProvider(interfaceClass:Class, provider:Function):void {
            var dependency:Dependency = Dependency.CreateProvider(interfaceClass, provider);
            dependencyMap[dependency.interfaceQualifiedClassName] = dependency;
            HydraFramework.log(HydraFramework.DEBUG_SHOW_INFO, "<HydraFramework> Registering dependency provider: ", dependency.interfaceQualifiedClassName, " <-> ", dependency.provider.toString(), "()");
        }

        /**
         * Retrieves the dependency that implements dependencyInterface.
         *
         * @param interfaceClass Interface for which to retrieve a dependency
         * @return Object
         */
        public function retrieveDependency(interfaceClass:Class):Object {
            var dependencyInterfaceClassName:String = getQualifiedClassName(dependencyInterface),
                dependency:Dependency = dependencyMap[dependencyInterfaceClassName];

            if (dependency === null || dependency === undefined) {
                throw new Error("Dependency does not exist for interface '" + dependencyInterfaceClassName + "'");
            }

            if (dependency.hasProvider) {
                var providerDependency:Object = dependency.provider();
                if (!(providerDependency is dependency.interfaceClass)) {
                    throw new Error("Dependency provided for '" + dependency.interfaceQualifiedClassName + "' was not a proper implementation!");
                }
                return providerDependency;
            }

            return new (dependency.concreteClass as Class)();
        }

        /**
         * Removes a specific dependency.
         *
         * @param concreteClass Remove dependency
         * @return void
         */
        public function removeDependency(concreteClass:Class):void {
            var concreteClassName:String = getQualifiedClassName(interfaceClass),
                interfaceClassName:String,
                currentDependency:IDependency;

            for (interfaceClassName in dependencyMap) {
                currentDependency = dependencyMap[interfaceClassName];
                if (currentDependency !== null && currentDependency !== undefined && currentDependency.concreteQualifiedClassName === concreteClassName) {
                    delete dependencyMap[interfaceClassName];
                    HydraFramework.log(HydraFramework.DEBUG_SHOW_INFO, "<HydraFramework> Removing dependency:", interfaceClassName);
                    break;
                }
            }
        }

        /**
         * Removes registered dependency for specified interface.
         *
         * @param interfaceClass Interface for which to remove a dependency
         * @return void
         */
        public function removeDependencyByInterface(interfaceClass:Class):void {
            var interfaceClassName:String = getQualifiedClassName(interfaceClass);
            delete dependencyMap[interfaceClassName];
            HydraFramework.log(HydraFramework.DEBUG_SHOW_INFO, "<HydraFramework> Removing dependency by Interface:", interfaceClassName);
        }

        /**
         * Completely removes all registered dependencies.
         *
         * @return void
         */
        public function removeAll():void {
            var s:String;
            for (s in dependencyMap) {
                delete dependencyMap[s];
            }
        }
    }
}

package com.hydraframework.core.registries.dependency.descriptor {

    import com.hydraframework.core.registries.dependency.interfaces.IDependency;

    import flash.utils.getQualifiedClassName;

    public class Dependency extends Object implements IDependency {

        /**
         * Properties
         */
        private var _interfaceClass:Class;

        public function set interfaceClass(value:Class):void {
            _interfaceClass = value;
        }

        public function get interfaceClass():Class {
            return _interfaceClass;
        }

        private var _concreteClass:Class;

        public function set concreteClass(value:Class):void {
            _concreteClass = value;
        }

        public function get concreteClass():Class {
            return _concreteClass;
        }

        private var _provider:Function;

        public function set provider(value:Function):void {
            _provider = value;
        }

        public function get provider():Function {
            return _provider;
        }


        public function get interfaceQualifiedClassName():String {
            return _interfaceClass !== null ? getQualifiedClassName(_interfaceClass) : null;
        }

        public function get concreteQualifiedClassName():String {
            return _concreteClass !== null ? getQualifiedClassName(_concreteClass) : null;
        }

        public function get hasProvider():Boolean {
            return _provider !== null;
        }

        /**
         * Ctor
         */

        /**
         * More expressive syntax for creating dependency providers
         * @param interfaceClass Interface class the provider for which the provider is registered
         * @param concereteClass Implementation to be instantiated when the interfaceClass is requested
         * @param provider Function to be executed upon instantation of the provided interface Class; When supplied, the 'concreteClass' parameter is ignored.
         */
        public function Dependency(interfaceClass:Class, concreteClass:Class = null, provider:Function = null) {
            super();
            if (concreteClass === null && provider === null) {
                throw new Error("A concerete class or provider function is required for interface: '" + interfaceQualifiedClassName + "'");
            }
            _interfaceClass = interfaceClass;
            _concreteClass = concreteClass;
            _provider = provider;
        }

        /**
         * More expressive syntax for creating dependency providers
         * @param interfaceClass Interface class the provider for which the provider is registered
         * @param provider Function to be executed upon instantation of the provided interface Class
         * @return Appropriately constructed dependency provider
         */
        public static function CreateProvider(interfaceClass:Class, provider:Function):IDependency {
            return new Dependency(interfaceClass, null, provider);
        }

    }
}

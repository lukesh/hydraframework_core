package com.hydraframework.core.registries.dependency.interfaces {

    public interface IDependency {
        /**
         * Interface for which the concrete or provider dependency is registered
         */
        function set interfaceClass(value:Class):void;
        function get interfaceClass():Class;

        /**
         * Concrete implementation to be instantiated for the interfaceClass
         */
        function set concreteClass(value:Class):void;
        function get concreteClass():Class;

        /**
         * Function called for retrieval of the dependency instead of the concrete
         * implementation. If set, the concrete implementation is ignored.
         *
         * This allows for application-level instantation control.
         */
        function set provider(value:Function):void;
        function get provider():Function;

        function get interfaceQualifiedClassName():String;
        function get concreteQualifiedClassName():String;
        function get hasProvider():Boolean;
    }
}

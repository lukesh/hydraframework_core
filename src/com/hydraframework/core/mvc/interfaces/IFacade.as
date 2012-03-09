/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.mvc.interfaces {

    public interface IFacade extends IRelay {

        ////////////////////////////////////////////////////////////////////
        //
        // Commands
        // 
        ////////////////////////////////////////////////////////////////////

        /**
         * Registers a command with the core. The command will run when the
         * Facade encounters a notification with name specified by
         * notificationName.
         *
         * @param notificationName
         * @param command
         * @return void
         */
        function registerCommand(notificationName:String, command:Class):void;
        /**
         * Retrieves a specific command by the notification name it is
         * registered with.
         *
         * @param notificationName
         * @param commandName
         * @return ICommand
         */
        function retrieveCommand(notificationName:String, commandName:String):ICommand;
        /**
         * Retrieves a list of commands registered (mapped) to a notification
         * name.
         *
         * @param String
         */
        function retrieveCommandList(notificationName:String):Array;
        /**
         * Removes a specific command.
         *
         * @param notificationName
         * @param command
         * @return void
         */
        function removeCommand(notificationName:String, command:Class):void;

        ////////////////////////////////////////////////////////////////////
        //
        // Mediators
        // 
        ////////////////////////////////////////////////////////////////////

        /**
         * Registers a Mediator with the core.
         *
         * @param mediator
         * @return void
         */
        function registerMediator(mediator:IMediator):void;
        /**
         * Returns a registered Mediator by name.
         *
         * @param mediatorName
         * @return IMediator
         */
        function retrieveMediator(mediatorName:String):IMediator;
        /**
         * Removes a registered Mediator by name.
         *
         * @param mediatorName
         * @return void
         */
        function removeMediator(mediatorName:String):void;

        ////////////////////////////////////////////////////////////////////
        //
        // Proxies
        // 
        ////////////////////////////////////////////////////////////////////

        /**
         * Registers a Proxy with the core.
         *
         * @param proxy
         * @return void
         */
        function registerProxy(proxy:IProxy):void;
        /**
         * Returns a registered Proxy by name.
         *
         * @param proxyName
         * @return IProxy
         */
        function retrieveProxy(proxyName:String):IProxy;
        /**
         * Removes a registered Proxy by name.
         *
         * @param proxyName
         * @return IProxy
         */
        function removeProxy(proxyName:String):void;

        ////////////////////////////////////////////////////////////////////
        //
        // Plugins
        // 
        ////////////////////////////////////////////////////////////////////

        /**
         * Registers a IPlugin with the core.
         *
         * @param plugin
         * @return void
         */
        function registerPlugin(plugin:IPlugin):void;
        /**
         * Returns a registered Plugin by name.
         *
         * @param pluginName
         * @return IPlugin
         */
        function retrievePlugin(pluginName:String):IPlugin;
        /**
         * Removes a registered Plugin by name.
         *
         * @param pluginName
         * @return void
         */
        function removePlugin(pluginName:String):void;

        ////////////////////////////////////////////////////////////////////
        //
        // Delegates
        // 
        ////////////////////////////////////////////////////////////////////

        /**
         * Registers a delegate with the core.
         *
         * @param delegate
         * @param registerGlobal
         * @return void
         */
        function registerDelegate(delegate:Class, registerGlobal:Boolean = false):void;
        /**
         * Retrieves the delegate that implements delegateInterface.
         *
         * @param delegateInterface
         * @param forceRetrieveLocal
         * @return Object
         */
        function retrieveDelegate(delegateInterface:Class, forceRetrieveLocal:Boolean = false):Object;
        /**
         * Removes a specific delegate.
         *
         * @param delegate
         * @param removeGlobal
         * @return void
         */
        function removeDelegate(delegate:Class, removeGlobal:Boolean = false):void;
        /**
         * Removes all registered delegates for specified interface.
         *
         * @param delegateInterface
         * @param removeGlobal
         * @return void
         */
        function removeDelegatesByInterface(delegateInterface:Class, removeGlobal:Boolean = false):void;

        ////////////////////////////////////////////////////////////////////
        //
        // General Dependency Injection
        // 
        ////////////////////////////////////////////////////////////////////

        /**
         * Registers a dependency with the core.
         *
         * @param interfaceClass Interface class to which dependency is registered
         * @param concreteClass Concrete implementation being registerd to the interfaceClass
         * @param registerGlobal
         * @return void
         */
        function registerDependency(interfaceClass:Class, concreteClass:Class, registerGlobal:Boolean = false):void;
        /**
         * Registers a dependency provider with the core.
         *
         * @param interfaceClass Interface class to which dependency provider is registered
         * @param provider Function called upon request of the supplied interfaceClass
         * @param registerGlobal
         * @return void
         */
        function registerDependencyProvider(interfaceClass:Class, provider:Function, registerGlobal:Boolean = false):void;
        /**
         * Retrieves the dependency that implements dependencyInterface.
         *
         * @param interfaceClass Interface for which to retrieve a dependency
         * @param forceRetrieveLocal
         * @return Object
         */
        function retrieveDependency(interfaceClass:Class, forceRetrieveLocal:Boolean = false):Object;
        /**
         * Removes a specific dependency.
         *
         * @param concreteClass Removes this dependency from the registry
         * @param removeGlobal
         * @return void
         */
        function removeDependency(concreteClass:Class, removeGlobal:Boolean = false):void;
        /**
         * Removes all registered dependencies for specified interface.
         *
         * @param interfaceClass Interface for which to remove a dependency
         * @param removeGlobal
         * @return void
         */
        function removeDependencyByInterface(interfaceClass:Class, removeGlobal:Boolean = false):void;

        ////////////////////////////////////////////////////////////////////
        //
        // Core
        // 
        ////////////////////////////////////////////////////////////////////

        /**
         * Override this method to register individual MVC actors with the
         * Facade. This is where you will call your register[Relay]() methods.
         * The order of their registration is not important.
         */
        function registerCore():void;
        /**
         * Override this method to execute specific functionality when the
         * core is remove from the system. Events should be removed
         * automatically, so garbage collection should handle the disposal of
         * objects, however if you need to explicitly unregister things, do it
         * here.
         */
        function removeCore():void;
    }
}

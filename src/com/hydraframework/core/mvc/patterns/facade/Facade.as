/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.mvc.patterns.facade {

    import com.hydraframework.core.HydraFramework;
    import com.hydraframework.core.hydraframework_internal;
    import com.hydraframework.core.mvc.events.Notification;
    import com.hydraframework.core.mvc.interfaces.ICommand;
    import com.hydraframework.core.mvc.interfaces.IFacade;
    import com.hydraframework.core.mvc.interfaces.IMediator;
    import com.hydraframework.core.mvc.interfaces.IPlugin;
    import com.hydraframework.core.mvc.interfaces.IProxy;
    import com.hydraframework.core.mvc.interfaces.IRelay;
    import com.hydraframework.core.mvc.patterns.command.SimpleCommand;
    import com.hydraframework.core.mvc.patterns.mediator.Mediator;
    import com.hydraframework.core.mvc.patterns.plugin.Plugin;
    import com.hydraframework.core.mvc.patterns.proxy.Proxy;
    import com.hydraframework.core.mvc.patterns.relay.Relay;
    import com.hydraframework.core.registries.delegate.DelegateRegistry;
    import com.hydraframework.core.registries.dependency.DependencyRegistry;

    import flash.events.Event;
    import flash.events.EventPhase;
    import flash.utils.getQualifiedClassName;

    import mx.core.IUIComponent;
    import mx.events.FlexEvent;

    //import nl.demonsters.debugger.MonsterDebugger;

    use namespace hydraframework_internal;

    public class Facade extends Relay implements IFacade {

        public static const REGISTER:String = "Facade.register";
        public static const REMOVE:String   = "Facade.remove";

        private var dependencyRegistry:DependencyRegistry;
        private var commandMap:Array;
        private var mediatorMap:Array;
        private var proxyMap:Array;
        private var pluginMap:Array;
        private var delegateRegistry:DelegateRegistry;

        //private var debugger:MonsterDebugger;

        public function Facade(name:String = null, component:IUIComponent = null) {
            super();
            //debugger = new MonsterDebugger(this);
            this.setName(name);
            this.setComponent(component);

            /*
               If the facade is bound to a component, it will automatically
               call initialize() when that component gets created.
             */
            if (component) {
                component.addEventListener(FlexEvent.CREATION_COMPLETE, handleRegister, false, 20, true);
            }
        }

        /**
         * Handles Notification type events. Override this method to add logic
         * for notifications that are sent throughout the MVC triad. Remember
         * to call super.handleNotification(notification).
         *
         * @param	Notification
         * @return	void
         */
        override hydraframework_internal function __handleNotification(notification:Notification):void {
            super.__handleNotification(notification);

            HydraFramework.log(HydraFramework.DEBUG_SHOW_INTERNALS, "----- <HydraFramework> Facade.hydraframwork_internal::__handleNotification", this, notification.target, "at target:", this == notification.
                               target, notification.eventPhase, " -- ", notification.name);
            /*
               If the event's target is the Facade, and it has reached its target,
               execute the command.
             */
            if (Event(notification).target == this && Event(notification).eventPhase == EventPhase.AT_TARGET) {
                var commandList:Array = this.retrieveCommandList(notification.name);
                var command:ICommand;

                for (var s:String in commandList) {
                    command = ICommand(new (commandList[s] as Class)(this));
                    if (command is SimpleCommand) {
                        SimpleCommand(command).hydraframework_internal::__execute(notification);
                    } else {
                        command.execute(notification);
                    }
                }
            } else {
                /*
                   Otherwise, distribute the event to the other actors.
                 */
                this.sendNotification(notification);

                /*
                   This handles Notification bubbling.

                   If the Facade is bound to a component, and the source
                   (target) of the event isn't the component itself, tell the
                   component to dispatch the event--this will allow it to bubble
                   to parent DisplayObjects.
                 */
                if (this.component && Event(notification).target != this.component && Event(notification).eventPhase == 2 && Event(notification).bubbles) {
                    Event(notification).stopImmediatePropagation();
                    this.component.dispatchEvent(Event(notification));
                }
            }
        }

        /**
         * @private
         *
         * This is key to the entire system. Relays respond to Notifications
         * to initialize(), dispose(), and subsequently handle other MVC
         * logic.
         */
        private function registerRelayEvents(relay:IRelay, priority:int = 0):void {
            HydraFramework.log(HydraFramework.DEBUG_SHOW_INTERNALS, "----- <HydraFramework> Relay.registerRelayEvents", this, "is version:", Relay(relay).getVersion());
            if (relay.getVersion() == HydraFramework.VERSION) {
                this.addEventListener(Notification.TYPE, Relay(relay).hydraframework_internal::__handleNotification, false, priority, true);
                relay.addEventListener(Notification.TYPE, this.hydraframework_internal::__handleNotification, false, priority, true);
            } else {
                this.addEventListener(Notification.TYPE, relay.handleNotification, false, priority, true);
                relay.addEventListener(Notification.TYPE, handleNotification, false, priority, true);
            }
        }

        /**
         * @private
         */
        private function removeRelayEvents(relay:IRelay):void {
            HydraFramework.log(HydraFramework.DEBUG_SHOW_INTERNALS, "----- <HydraFramework> Relay.removeRelayEvents", this, "is version:", Relay(relay).getVersion());
            if (relay.getVersion() == HydraFramework.VERSION) {
                this.removeEventListener(Notification.TYPE, Relay(relay).hydraframework_internal::__handleNotification, false);
                relay.removeEventListener(Notification.TYPE, this.hydraframework_internal::__handleNotification, false);
            } else {
                this.removeEventListener(Notification.TYPE, relay.handleNotification, false);
                relay.removeEventListener(Notification.TYPE, handleNotification, false);
            }
        }

        /**
         * @private
         */
        override protected function attachEventListeners():void {
            super.attachEventListeners();
            this.addEventListener(Notification.TYPE, this.hydraframework_internal::__handleNotification, false, 0, true);
            var s:String;

            for (s in mediatorMap) {
                registerRelayEvents(mediatorMap[s] as IRelay, 10);
            }

            for (s in proxyMap) {
                registerRelayEvents(proxyMap[s] as IRelay, 0);
            }

            for (s in pluginMap) {
                registerRelayEvents(pluginMap[s] as IRelay, 20);
            }

            if (component) {
                /*
                   Use capture to form an "event diode" of sorts.
                 */
                component.addEventListener(Notification.TYPE, this.hydraframework_internal::__handleNotification, true, 0, true);
                /*
                   If the Facade is bound to a component, automatically
                   initialize() and dispose() as the component is added and
                   removed fromt the display list.
                 */
                component.addEventListener(FlexEvent.ADD, handleRegister, false, 20, true);
                component.addEventListener(FlexEvent.REMOVE, handleRemove, false, 0, true);
            }
        }

        /**
         * @private
         */
        override protected function removeEventListeners():void {
            super.removeEventListeners();
            this.removeEventListener(Notification.TYPE, this.hydraframework_internal::__handleNotification, false);
            var s:String;

            for (s in mediatorMap) {
                removeRelayEvents(mediatorMap[s] as IRelay);
            }

            for (s in proxyMap) {
                removeRelayEvents(proxyMap[s] as IRelay);
            }

            for (s in pluginMap) {
                removeRelayEvents(pluginMap[s] as IRelay);
            }

            if (component) {
                component.removeEventListener(Notification.TYPE, this.hydraframework_internal::__handleNotification, true);
                component.removeEventListener(FlexEvent.REMOVE, handleRemove, false);
            }
        }

        override hydraframework_internal function __initialize(notificationName:String = null):void {
            if (initialized)
                return;

            HydraFramework.log(HydraFramework.DEBUG_SHOW_INTERNALS, "----- <HydraFramework> Facade.hydraframework_internal::__initialize", this, "INITIALIZED:", initialized);

            //MonsterDebugger.trace(this, "Facade.initialize()");
            //trace("Facade.initialize()", this);
            dependencyRegistry = new DependencyRegistry();
            commandMap = [];
            mediatorMap = [];
            proxyMap = [];
            pluginMap = [];
            delegateRegistry = new DelegateRegistry();
            /*
               Register Relays with the Facade.
             */
            this.hydraframework_internal::__registerCore();
            /*
               Bind Relay events to each actor.
             */
            super.__initialize();
            /*
               Relays should listen for this Notification and initialize()
             */
            this.sendNotification(new Notification(notificationName || Facade.REGISTER, this));
        }

        override hydraframework_internal function __dispose(notificationName:String = null):void {
            if (!initialized)
                return;
            //MonsterDebugger.trace(this, "Facade.dispose()");
            //trace("Facade.dispose()", this);
            /*
               Relays should listen for this Notification and dispose()
             */
            this.sendNotification(new Notification(notificationName || Facade.REMOVE, this));
            var s:String;
            super.__dispose();
            this.hydraframework_internal::__removeCore();

            dependencyRegistry.removeAll();
            delegateRegistry.removeAll();

            for (s in pluginMap) {
                removePlugin(s);
            }

            for (s in proxyMap) {
                removeProxy(s);
            }

            for (s in mediatorMap) {
                removeMediator(s);
            }

            for (s in commandMap) {
                delete commandMap[s];
            }

        }

        /*
           -----------------------------------------------------------------------
            GENERAL DEPENDENCY REGISTRATION
           -----------------------------------------------------------------------
        */ //

        public function registerDependency(interfaceClass:Class, concreteClass:Class, registerGlobal:Boolean = false):void {
            if (registerGlobal) {
                DependencyRegistry.getInstance().registerDependency(interfaceClass, concreteClass);
            } else {
                dependencyRegistry.registerDependency(interfaceClass, concreteClass);
            }
        }

        public function registerDependencyProvider(interfaceClass:Class, provider:Function, registerGlobal:Boolean = false):void {
            if (registerGlobal) {
                DependencyRegistry.getInstance().registerDependencyProvider(interfaceClass, provider);
            } else {
                dependencyRegistry.registerDependencyProvider(interfaceClass, provider);
            }
        }

        public function retrieveDependency(interfaceClass:Class, forceRetrieveLocal:Boolean = false):Object {
            var dependency:Object;
            /*
            This code could be simplified attempting to retrieve the globally registered delegate first,
            and if that were null OR forceRetrieveLocal == true, attempt to return the local one. However,
            this would always require two lookups in requests where forceRetrieveLocal == true.
            */
            if (forceRetrieveLocal) {
                dependency = dependencyRegistry.retrieveDependency(interfaceClass);
            } else {
                dependency = DependencyRegistry.getInstance().retrieveDependency(interfaceClass);
                if (!dependency) {
                    dependency = dependencyRegistry.retrieveDependency(interfaceClass);
                }
            }
            return dependency;
        }

        public function removeDependency(concreteClass:Class, removeGlobal:Boolean = false):void {
            if (removeGlobal) {
                DependencyRegistry.getInstance().removeDependency(concreteClass);
            } else {
                dependencyRegistry.removeDependency(concreteClass);
            }
        }

        public function removeDependencyByInterface(interfaceClass:Class, removeGlobal:Boolean = false):void {
            if (removeGlobal) {
                DependencyRegistry.getInstance().removeDependencyByInterface(interfaceClass);
            } else {
                dependencyRegistry.removeDependencyByInterface(interfaceClass);
            }
        }

        /*
           -----------------------------------------------------------------------
           COMMANDS
           -----------------------------------------------------------------------
         */ //

        public function registerCommand(notificationName:String, command:Class):void {
            var commandClass:String = getQualifiedClassName(command);

            if (!commandMap[notificationName])
                commandMap[notificationName] = [];
            commandMap[notificationName][commandClass] = command;
            HydraFramework.log(HydraFramework.DEBUG_SHOW_INFO, "<HydraFramework> Registering command:", notificationName, "->", commandClass);
        }

        public function retrieveCommand(notificationName:String, commandClass:String):ICommand {
            var commandList:Array = retrieveCommandList(notificationName);
            return commandList ? new (commandList[commandClass] as Class)() as ICommand : null;
        }

        public function retrieveCommandList(notificationName:String):Array {
            return commandMap[notificationName];
        }

        public function removeCommand(notificationName:String, command:Class):void {
            var commandClass:String = getQualifiedClassName(command);

            if (commandMap[notificationName]) {
                delete commandMap[notificationName][commandClass];
            }

            HydraFramework.log(HydraFramework.DEBUG_SHOW_INFO, "<HydraFramework> Removing command:", notificationName, "->", commandClass);
        }

        /*
           -----------------------------------------------------------------------
           MEDIATORS
           -----------------------------------------------------------------------
         */ //

        public function registerMediator(mediator:IMediator):void {
            if (mediatorMap[mediator.getName()]) {
                HydraFramework.log(HydraFramework.DEBUG_SHOW_WARNINGS, "*** WARNING *** Mediator '" + mediator.getName() + "' already registered with Facade '" + this.getName() + "'; aborting registration.");
            } else {
                mediatorMap[mediator.getName()] = mediator;
                mediator.setFacade(this);

                if (this.initialized) {
                    registerRelayEvents(mediator as IRelay);
                    this.sendNotification(new Notification(Mediator.REGISTER, mediator as IRelay));
                }
            }
        }

        public function retrieveMediator(mediatorName:String):IMediator {
            return mediatorMap[mediatorName] as IMediator;
        }

        public function removeMediator(mediatorName:String):void {
            var relay:IRelay = retrieveMediator(mediatorName) as IRelay;

            if (!relay)
                return;
            this.sendNotification(new Notification(Mediator.REMOVE, relay));
            delete mediatorMap[relay.getName()];
            relay.setFacade(null);
            removeRelayEvents(relay);
        }

        /*
           -----------------------------------------------------------------------
           PROXIES
           -----------------------------------------------------------------------
         */ //

        public function registerProxy(proxy:IProxy):void {
            if (proxyMap[proxy.getName()]) {
                HydraFramework.log(HydraFramework.DEBUG_SHOW_WARNINGS, "*** WARNING *** Proxy '" + proxy.getName() + "' already registered with Facade '" + this.getName() + "'; aborting registration.");
            } else {
                proxyMap[proxy.getName()] = proxy;
                proxy.setFacade(this);

                HydraFramework.log(HydraFramework.DEBUG_SHOW_INFO, "<HydraFramework> Registering proxy:", proxy.getName());

                if (this.initialized) {
                    registerRelayEvents(proxy as IRelay);
                    if (proxy.getVersion() == HydraFramework.VERSION) {
                        Relay(proxy).hydraframework_internal::__initialize();
                    } else {
                        proxy.initialize();
                    }
                    this.sendNotification(new Notification(Proxy.REGISTER, proxy as IRelay));
                }
            }
        }

        public function retrieveProxy(proxyName:String):IProxy {
            return proxyMap[proxyName] as IProxy;
        }

        public function removeProxy(proxyName:String):void {
            var relay:IRelay = retrieveProxy(proxyName) as IRelay;

            if (!relay)
                return;
            this.sendNotification(new Notification(Proxy.REMOVE, relay));
            if (relay.getVersion() == HydraFramework.VERSION) {
                Relay(relay).hydraframework_internal::__dispose();
            } else {
                relay.dispose();
            }
            delete proxyMap[relay.getName()];
            relay.setFacade(null);
            removeRelayEvents(relay);
        }

        /*
           -----------------------------------------------------------------------
           GENERIC RELAYS (PLUGINS)
           -----------------------------------------------------------------------
         */ //

        public function registerPlugin(plugin:IPlugin):void {
            // Only one instance of a plugin can be registered.
            if (retrievePlugin(plugin.getName())) {
                return;
            }
            pluginMap[plugin.getName()] = plugin;
            plugin.setFacade(this);

            if (this.initialized) {
                registerRelayEvents(plugin as IRelay);
                plugin.preinitialize();
                if (plugin.getVersion() == HydraFramework.VERSION) {
                    Relay(plugin).hydraframework_internal::__initialize();
                } else {
                    plugin.initialize();
                }
                this.sendNotification(new Notification(Plugin.REGISTER, plugin as IRelay));
            } else {
                plugin.preinitialize();
            }
        }

        public function retrievePlugin(pluginName:String):IPlugin {
            return pluginMap[pluginName] as IPlugin;
        }

        public function removePlugin(pluginName:String):void {
            var relay:IRelay = retrievePlugin(pluginName) as IRelay;

            if (!relay)
                return;
            this.sendNotification(new Notification(Plugin.REMOVE, relay));
            if (relay.getVersion() == HydraFramework.VERSION) {
                Relay(relay).hydraframework_internal::__dispose();
            } else {
                relay.dispose();
            }
            delete pluginMap[relay.getName()];
            relay.setFacade(null);
            removeRelayEvents(relay);
        }

        /*
           -----------------------------------------------------------------------
           DELEGATES
           -----------------------------------------------------------------------
         */ //

        public function registerDelegate(delegate:Class, registerGlobal:Boolean = false):void {
            if (registerGlobal) {
                DelegateRegistry.getInstance().registerDelegate(delegate);
            } else {
                delegateRegistry.registerDelegate(delegate);
            }
        }

        public function retrieveDelegate(delegateInterface:Class, forceRetrieveLocal:Boolean = false):Object {
            var delegate:Object;
            /*
               This code could be simplified attempting to retrieve the globally registered delegate first,
               and if that were null OR forceRetrieveLocal == true, attempt to return the local one. However,
               this would always require two lookups in requests where forceRetrieveLocal == true.
             */
            if (forceRetrieveLocal) {
                delegate = delegateRegistry.retrieveDelegate(delegateInterface);
            } else {
                delegate = DelegateRegistry.getInstance().retrieveDelegate(delegateInterface);
                if (!delegate) {
                    delegate = delegateRegistry.retrieveDelegate(delegateInterface);
                }
            }
            return delegate;
        }

        public function removeDelegate(delegate:Class, removeGlobal:Boolean = false):void {
            if (removeGlobal) {
                DelegateRegistry.getInstance().removeDelegate(delegate);
            } else {
                delegateRegistry.removeDelegate(delegate);
            }
        }

        public function removeDelegatesByInterface(delegateInterface:Class, removeGlobal:Boolean = false):void {
            if (removeGlobal) {
                DelegateRegistry.getInstance().removeDelegatesByInterface(delegateInterface);
            } else {
                delegateRegistry.removeDelegatesByInterface(delegateInterface);
            }
        }

        /*
           -----------------------------------------------------------------------
           CORE
           -----------------------------------------------------------------------
         */ //

        /**
         * @private
         */
        hydraframework_internal function __registerCore():void {
            registerCore();
        }

        public function registerCore():void {
        }

        hydraframework_internal function __removeCore():void {
            removeCore();
        }

        public function removeCore():void {
        }
    }
}

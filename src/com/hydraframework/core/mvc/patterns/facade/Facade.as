/*
   HydraFramework - Copyright (c) 2010 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.mvc.patterns.facade {
	import com.hydraframework.core.HydraFramework;
	import com.hydraframework.core.HydraEventMap;
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
	
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;

	//import nl.demonsters.debugger.MonsterDebugger;

	use namespace hydraframework_internal;

	public class Facade extends Relay implements IFacade {
		public static const REGISTER : String = "Facade.register";
		public static const REMOVE : String = "Facade.remove";
		private var commandMap : Array;
		private var mediatorMap : Array;
		private var proxyMap : Array;
		private var pluginMap : Array;
		private var delegateRegistry : DelegateRegistry;
		private var eventMap : HydraEventMap;
		
		//private var debugger:MonsterDebugger;

		/*
		   ...rest is a compatibility feature. Ultimately, we'd like this:
		   component : IEventDispatcher = null, eventMap : HydraEventMap = null
		   however this would explode compatibility with previous versions,
		   and AS3 does not support overloading.
		 */
		public function Facade(...rest) {
			super();
			if (rest.length > 0) {
				if (rest[0] is Array) {
					rest = rest[0];
				}
				if (rest[0] is String) {
					this.setName(String(rest[0]));
				} else if (rest[0] is IEventDispatcher) {
					this.setComponent(IEventDispatcher(rest[0]));
				}
			}
			if (rest.length > 1) {
				if (rest[1] is IEventDispatcher) {
					this.setComponent(IEventDispatcher(rest[1]));
				} else if (rest[1] is HydraEventMap) {
					this.eventMap = HydraEventMap(rest[1]).clone();
				}
			}
			if (this.eventMap == null) {
				this.eventMap = HydraFramework.defaultEventMap.clone()
			}
			
			//debugger = new MonsterDebugger(this);
			
			/*
			   If the facade is bound to a component, it will automatically
			   call initialize() when that component gets created.
			 */
			if (component) {
				eventMap.registerInitializeCoreEvents(component, handleRegister, true);
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
		override hydraframework_internal function __handleNotification(notification : Notification) : void {
			super.__handleNotification(notification);

			HydraFramework.log(HydraFramework.DEBUG_SHOW_INTERNALS, "----- <HydraFramework> Facade.hydraframwork_internal::__handleNotification", this, notification.target, "at target:", this == notification.target,
				notification.eventPhase, " -- ", notification.name);
			/*
			   If the event's target is the Facade, and it has reached its target,
			   execute the command.
			 */
			if (Event(notification).target == this && Event(notification).eventPhase == EventPhase.AT_TARGET) {
				var commandList : Array = this.retrieveCommandList(notification.name);
				var command : ICommand;

				for (var s : String in commandList) {
					command = ICommand(new(commandList[s] as Class)(this));
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
		private function registerRelayEvents(relay : IRelay, priority : int = 0) : void {
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
		private function removeRelayEvents(relay : IRelay) : void {
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
		override protected function attachEventListeners() : void {
			super.attachEventListeners();
			this.addEventListener(Notification.TYPE, this.hydraframework_internal::__handleNotification, false, 0, true);
			var s : String;

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
				eventMap.registerInitializeCoreEvents(component, handleRegister, false);
				eventMap.registerDisposeCoreEvents(component, handleRemove);
			}
		}

		/**
		 * @private
		 */
		override protected function removeEventListeners() : void {
			super.removeEventListeners();
			this.removeEventListener(Notification.TYPE, this.hydraframework_internal::__handleNotification, false);
			var s : String;

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
				eventMap.removeDisposeCoreEvents(component, handleRemove);
			}
		}

		override hydraframework_internal function __initialize(notificationName : String = null) : void {
			if (initialized)
				return;

			HydraFramework.log(HydraFramework.DEBUG_SHOW_INTERNALS, "----- <HydraFramework> Facade.hydraframework_internal::__initialize", this, "INITIALIZED:", initialized);

			//MonsterDebugger.trace(this, "Facade.initialize()");
			//trace("Facade.initialize()", this);
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

		override hydraframework_internal function __dispose(notificationName : String = null) : void {
			if (!initialized)
				return;
			//MonsterDebugger.trace(this, "Facade.dispose()");
			//trace("Facade.dispose()", this);
			/*
			   Relays should listen for this Notification and dispose()
			 */
			this.sendNotification(new Notification(notificationName || Facade.REMOVE, this));
			var s : String;
			super.__dispose();
			this.hydraframework_internal::__removeCore();

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
		   COMMANDS
		   -----------------------------------------------------------------------
		 */ //
		/**
		 * Registers a command with the core. The command will run when the
		 * Facade encounters a notification with name specified by
		 * notificationName.
		 *
		 * @param	String
		 * @param	Class
		 * @return	void
		 */
		public function registerCommand(notificationName : String, command : Class) : void {
			var commandClass : String = getQualifiedClassName(command);

			if (!commandMap[notificationName])
				commandMap[notificationName] = [];
			commandMap[notificationName][commandClass] = command;
			HydraFramework.log(HydraFramework.DEBUG_SHOW_INFO, "<HydraFramework> Registering command:", notificationName, "->", commandClass);
		}

		/**
		 * Retrieves a specific command by the notification name it is
		 * registered with.
		 *
		 * @param	String
		 * @param	String
		 * @return	ICommand
		 */
		public function retrieveCommand(notificationName : String, commandClass : String) : ICommand {
			var commandList : Array = retrieveCommandList(notificationName);
			return commandList ? new(commandList[commandClass] as Class)() as ICommand : null;
		}

		/**
		 * Retrieves a list of commands registered (mapped) to a notification
		 * name.
		 *
		 * @param String
		 */
		public function retrieveCommandList(notificationName : String) : Array {
			return commandMap[notificationName];
		}

		/**
		 * Removes a specific command.
		 *
		 * @param	String
		 * @param	Class
		 * @return	void
		 */
		public function removeCommand(notificationName : String, command : Class) : void {
			var commandClass : String = getQualifiedClassName(command);

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
		/**
		 * Registers a Mediator with the core.
		 *
		 * @param	IMediator
		 * @return	void
		 */
		public function registerMediator(mediator : IMediator) : void {
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

		/**
		 * Returns a registered Mediator by name.
		 *
		 * @param	String
		 * @return	IMediator
		 */
		public function retrieveMediator(mediatorNameOrClass : *) : IMediator {
			if (mediatorNameOrClass is String) {
				return mediatorMap[mediatorNameOrClass] as IMediator;
			} else {
				for each (var o : IMediator in mediatorMap) {
					if (o is mediatorNameOrClass) {
						return o;
					}
				}
			}
			return null;
		}

		/**
		 * Removes a registered Mediator by name.
		 *
		 * @param	String
		 * @return	void
		 */
		public function removeMediator(mediatorName : String) : void {
			var relay : IRelay = retrieveMediator(mediatorName) as IRelay;

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
		/**
		 * Registers a Proxy with the core.
		 *
		 * @param	IProxy
		 * @return	void
		 */
		public function registerProxy(proxy : IProxy) : void {
			if (proxyMap[proxy.getName()]) {
				HydraFramework.log(HydraFramework.DEBUG_SHOW_WARNINGS, "*** WARNING *** Proxy '" + proxy.getName() + "' already registered with Facade '" + this.getName() + "'; aborting registration.");
			} else {
				proxyMap[proxy.getName()] = proxy;
				proxy.setFacade(this);

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

		/**
		 * Returns a registered Proxy by name.
		 *
		 * @param	String
		 * @return	IProxy
		 */
		public function retrieveProxy(proxyNameOrClass : *) : IProxy {
			if (proxyNameOrClass is String) {
				return proxyMap[proxyNameOrClass] as IProxy;
			} else {
				for each(var o : IProxy in proxyMap) {
					if (o is proxyNameOrClass) {
						return o;
					}
				}
			}
			return null;
		}

		/**
		 * Removes a registered Proxy by name.
		 *
		 * @param	String
		 * @return	IProxy
		 */
		public function removeProxy(proxyName : String) : void {
			var relay : IRelay = retrieveProxy(proxyName) as IRelay;

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
		/**
		 * Registers a IPlugin with the core.
		 *
		 * @param	IPlugin
		 * @return	void
		 */
		public function registerPlugin(plugin : IPlugin) : void {
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

		/**
		 * Returns a registered Plugin by name.
		 *
		 * @param	String
		 * @return	IPlugin
		 */
		public function retrievePlugin(pluginNameOrClass : *) : IPlugin {
			if (pluginNameOrClass is String) {
				return pluginMap[pluginNameOrClass] as IPlugin;
			} else {
				for each (var o : IPlugin in pluginMap) {
					if (o is pluginNameOrClass) {
						return o;
					}
				}
			}
			return null;
		}

		/**
		 * Removes a registered Plugin by name.
		 *
		 * @param	String
		 * @return	IPlugin
		 */
		public function removePlugin(pluginName : String) : void {
			var relay : IRelay = retrievePlugin(pluginName) as IRelay;

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
		/**
		 * Registers a delegate with the core.
		 *
		 * @param	Class
		 * @return	void
		 */
		public function registerDelegate(delegate : Class, registerGlobal : Boolean = false) : void {
			if (registerGlobal) {
				DelegateRegistry.getInstance().registerDelegate(delegate);
			} else {
				delegateRegistry.registerDelegate(delegate);
			}
		}

		/**
		 * Retrieves the delegate that implements delegateInterface.
		 *
		 * @param	Class
		 * @return	Object
		 */
		public function retrieveDelegate(delegateInterface : Class, forceRetrieveLocal : Boolean = false) : Object {
			var delegate : Object;
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

		/**
		 * Removes a specific delegate.
		 *
		 * @param	String
		 * @param	Class
		 * @return	void
		 */
		public function removeDelegate(delegate : Class, removeGlobal : Boolean = false) : void {
			if (removeGlobal) {
				DelegateRegistry.getInstance().removeDelegate(delegate);
			} else {
				delegateRegistry.removeDelegate(delegate);
			}
		}

		/**
		 * Removes all registered delegates for specified interface.
		 *
		 * @param	String
		 * @param	Class
		 * @return	void
		 */
		public function removeDelegatesByInterface(delegateInterface : Class, removeGlobal : Boolean = false) : void {
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

		hydraframework_internal function __registerCore() : void {
			registerCore();
		}

		/**
		 * Override this method to register individual MVC actors with the
		 * Facade. This is where you will call your register[Relay]() methods.
		 * The order of their registration is not important.
		 */
		public function registerCore() : void {
		}

		hydraframework_internal function __removeCore() : void {
			removeCore();
		}

		/**
		 * Override this method to execute specific functionality when the
		 * core is remove from the system. Events should be removed
		 * automatically, so garbage collection should handle the disposal of
		 * objects, however if you need to explicitly unregister things, do it
		 * here.
		 */
		public function removeCore() : void {
		}
	}
}
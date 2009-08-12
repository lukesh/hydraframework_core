/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core.mvc.patterns.facade {
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.interfaces.ICommand;
	import com.hydraframework.core.mvc.interfaces.IFacade;
	import com.hydraframework.core.mvc.interfaces.IMediator;
	import com.hydraframework.core.mvc.interfaces.IPlugin;
	import com.hydraframework.core.mvc.interfaces.IProxy;
	import com.hydraframework.core.mvc.interfaces.IRelay;
	import com.hydraframework.core.mvc.patterns.mediator.Mediator;
	import com.hydraframework.core.mvc.patterns.plugin.Plugin;
	import com.hydraframework.core.mvc.patterns.proxy.Proxy;
	import com.hydraframework.core.mvc.patterns.relay.Relay;
	import com.hydraframework.core.registries.delegate.DelegateRegistry;
	
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IUIComponent;
	import mx.events.FlexEvent;

	//import nl.demonsters.debugger.MonsterDebugger;

	public class Facade extends Relay implements IFacade {
		public static const REGISTER:String = "Facade.register";
		public static const REMOVE:String = "Facade.remove";
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
		override public function handleNotification(notification:Notification):void {
			super.handleNotification(notification);

			// trace(this, notification.target, this==notification.target, notification.eventPhase, " -- ", notification.name);
			/*
			   If the event's target is the Facade, and it has reached its target,
			   execute the command.
			 */
			if (Event(notification).target == this && Event(notification).eventPhase == EventPhase.AT_TARGET) {
				var commandList:Array = this.retrieveCommandList(notification.name);
				var command:ICommand;

				for (var s:String in commandList) {
					command = ICommand(new(commandList[s] as Class)(this));
					command.execute(notification);
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
			this.addEventListener(Notification.TYPE, relay.handleNotification, false, priority, true);
			relay.addEventListener(Notification.TYPE, handleNotification, false, priority, true);
		}

		/**
		 * @private
		 */
		private function removeRelayEvents(relay:IRelay):void {
			this.removeEventListener(Notification.TYPE, relay.handleNotification, false);
			relay.removeEventListener(Notification.TYPE, handleNotification, false);
		}

		/**
		 * @private
		 */
		override protected function attachEventListeners():void {
			super.attachEventListeners();
			this.addEventListener(Notification.TYPE, handleNotification, false, 0, true);
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
				component.addEventListener(Notification.TYPE, handleNotification, true, 0, true);
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
			this.removeEventListener(Notification.TYPE, handleNotification, false);
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
				component.removeEventListener(Notification.TYPE, handleNotification, true);
				component.removeEventListener(FlexEvent.REMOVE, handleRemove, false);
			}
		}

		override public function initialize():void {
			if (initialized)
				return;
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
			this.registerCore();
			/*
			   Bind Relay events to each actor.
			 */
			super.initialize();
			/*
			   Relays should listen for this Notification and initialize()
			 */
			this.sendNotification(new Notification(Facade.REGISTER, this));
		}

		override public function dispose():void {
			if (!initialized)
				return;
			//MonsterDebugger.trace(this, "Facade.dispose()");
			//trace("Facade.dispose()", this);
			/*
			   Relays should listen for this Notification and dispose()
			 */
			this.sendNotification(new Notification(Facade.REMOVE, this));
			var s:String;
			super.dispose();
			this.removeCore();

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
		public function registerCommand(notificationName:String, command:Class):void {
			var commandClass:String = getQualifiedClassName(command);

			if (!commandMap[notificationName])
				commandMap[notificationName] = [];
			commandMap[notificationName][commandClass] = command;
			trace("Registering command:", notificationName, "->", commandClass);
		}

		/**
		 * Retrieves a specific command by the notification name it is
		 * registered with.
		 *
		 * @param	String
		 * @param	String
		 * @return	ICommand
		 */
		public function retrieveCommand(notificationName:String, commandClass:String):ICommand {
			var commandList:Array = retrieveCommandList(notificationName);
			return commandList ? new(commandList[commandClass] as Class)() as ICommand : null;
		}

		/**
		 * Retrieves a list of commands registered (mapped) to a notification
		 * name.
		 *
		 * @param String
		 */
		public function retrieveCommandList(notificationName:String):Array {
			return commandMap[notificationName];
		}

		/**
		 * Removes a specific command.
		 *
		 * @param	String
		 * @param	Class
		 * @return	void
		 */
		public function removeCommand(notificationName:String, command:Class):void {
			var commandClass:String = getQualifiedClassName(command);

			if (commandMap[notificationName]) {
				delete commandMap[notificationName][commandClass];
			}

			trace("Removing command:", notificationName, "->", commandClass);
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
		public function registerMediator(mediator:IMediator):void {
			if (mediatorMap[mediator.getName()]) {
				trace("*** WARNING *** Mediator '" + mediator.getName() + "' already registered with Facade '" + this.getName() + "'; aborting registration.");
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
		public function retrieveMediator(mediatorName:String):IMediator {
			return mediatorMap[mediatorName] as IMediator;
		}

		/**
		 * Removes a registered Mediator by name.
		 *
		 * @param	String
		 * @return	void
		 */
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
		/**
		 * Registers a Proxy with the core.
		 *
		 * @param	IProxy
		 * @return	void
		 */
		public function registerProxy(proxy:IProxy):void {
			if (proxyMap[proxy.getName()]) {
				trace("*** WARNING *** Proxy '" + proxy.getName() + "' already registered with Facade '" + this.getName() + "'; aborting registration.");
			} else {
				proxyMap[proxy.getName()] = proxy;
				proxy.setFacade(this);
	
				if (this.initialized) {
					registerRelayEvents(proxy as IRelay);
					proxy.initialize();
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
		public function retrieveProxy(proxyName:String):IProxy {
			return proxyMap[proxyName] as IProxy;
		}

		/**
		 * Removes a registered Proxy by name.
		 *
		 * @param	String
		 * @return	IProxy
		 */
		public function removeProxy(proxyName:String):void {
			var relay:IRelay = retrieveProxy(proxyName) as IRelay;

			if (!relay)
				return;
			this.sendNotification(new Notification(Proxy.REMOVE, relay));
			relay.dispose();
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
				plugin.initialize();
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
		public function retrievePlugin(pluginName:String):IPlugin {
			return pluginMap[pluginName] as IPlugin;
		}

		/**
		 * Removes a registered Plugin by name.
		 *
		 * @param	String
		 * @return	IPlugin
		 */
		public function removePlugin(pluginName:String):void {
			var relay:IRelay = retrievePlugin(pluginName) as IRelay;

			if (!relay)
				return;
			this.sendNotification(new Notification(Plugin.REMOVE, relay));
			relay.dispose();
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
		public function registerDelegate(delegate:Class, registerGlobal:Boolean = false):void {
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

		/**
		 * Removes a specific delegate.
		 *
		 * @param	String
		 * @param	Class
		 * @return	void
		 */
		public function removeDelegate(delegate:Class, removeGlobal:Boolean = false):void {
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
		 * Override this method to register individual MVC actors with the
		 * Facade. This is where you will call your register[Relay]() methods.
		 * The order of their registration is not important.
		 */
		public function registerCore():void {
		}

		/**
		 * Override this method to execute specific functionality when the
		 * core is remove from the system. Events should be removed
		 * automatically, so garbage collection should handle the disposal of
		 * objects, however if you need to explicitly unregister things, do it
		 * here.
		 */
		public function removeCore():void {
		}
	}
}
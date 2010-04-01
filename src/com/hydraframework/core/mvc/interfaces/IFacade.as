/*
   HydraFramework - Copyright (c) 2010 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.mvc.interfaces {

	public interface IFacade extends IRelay {
		function registerCommand(notificationName : String, command : Class) : void;
		function retrieveCommand(notificationName : String, commandName : String) : ICommand;
		function retrieveCommandList(notificationName : String) : Array;
		function removeCommand(notificationName : String, command : Class) : void;
		
		function registerMediator(mediator : IMediator) : void;
		function retrieveMediator(mediatorNameOrClass : *) : IMediator;
		function removeMediator(mediatorName : String) : void;
		function registerProxy(proxy : IProxy) : void;
		function retrieveProxy(proxyNameOrClass : *) : IProxy;
		function removeProxy(proxyName : String) : void;
		function registerPlugin(plugin : IPlugin) : void;
		function retrievePlugin(pluginNameOrClass : *) : IPlugin;
		function removePlugin(pluginName : String) : void;
		
		function registerDelegate(delegate : Class, registerGlobal : Boolean = false) : void;
		function retrieveDelegate(delegateInterface : Class, forceRetrieveLocal : Boolean = false) : Object;
		function removeDelegate(delegate : Class, removeGlobal : Boolean = false) : void;
		function removeDelegatesByInterface(delegateInterface : Class, removeGlobal : Boolean = false) : void;
		
		function registerCore() : void;
		function removeCore() : void;
	}
}
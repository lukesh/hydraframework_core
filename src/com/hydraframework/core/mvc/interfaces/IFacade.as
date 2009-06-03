/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core.mvc.interfaces {

	public interface IFacade extends IRelay {
		function registerCommand(notificationName:String, command:Class):void;
		function retrieveCommand(notificationName:String, commandName:String):ICommand;
		function retrieveCommandList(notificationName:String):Array;
		function removeCommand(notificationName:String, command:Class):void;
		function registerMediator(mediator:IMediator):void;
		function retrieveMediator(mediatorName:String):IMediator;
		function removeMediator(mediatorName:String):void;
		function registerProxy(proxy:IProxy):void;
		function retrieveProxy(proxyName:String):IProxy;
		function removeProxy(proxyName:String):void;
		function registerPlugin(plugin:IPlugin):void;
		function retrievePlugin(pluginName:String):IPlugin;
		function removePlugin(pluginName:String):void;
		function registerDelegate(delegate:Class):void;
		function retrieveDelegate(delegateInterface:Class):Object;
		function removeDelegate(delegate:Class):void;
		function registerCore():void;
		function removeCore():void;
	}
}
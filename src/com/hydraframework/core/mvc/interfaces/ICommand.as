/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core.mvc.interfaces {
	import com.hydraframework.core.mvc.events.Notification;
	
	public interface ICommand {
		function execute(notification:Notification):void;
	}
}
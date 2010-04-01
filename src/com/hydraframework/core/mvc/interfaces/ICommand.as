/*
   HydraFramework - Copyright (c) 2010 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.mvc.interfaces {
	import com.hydraframework.core.mvc.events.Notification;

	public interface ICommand {
		function execute(notification : Notification) : void;
	}
}
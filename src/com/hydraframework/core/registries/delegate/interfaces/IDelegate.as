/*
   HydraFramework - Copyright (c) 2010 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.registries.delegate.interfaces {
	import mx.rpc.IResponder;

	public interface IDelegate {
		function set responder(value : IResponder) : void;
		/**
		 * The delegate maintains a responder property of type IResponder.
		 * When the delegate gets a response from the server, it is responsible
		 * transforming the data and applying it to the responder.
		 */
		function get responder() : IResponder;
	}
}
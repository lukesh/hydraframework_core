/*
   HydraFramework - Copyright (c) 2009-2012 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core {

    import com.hydraframework.core.mvc.interfaces.IFacade;
    import flash.events.EventDispatcher;
    import mx.core.IUIComponent;
    import mx.events.FlexEvent;

    public class HydraCore extends EventDispatcher {

        public var component:IUIComponent;
        public var facadeClass:Class;
        public var facade:IFacade;

        public function HydraCore(component:IUIComponent, facadeClass:Class) {
            this.component = component;
            this.facadeClass = facadeClass;
            this.component.addEventListener(FlexEvent.INITIALIZE, handleInitialize);
        }

        private function handleInitialize(event:FlexEvent):void {
            this.facade = new facadeClass(component);
        }
    }
}

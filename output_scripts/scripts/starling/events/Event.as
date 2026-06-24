package starling.events
{
   import flash.utils.getQualifiedClassName;
   import starling.core.starling_internal;
   import starling.utils.StringUtil;
   
   public class Event
   {
      
      public static const ADDED:String = "added";
      
      public static const ADDED_TO_STAGE:String = "addedToStage";
      
      public static const ENTER_FRAME:String = "enterFrame";
      
      public static const REMOVED:String = "removed";
      
      public static const REMOVED_FROM_STAGE:String = "removedFromStage";
      
      public static const TRIGGERED:String = "triggered";
      
      public static const RESIZE:String = "resize";
      
      public static const COMPLETE:String = "complete";
      
      public static const CONTEXT3D_CREATE:String = "context3DCreate";
      
      public static const RENDER:String = "render";
      
      public static const SKIP_FRAME:String = "skipFrame";
      
      public static const ROOT_CREATED:String = "rootCreated";
      
      public static const REMOVE_FROM_JUGGLER:String = "removeFromJuggler";
      
      public static const TEXTURES_RESTORED:String = "texturesRestored";
      
      public static const IO_ERROR:String = "ioError";
      
      public static const SECURITY_ERROR:String = "securityError";
      
      public static const PARSE_ERROR:String = "parseError";
      
      public static const FATAL_ERROR:String = "fatalError";
      
      public static const CHANGE:String = "change";
      
      public static const CANCEL:String = "cancel";
      
      public static const SCROLL:String = "scroll";
      
      public static const OPEN:String = "open";
      
      public static const CLOSE:String = "close";
      
      public static const SELECT:String = "select";
      
      public static const READY:String = "ready";
      
      public static const UPDATE:String = "update";
      
      private static var sEventPool:Vector.<starling.events.Event> = new Vector.<starling.events.Event>(0);
       
      
      private var _target:starling.events.EventDispatcher;
      
      private var _currentTarget:starling.events.EventDispatcher;
      
      private var _type:String;
      
      private var _bubbles:Boolean;
      
      private var _stopsPropagation:Boolean;
      
      private var _stopsImmediatePropagation:Boolean;
      
      private var _data:Object;
      
      public function Event(param1:String, param2:Boolean = false, param3:Object = null)
      {
         super();
         this._type = param1;
         this._bubbles = param2;
         this._data = param3;
      }
      
      starling_internal static function fromPool(param1:String, param2:Boolean = false, param3:Object = null) : starling.events.Event
      {
         if(sEventPool.length)
         {
            return sEventPool.pop().reset(param1,param2,param3);
         }
         return new starling.events.Event(param1,param2,param3);
      }
      
      starling_internal static function toPool(param1:starling.events.Event) : void
      {
         param1._data = param1._target = param1._currentTarget = null;
         sEventPool[sEventPool.length] = param1;
      }
      
      public function stopPropagation() : void
      {
         this._stopsPropagation = true;
      }
      
      public function stopImmediatePropagation() : void
      {
         this._stopsPropagation = this._stopsImmediatePropagation = true;
      }
      
      public function toString() : String
      {
         return StringUtil.format("[{0} type=\"{1}\" bubbles={2}]",getQualifiedClassName(this).split("::").pop(),this._type,this._bubbles);
      }
      
      public function get bubbles() : Boolean
      {
         return this._bubbles;
      }
      
      public function get target() : starling.events.EventDispatcher
      {
         return this._target;
      }
      
      public function get currentTarget() : starling.events.EventDispatcher
      {
         return this._currentTarget;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      internal function setTarget(param1:starling.events.EventDispatcher) : void
      {
         this._target = param1;
      }
      
      internal function setCurrentTarget(param1:starling.events.EventDispatcher) : void
      {
         this._currentTarget = param1;
      }
      
      internal function setData(param1:Object) : void
      {
         this._data = param1;
      }
      
      internal function get stopsPropagation() : Boolean
      {
         return this._stopsPropagation;
      }
      
      internal function get stopsImmediatePropagation() : Boolean
      {
         return this._stopsImmediatePropagation;
      }
      
      starling_internal function reset(param1:String, param2:Boolean = false, param3:Object = null) : starling.events.Event
      {
         this._type = param1;
         this._bubbles = param2;
         this._data = param3;
         this._target = this._currentTarget = null;
         this._stopsPropagation = this._stopsImmediatePropagation = false;
         return this;
      }
   }
}

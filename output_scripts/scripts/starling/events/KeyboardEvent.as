package starling.events
{
   public class KeyboardEvent extends Event
   {
      
      public static const KEY_UP:String = "keyUp";
      
      public static const KEY_DOWN:String = "keyDown";
       
      
      private var _charCode:uint;
      
      private var _keyCode:uint;
      
      private var _keyLocation:uint;
      
      private var _altKey:Boolean;
      
      private var _ctrlKey:Boolean;
      
      private var _shiftKey:Boolean;
      
      private var _isDefaultPrevented:Boolean;
      
      public function KeyboardEvent(param1:String, param2:uint = 0, param3:uint = 0, param4:uint = 0, param5:Boolean = false, param6:Boolean = false, param7:Boolean = false)
      {
         super(param1,false,param3);
         this._charCode = param2;
         this._keyCode = param3;
         this._keyLocation = param4;
         this._ctrlKey = param5;
         this._altKey = param6;
         this._shiftKey = param7;
      }
      
      public function preventDefault() : void
      {
         this._isDefaultPrevented = true;
      }
      
      public function isDefaultPrevented() : Boolean
      {
         return this._isDefaultPrevented;
      }
      
      public function get charCode() : uint
      {
         return this._charCode;
      }
      
      public function get keyCode() : uint
      {
         return this._keyCode;
      }
      
      public function get keyLocation() : uint
      {
         return this._keyLocation;
      }
      
      public function get altKey() : Boolean
      {
         return this._altKey;
      }
      
      public function get ctrlKey() : Boolean
      {
         return this._ctrlKey;
      }
      
      public function get shiftKey() : Boolean
      {
         return this._shiftKey;
      }
   }
}

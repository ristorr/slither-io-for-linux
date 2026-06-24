package starling.text
{
   import flash.text.StyleSheet;
   import starling.core.Starling;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   
   public class TextOptions extends EventDispatcher
   {
       
      
      private var _wordWrap:Boolean;
      
      private var _autoScale:Boolean;
      
      private var _autoSize:String;
      
      private var _isHtmlText:Boolean;
      
      private var _textureScale:Number;
      
      private var _textureFormat:String;
      
      private var _styleSheet:StyleSheet;
      
      private var _padding:Number;
      
      public function TextOptions(param1:Boolean = true, param2:Boolean = false)
      {
         super();
         this._wordWrap = param1;
         this._autoScale = param2;
         this._autoSize = starling.text.TextFieldAutoSize.NONE;
         this._textureScale = Starling.contentScaleFactor;
         this._textureFormat = starling.text.TextField.defaultTextureFormat;
         this._isHtmlText = false;
         this._padding = 0;
      }
      
      public function copyFrom(param1:starling.text.TextOptions) : void
      {
         this._wordWrap = param1._wordWrap;
         this._autoScale = param1._autoScale;
         this._autoSize = param1._autoSize;
         this._isHtmlText = param1._isHtmlText;
         this._textureScale = param1._textureScale;
         this._textureFormat = param1._textureFormat;
         this._styleSheet = param1._styleSheet;
         this._padding = param1._padding;
         dispatchEventWith(Event.CHANGE);
      }
      
      public function clone() : starling.text.TextOptions
      {
         var _loc1_:Class = Object(this).constructor as Class;
         var _loc2_:starling.text.TextOptions = new _loc1_() as starling.text.TextOptions;
         _loc2_.copyFrom(this);
         return _loc2_;
      }
      
      public function get wordWrap() : Boolean
      {
         return this._wordWrap;
      }
      
      public function set wordWrap(param1:Boolean) : void
      {
         if(this._wordWrap != param1)
         {
            this._wordWrap = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get autoSize() : String
      {
         return this._autoSize;
      }
      
      public function set autoSize(param1:String) : void
      {
         if(this._autoSize != param1)
         {
            this._autoSize = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get autoScale() : Boolean
      {
         return this._autoScale;
      }
      
      public function set autoScale(param1:Boolean) : void
      {
         if(this._autoScale != param1)
         {
            this._autoScale = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get isHtmlText() : Boolean
      {
         return this._isHtmlText;
      }
      
      public function set isHtmlText(param1:Boolean) : void
      {
         if(this._isHtmlText != param1)
         {
            this._isHtmlText = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get styleSheet() : StyleSheet
      {
         return this._styleSheet;
      }
      
      public function set styleSheet(param1:StyleSheet) : void
      {
         this._styleSheet = param1;
         dispatchEventWith(Event.CHANGE);
      }
      
      public function get textureScale() : Number
      {
         return this._textureScale;
      }
      
      public function set textureScale(param1:Number) : void
      {
         this._textureScale = param1;
      }
      
      public function get textureFormat() : String
      {
         return this._textureFormat;
      }
      
      public function set textureFormat(param1:String) : void
      {
         if(this._textureFormat != param1)
         {
            this._textureFormat = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get padding() : Number
      {
         return this._padding;
      }
      
      public function set padding(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         if(this._padding != param1)
         {
            this._padding = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
   }
}

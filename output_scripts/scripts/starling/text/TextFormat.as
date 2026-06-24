package starling.text
{
   import flash.text.TextFormat;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.utils.Align;
   
   public class TextFormat extends EventDispatcher
   {
       
      
      private var _font:String;
      
      private var _size:Number;
      
      private var _color:uint;
      
      private var _bold:Boolean;
      
      private var _italic:Boolean;
      
      private var _underline:Boolean;
      
      private var _horizontalAlign:String;
      
      private var _verticalAlign:String;
      
      private var _kerning:Boolean;
      
      private var _leading:Number;
      
      private var _letterSpacing:Number;
      
      public function TextFormat(param1:String = "Verdana", param2:Number = 12, param3:uint = 0, param4:String = "center", param5:String = "center")
      {
         super();
         this._font = param1;
         this._size = param2;
         this._color = param3;
         this._horizontalAlign = param4;
         this._verticalAlign = param5;
         this._kerning = true;
         this._letterSpacing = this._leading = 0;
      }
      
      public function copyFrom(param1:starling.text.TextFormat) : void
      {
         this._font = param1._font;
         this._size = param1._size;
         this._color = param1._color;
         this._bold = param1._bold;
         this._italic = param1._italic;
         this._underline = param1._underline;
         this._horizontalAlign = param1._horizontalAlign;
         this._verticalAlign = param1._verticalAlign;
         this._kerning = param1._kerning;
         this._leading = param1._leading;
         this._letterSpacing = param1._letterSpacing;
         dispatchEventWith(Event.CHANGE);
      }
      
      public function clone() : starling.text.TextFormat
      {
         var _loc1_:Class = Object(this).constructor as Class;
         var _loc2_:starling.text.TextFormat = new _loc1_() as starling.text.TextFormat;
         _loc2_.copyFrom(this);
         return _loc2_;
      }
      
      public function setTo(param1:String = "Verdana", param2:Number = 12, param3:uint = 0, param4:String = "center", param5:String = "center") : void
      {
         this._font = param1;
         this._size = param2;
         this._color = param3;
         this._horizontalAlign = param4;
         this._verticalAlign = param5;
         dispatchEventWith(Event.CHANGE);
      }
      
      public function toNativeFormat(param1:flash.text.TextFormat = null) : flash.text.TextFormat
      {
         if(param1 == null)
         {
            param1 = new flash.text.TextFormat();
         }
         param1.font = this._font;
         param1.size = this._size;
         param1.color = this._color;
         param1.bold = this._bold;
         param1.italic = this._italic;
         param1.underline = this._underline;
         param1.align = this._horizontalAlign;
         param1.kerning = this._kerning;
         param1.leading = this._leading;
         param1.letterSpacing = this._letterSpacing;
         return param1;
      }
      
      public function get font() : String
      {
         return this._font;
      }
      
      public function set font(param1:String) : void
      {
         if(param1 != this._font)
         {
            this._font = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get size() : Number
      {
         return this._size;
      }
      
      public function set size(param1:Number) : void
      {
         if(param1 != this._size)
         {
            this._size = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(param1:uint) : void
      {
         if(param1 != this._color)
         {
            this._color = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get bold() : Boolean
      {
         return this._bold;
      }
      
      public function set bold(param1:Boolean) : void
      {
         if(param1 != this._bold)
         {
            this._bold = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get italic() : Boolean
      {
         return this._italic;
      }
      
      public function set italic(param1:Boolean) : void
      {
         if(param1 != this._italic)
         {
            this._italic = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get underline() : Boolean
      {
         return this._underline;
      }
      
      public function set underline(param1:Boolean) : void
      {
         if(param1 != this._underline)
         {
            this._underline = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get horizontalAlign() : String
      {
         return this._horizontalAlign;
      }
      
      public function set horizontalAlign(param1:String) : void
      {
         if(!Align.isValidHorizontal(param1))
         {
            throw new ArgumentError("Invalid horizontal alignment");
         }
         if(param1 != this._horizontalAlign)
         {
            this._horizontalAlign = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get verticalAlign() : String
      {
         return this._verticalAlign;
      }
      
      public function set verticalAlign(param1:String) : void
      {
         if(!Align.isValidVertical(param1))
         {
            throw new ArgumentError("Invalid vertical alignment");
         }
         if(param1 != this._verticalAlign)
         {
            this._verticalAlign = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get kerning() : Boolean
      {
         return this._kerning;
      }
      
      public function set kerning(param1:Boolean) : void
      {
         if(param1 != this._kerning)
         {
            this._kerning = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get leading() : Number
      {
         return this._leading;
      }
      
      public function set leading(param1:Number) : void
      {
         if(param1 != this._leading)
         {
            this._leading = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get letterSpacing() : Number
      {
         return this._letterSpacing;
      }
      
      public function set letterSpacing(param1:Number) : void
      {
         if(param1 != this._letterSpacing)
         {
            this._letterSpacing = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
   }
}

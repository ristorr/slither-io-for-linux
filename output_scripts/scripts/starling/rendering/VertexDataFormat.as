package starling.rendering
{
   import flash.display3D.VertexBuffer3D;
   import flash.utils.Dictionary;
   import starling.core.Starling;
   import starling.utils.StringUtil;
   
   public class VertexDataFormat
   {
      
      private static var sFormats:Dictionary = new Dictionary();
       
      
      private var _format:String;
      
      private var _vertexSize:int;
      
      private var _attributes:Vector.<starling.rendering.VertexDataAttribute>;
      
      public function VertexDataFormat()
      {
         super();
         this._attributes = new Vector.<starling.rendering.VertexDataAttribute>();
      }
      
      public static function fromString(param1:String) : starling.rendering.VertexDataFormat
      {
         var _loc2_:starling.rendering.VertexDataFormat = null;
         var _loc3_:String = null;
         if(param1 in sFormats)
         {
            return sFormats[param1];
         }
         _loc2_ = new starling.rendering.VertexDataFormat();
         _loc2_.parseFormat(param1);
         _loc3_ = _loc2_._format;
         if(_loc3_ in sFormats)
         {
            _loc2_ = sFormats[_loc3_];
         }
         sFormats[param1] = _loc2_;
         sFormats[_loc3_] = _loc2_;
         return _loc2_;
      }
      
      public function extend(param1:String) : starling.rendering.VertexDataFormat
      {
         return fromString(this._format + ", " + param1);
      }
      
      public function getSize(param1:String) : int
      {
         return this.getAttribute(param1).size;
      }
      
      public function getSizeIn32Bits(param1:String) : int
      {
         return this.getAttribute(param1).size / 4;
      }
      
      public function getOffset(param1:String) : int
      {
         return this.getAttribute(param1).offset;
      }
      
      public function getOffsetIn32Bits(param1:String) : int
      {
         return this.getAttribute(param1).offset / 4;
      }
      
      public function getFormat(param1:String) : String
      {
         return this.getAttribute(param1).format;
      }
      
      public function getName(param1:int) : String
      {
         return this._attributes[param1].name;
      }
      
      public function hasAttribute(param1:String) : Boolean
      {
         var _loc2_:int = int(this._attributes.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this._attributes[_loc3_].name == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function setVertexBufferAt(param1:int, param2:VertexBuffer3D, param3:String) : void
      {
         var _loc4_:starling.rendering.VertexDataAttribute = this.getAttribute(param3);
         Starling.context.setVertexBufferAt(param1,param2,_loc4_.offset / 4,_loc4_.format);
      }
      
      private function parseFormat(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:starling.rendering.VertexDataAttribute = null;
         if(param1 != null && param1 != "")
         {
            this._attributes.length = 0;
            this._format = "";
            _loc2_ = param1.split(",");
            _loc3_ = int(_loc2_.length);
            _loc4_ = 0;
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               if((_loc7_ = (_loc6_ = String(_loc2_[_loc5_])).split(":")).length != 2)
               {
                  throw new ArgumentError("Missing colon: " + _loc6_);
               }
               _loc8_ = StringUtil.trim(_loc7_[0]);
               _loc9_ = StringUtil.trim(_loc7_[1]);
               if(_loc8_.length == 0 || _loc9_.length == 0)
               {
                  throw new ArgumentError("Invalid format string: " + _loc6_);
               }
               _loc10_ = new starling.rendering.VertexDataAttribute(_loc8_,_loc9_,_loc4_);
               _loc4_ += _loc10_.size;
               this._format += (_loc5_ == 0 ? "" : ", ") + _loc10_.name + ":" + _loc10_.format;
               this._attributes[this._attributes.length] = _loc10_;
               _loc5_++;
            }
            this._vertexSize = _loc4_;
         }
         else
         {
            this._format = "";
         }
      }
      
      public function toString() : String
      {
         return this._format;
      }
      
      internal function getAttribute(param1:String) : starling.rendering.VertexDataAttribute
      {
         var _loc2_:int = 0;
         var _loc3_:starling.rendering.VertexDataAttribute = null;
         var _loc4_:int = int(this._attributes.length);
         _loc2_ = 0;
         while(_loc2_ < _loc4_)
         {
            _loc3_ = this._attributes[_loc2_];
            if(_loc3_.name == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      internal function get attributes() : Vector.<starling.rendering.VertexDataAttribute>
      {
         return this._attributes;
      }
      
      public function get formatString() : String
      {
         return this._format;
      }
      
      public function get vertexSize() : int
      {
         return this._vertexSize;
      }
      
      public function get vertexSizeIn32Bits() : int
      {
         return this._vertexSize / 4;
      }
      
      public function get numAttributes() : int
      {
         return this._attributes.length;
      }
   }
}

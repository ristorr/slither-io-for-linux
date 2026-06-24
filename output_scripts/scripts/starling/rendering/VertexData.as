package starling.rendering
{
   import flash.display3D.Context3D;
   import flash.display3D.VertexBuffer3D;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import starling.core.Starling;
   import starling.errors.MissingContextError;
   import starling.styles.MeshStyle;
   import starling.utils.MathUtil;
   import starling.utils.MatrixUtil;
   import starling.utils.StringUtil;
   
   public class VertexData
   {
      
      private static var sHelperPoint:Point = new Point();
      
      private static var sHelperPoint3D:Vector3D = new Vector3D();
      
      private static var sBytes:ByteArray = new ByteArray();
       
      
      private var _rawData:ByteArray;
      
      private var _numVertices:int;
      
      private var _format:starling.rendering.VertexDataFormat;
      
      private var _attributes:Vector.<starling.rendering.VertexDataAttribute>;
      
      private var _numAttributes:int;
      
      private var _premultipliedAlpha:Boolean;
      
      private var _tinted:Boolean;
      
      private var _posOffset:int;
      
      private var _colOffset:int;
      
      private var _vertexSize:int;
      
      public function VertexData(param1:* = null, param2:int = 32)
      {
         super();
         if(param1 == null)
         {
            this._format = MeshStyle.VERTEX_FORMAT;
         }
         else if(param1 is starling.rendering.VertexDataFormat)
         {
            this._format = param1;
         }
         else
         {
            if(!(param1 is String))
            {
               throw new ArgumentError("\'format\' must be String or VertexDataFormat");
            }
            this._format = starling.rendering.VertexDataFormat.fromString(param1 as String);
         }
         this._attributes = this._format.attributes;
         this._numAttributes = this._attributes.length;
         this._posOffset = this._format.hasAttribute("position") ? this._format.getOffset("position") : 0;
         this._colOffset = this._format.hasAttribute("color") ? this._format.getOffset("color") : 0;
         this._vertexSize = this._format.vertexSize;
         this._numVertices = 0;
         this._premultipliedAlpha = true;
         this._rawData = new ByteArray();
         this._rawData.endian = sBytes.endian = Endian.LITTLE_ENDIAN;
         this._rawData.length = param2 * this._vertexSize;
         this._rawData.length = 0;
      }
      
      private static function switchEndian(param1:uint) : uint
      {
         return (param1 & 255) << 24 | (param1 >> 8 & 255) << 16 | (param1 >> 16 & 255) << 8 | param1 >> 24 & 255;
      }
      
      private static function premultiplyAlpha(param1:uint) : uint
      {
         var _loc3_:Number = NaN;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc2_:uint = uint(param1 & 255);
         if(_loc2_ == 255)
         {
            return param1;
         }
         _loc3_ = _loc2_ / 255;
         _loc4_ = (param1 >> 24 & 255) * _loc3_;
         _loc5_ = (param1 >> 16 & 255) * _loc3_;
         _loc6_ = (param1 >> 8 & 255) * _loc3_;
         return (_loc4_ & 255) << 24 | (_loc5_ & 255) << 16 | (_loc6_ & 255) << 8 | _loc2_;
      }
      
      private static function unmultiplyAlpha(param1:uint) : uint
      {
         var _loc3_:Number = NaN;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc2_:uint = uint(param1 & 255);
         if(_loc2_ == 255 || _loc2_ == 0)
         {
            return param1;
         }
         _loc3_ = _loc2_ / 255;
         _loc4_ = (param1 >> 24 & 255) / _loc3_;
         _loc5_ = (param1 >> 16 & 255) / _loc3_;
         _loc6_ = (param1 >> 8 & 255) / _loc3_;
         return (_loc4_ & 255) << 24 | (_loc5_ & 255) << 16 | (_loc6_ & 255) << 8 | _loc2_;
      }
      
      public function clear() : void
      {
         this._rawData.clear();
         this._numVertices = 0;
         this._tinted = false;
      }
      
      public function clone() : starling.rendering.VertexData
      {
         var _loc1_:starling.rendering.VertexData = new starling.rendering.VertexData(this._format,this._numVertices);
         _loc1_._rawData.writeBytes(this._rawData);
         _loc1_._numVertices = this._numVertices;
         _loc1_._premultipliedAlpha = this._premultipliedAlpha;
         _loc1_._tinted = this._tinted;
         return _loc1_;
      }
      
      public function copyTo(param1:starling.rendering.VertexData, param2:int = 0, param3:Matrix = null, param4:int = 0, param5:int = -1) : void
      {
         var _loc6_:ByteArray = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:starling.rendering.VertexDataAttribute = null;
         var _loc13_:starling.rendering.VertexDataAttribute = null;
         if(param5 < 0 || param4 + param5 > this._numVertices)
         {
            param5 = this._numVertices - param4;
         }
         if(this._format === param1._format)
         {
            if(param1._numVertices < param2 + param5)
            {
               param1._numVertices = param2 + param5;
            }
            param1._tinted = param1._tinted || this._tinted;
            (_loc6_ = param1._rawData).position = param2 * this._vertexSize;
            _loc6_.writeBytes(this._rawData,param4 * this._vertexSize,param5 * this._vertexSize);
            if(param3)
            {
               _loc10_ = (_loc9_ = param2 * this._vertexSize + this._posOffset) + param5 * this._vertexSize;
               while(_loc9_ < _loc10_)
               {
                  _loc6_.position = _loc9_;
                  _loc7_ = _loc6_.readFloat();
                  _loc8_ = _loc6_.readFloat();
                  _loc6_.position = _loc9_;
                  _loc6_.writeFloat(param3.a * _loc7_ + param3.c * _loc8_ + param3.tx);
                  _loc6_.writeFloat(param3.d * _loc8_ + param3.b * _loc7_ + param3.ty);
                  _loc9_ += this._vertexSize;
               }
            }
         }
         else
         {
            if(param1._numVertices < param2 + param5)
            {
               param1.numVertices = param2 + param5;
            }
            _loc11_ = 0;
            while(_loc11_ < this._numAttributes)
            {
               _loc12_ = this._attributes[_loc11_];
               if(_loc13_ = param1.getAttribute(_loc12_.name))
               {
                  if(_loc12_.offset == this._posOffset)
                  {
                     this.copyAttributeTo_internal(param1,param2,param3,_loc12_,_loc13_,param4,param5);
                  }
                  else
                  {
                     this.copyAttributeTo_internal(param1,param2,null,_loc12_,_loc13_,param4,param5);
                  }
               }
               _loc11_++;
            }
         }
      }
      
      public function copyAttributeTo(param1:starling.rendering.VertexData, param2:int, param3:String, param4:Matrix = null, param5:int = 0, param6:int = -1) : void
      {
         var _loc7_:starling.rendering.VertexDataAttribute = this.getAttribute(param3);
         var _loc8_:starling.rendering.VertexDataAttribute = param1.getAttribute(param3);
         if(_loc7_ == null)
         {
            throw new ArgumentError("Attribute \'" + param3 + "\' not found in source data");
         }
         if(_loc8_ == null)
         {
            throw new ArgumentError("Attribute \'" + param3 + "\' not found in target data");
         }
         if(_loc7_.isColor)
         {
            param1._tinted = param1._tinted || this._tinted;
         }
         this.copyAttributeTo_internal(param1,param2,param4,_loc7_,_loc8_,param5,param6);
      }
      
      private function copyAttributeTo_internal(param1:starling.rendering.VertexData, param2:int, param3:Matrix, param4:starling.rendering.VertexDataAttribute, param5:starling.rendering.VertexDataAttribute, param6:int, param7:int) : void
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(param4.format != param5.format)
         {
            throw new IllegalOperationError("Attribute formats differ between source and target");
         }
         if(param7 < 0 || param6 + param7 > this._numVertices)
         {
            param7 = this._numVertices - param6;
         }
         if(param1._numVertices < param2 + param7)
         {
            param1._numVertices = param2 + param7;
         }
         var _loc12_:ByteArray = this._rawData;
         var _loc13_:ByteArray = param1._rawData;
         var _loc14_:int = this._vertexSize - param4.size;
         var _loc15_:int = param1._vertexSize - param5.size;
         var _loc16_:int = param4.size / 4;
         _loc12_.position = param6 * this._vertexSize + param4.offset;
         _loc13_.position = param2 * param1._vertexSize + param5.offset;
         if(param3)
         {
            _loc8_ = 0;
            while(_loc8_ < param7)
            {
               _loc10_ = _loc12_.readFloat();
               _loc11_ = _loc12_.readFloat();
               _loc13_.writeFloat(param3.a * _loc10_ + param3.c * _loc11_ + param3.tx);
               _loc13_.writeFloat(param3.d * _loc11_ + param3.b * _loc10_ + param3.ty);
               _loc12_.position += _loc14_;
               _loc13_.position += _loc15_;
               _loc8_++;
            }
         }
         else
         {
            _loc8_ = 0;
            while(_loc8_ < param7)
            {
               _loc9_ = 0;
               while(_loc9_ < _loc16_)
               {
                  _loc13_.writeUnsignedInt(_loc12_.readUnsignedInt());
                  _loc9_++;
               }
               _loc12_.position += _loc14_;
               _loc13_.position += _loc15_;
               _loc8_++;
            }
         }
      }
      
      public function trim() : void
      {
         var _loc1_:int = this._numVertices * this._vertexSize;
         sBytes.length = _loc1_;
         sBytes.position = 0;
         sBytes.writeBytes(this._rawData,0,_loc1_);
         this._rawData.clear();
         this._rawData.length = _loc1_;
         this._rawData.writeBytes(sBytes);
         sBytes.length = 0;
      }
      
      public function toString() : String
      {
         return StringUtil.format("[VertexData format=\"{0}\" numVertices={1}]",this._format.formatString,this._numVertices);
      }
      
      public function getUnsignedInt(param1:int, param2:String) : uint
      {
         this._rawData.position = param1 * this._vertexSize + this.getAttribute(param2).offset;
         return this._rawData.readUnsignedInt();
      }
      
      public function setUnsignedInt(param1:int, param2:String, param3:uint) : void
      {
         if(this._numVertices < param1 + 1)
         {
            this.numVertices = param1 + 1;
         }
         this._rawData.position = param1 * this._vertexSize + this.getAttribute(param2).offset;
         this._rawData.writeUnsignedInt(param3);
      }
      
      public function getFloat(param1:int, param2:String) : Number
      {
         this._rawData.position = param1 * this._vertexSize + this.getAttribute(param2).offset;
         return this._rawData.readFloat();
      }
      
      public function setFloat(param1:int, param2:String, param3:Number) : void
      {
         if(this._numVertices < param1 + 1)
         {
            this.numVertices = param1 + 1;
         }
         this._rawData.position = param1 * this._vertexSize + this.getAttribute(param2).offset;
         this._rawData.writeFloat(param3);
      }
      
      public function getPoint(param1:int, param2:String, param3:Point = null) : Point
      {
         if(param3 == null)
         {
            param3 = new Point();
         }
         var _loc4_:int = param2 == "position" ? this._posOffset : this.getAttribute(param2).offset;
         this._rawData.position = param1 * this._vertexSize + _loc4_;
         param3.x = this._rawData.readFloat();
         param3.y = this._rawData.readFloat();
         return param3;
      }
      
      public function setPoint(param1:int, param2:String, param3:Number, param4:Number) : void
      {
         if(this._numVertices < param1 + 1)
         {
            this.numVertices = param1 + 1;
         }
         var _loc5_:int = param2 == "position" ? this._posOffset : this.getAttribute(param2).offset;
         this._rawData.position = param1 * this._vertexSize + _loc5_;
         this._rawData.writeFloat(param3);
         this._rawData.writeFloat(param4);
      }
      
      public function getPoint3D(param1:int, param2:String, param3:Vector3D = null) : Vector3D
      {
         if(param3 == null)
         {
            param3 = new Vector3D();
         }
         this._rawData.position = param1 * this._vertexSize + this.getAttribute(param2).offset;
         param3.x = this._rawData.readFloat();
         param3.y = this._rawData.readFloat();
         param3.z = this._rawData.readFloat();
         return param3;
      }
      
      public function setPoint3D(param1:int, param2:String, param3:Number, param4:Number, param5:Number) : void
      {
         if(this._numVertices < param1 + 1)
         {
            this.numVertices = param1 + 1;
         }
         this._rawData.position = param1 * this._vertexSize + this.getAttribute(param2).offset;
         this._rawData.writeFloat(param3);
         this._rawData.writeFloat(param4);
         this._rawData.writeFloat(param5);
      }
      
      public function getPoint4D(param1:int, param2:String, param3:Vector3D = null) : Vector3D
      {
         if(param3 == null)
         {
            param3 = new Vector3D();
         }
         this._rawData.position = param1 * this._vertexSize + this.getAttribute(param2).offset;
         param3.x = this._rawData.readFloat();
         param3.y = this._rawData.readFloat();
         param3.z = this._rawData.readFloat();
         param3.w = this._rawData.readFloat();
         return param3;
      }
      
      public function setPoint4D(param1:int, param2:String, param3:Number, param4:Number, param5:Number, param6:Number = 1) : void
      {
         if(this._numVertices < param1 + 1)
         {
            this.numVertices = param1 + 1;
         }
         this._rawData.position = param1 * this._vertexSize + this.getAttribute(param2).offset;
         this._rawData.writeFloat(param3);
         this._rawData.writeFloat(param4);
         this._rawData.writeFloat(param5);
         this._rawData.writeFloat(param6);
      }
      
      public function getColor(param1:int, param2:String = "color") : uint
      {
         var _loc3_:int = param2 == "color" ? this._colOffset : this.getAttribute(param2).offset;
         this._rawData.position = param1 * this._vertexSize + _loc3_;
         var _loc4_:uint = switchEndian(this._rawData.readUnsignedInt());
         if(this._premultipliedAlpha)
         {
            _loc4_ = unmultiplyAlpha(_loc4_);
         }
         return _loc4_ >> 8 & 16777215;
      }
      
      public function setColor(param1:int, param2:String, param3:uint) : void
      {
         if(this._numVertices < param1 + 1)
         {
            this.numVertices = param1 + 1;
         }
         var _loc4_:Number = this.getAlpha(param1,param2);
         this.colorize(param2,param3,_loc4_,param1,1);
      }
      
      public function getAlpha(param1:int, param2:String = "color") : Number
      {
         var _loc3_:int = param2 == "color" ? this._colOffset : this.getAttribute(param2).offset;
         this._rawData.position = param1 * this._vertexSize + _loc3_;
         var _loc4_:uint;
         return ((_loc4_ = switchEndian(this._rawData.readUnsignedInt())) & 255) / 255;
      }
      
      public function setAlpha(param1:int, param2:String, param3:Number) : void
      {
         if(this._numVertices < param1 + 1)
         {
            this.numVertices = param1 + 1;
         }
         var _loc4_:uint = this.getColor(param1,param2);
         this.colorize(param2,_loc4_,param3,param1,1);
      }
      
      public function getBounds(param1:String = "position", param2:Matrix = null, param3:int = 0, param4:int = -1, param5:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:int = 0;
         if(param5 == null)
         {
            param5 = new flash.geom.Rectangle();
         }
         if(param4 < 0 || param3 + param4 > this._numVertices)
         {
            param4 = this._numVertices - param3;
         }
         if(param4 == 0)
         {
            if(param2 == null)
            {
               param5.setEmpty();
            }
            else
            {
               MatrixUtil.transformCoords(param2,0,0,sHelperPoint);
               param5.setTo(sHelperPoint.x,sHelperPoint.y,0,0);
            }
         }
         else
         {
            _loc6_ = Number.MAX_VALUE;
            _loc7_ = -Number.MAX_VALUE;
            _loc8_ = Number.MAX_VALUE;
            _loc9_ = -Number.MAX_VALUE;
            _loc10_ = param1 == "position" ? this._posOffset : this.getAttribute(param1).offset;
            _loc11_ = param3 * this._vertexSize + _loc10_;
            if(param2 == null)
            {
               _loc14_ = 0;
               while(_loc14_ < param4)
               {
                  this._rawData.position = _loc11_;
                  _loc12_ = this._rawData.readFloat();
                  _loc13_ = this._rawData.readFloat();
                  _loc11_ += this._vertexSize;
                  if(_loc6_ > _loc12_)
                  {
                     _loc6_ = _loc12_;
                  }
                  if(_loc7_ < _loc12_)
                  {
                     _loc7_ = _loc12_;
                  }
                  if(_loc8_ > _loc13_)
                  {
                     _loc8_ = _loc13_;
                  }
                  if(_loc9_ < _loc13_)
                  {
                     _loc9_ = _loc13_;
                  }
                  _loc14_++;
               }
            }
            else
            {
               _loc14_ = 0;
               while(_loc14_ < param4)
               {
                  this._rawData.position = _loc11_;
                  _loc12_ = this._rawData.readFloat();
                  _loc13_ = this._rawData.readFloat();
                  _loc11_ += this._vertexSize;
                  MatrixUtil.transformCoords(param2,_loc12_,_loc13_,sHelperPoint);
                  if(_loc6_ > sHelperPoint.x)
                  {
                     _loc6_ = sHelperPoint.x;
                  }
                  if(_loc7_ < sHelperPoint.x)
                  {
                     _loc7_ = sHelperPoint.x;
                  }
                  if(_loc8_ > sHelperPoint.y)
                  {
                     _loc8_ = sHelperPoint.y;
                  }
                  if(_loc9_ < sHelperPoint.y)
                  {
                     _loc9_ = sHelperPoint.y;
                  }
                  _loc14_++;
               }
            }
            param5.setTo(_loc6_,_loc8_,_loc7_ - _loc6_,_loc9_ - _loc8_);
         }
         return param5;
      }
      
      public function getBoundsProjected(param1:String, param2:Matrix3D, param3:Vector3D, param4:int = 0, param5:int = -1, param6:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:int = 0;
         if(param6 == null)
         {
            param6 = new flash.geom.Rectangle();
         }
         if(param3 == null)
         {
            throw new ArgumentError("camPos must not be null");
         }
         if(param5 < 0 || param4 + param5 > this._numVertices)
         {
            param5 = this._numVertices - param4;
         }
         if(param5 == 0)
         {
            if(param2)
            {
               MatrixUtil.transformCoords3D(param2,0,0,0,sHelperPoint3D);
            }
            else
            {
               sHelperPoint3D.setTo(0,0,0);
            }
            MathUtil.intersectLineWithXYPlane(param3,sHelperPoint3D,sHelperPoint);
            param6.setTo(sHelperPoint.x,sHelperPoint.y,0,0);
         }
         else
         {
            _loc7_ = Number.MAX_VALUE;
            _loc8_ = -Number.MAX_VALUE;
            _loc9_ = Number.MAX_VALUE;
            _loc10_ = -Number.MAX_VALUE;
            _loc11_ = param1 == "position" ? this._posOffset : this.getAttribute(param1).offset;
            _loc12_ = param4 * this._vertexSize + _loc11_;
            _loc15_ = 0;
            while(_loc15_ < param5)
            {
               this._rawData.position = _loc12_;
               _loc13_ = this._rawData.readFloat();
               _loc14_ = this._rawData.readFloat();
               _loc12_ += this._vertexSize;
               if(param2)
               {
                  MatrixUtil.transformCoords3D(param2,_loc13_,_loc14_,0,sHelperPoint3D);
               }
               else
               {
                  sHelperPoint3D.setTo(_loc13_,_loc14_,0);
               }
               MathUtil.intersectLineWithXYPlane(param3,sHelperPoint3D,sHelperPoint);
               if(_loc7_ > sHelperPoint.x)
               {
                  _loc7_ = sHelperPoint.x;
               }
               if(_loc8_ < sHelperPoint.x)
               {
                  _loc8_ = sHelperPoint.x;
               }
               if(_loc9_ > sHelperPoint.y)
               {
                  _loc9_ = sHelperPoint.y;
               }
               if(_loc10_ < sHelperPoint.y)
               {
                  _loc10_ = sHelperPoint.y;
               }
               _loc15_++;
            }
            param6.setTo(_loc7_,_loc9_,_loc8_ - _loc7_,_loc10_ - _loc9_);
         }
         return param6;
      }
      
      public function get premultipliedAlpha() : Boolean
      {
         return this._premultipliedAlpha;
      }
      
      public function set premultipliedAlpha(param1:Boolean) : void
      {
         this.setPremultipliedAlpha(param1,false);
      }
      
      public function setPremultipliedAlpha(param1:Boolean, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:starling.rendering.VertexDataAttribute = null;
         var _loc5_:int = 0;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:int = 0;
         if(param2 && param1 != this._premultipliedAlpha)
         {
            _loc3_ = 0;
            while(_loc3_ < this._numAttributes)
            {
               if((_loc4_ = this._attributes[_loc3_]).isColor)
               {
                  _loc5_ = _loc4_.offset;
                  _loc8_ = 0;
                  while(_loc8_ < this._numVertices)
                  {
                     this._rawData.position = _loc5_;
                     _loc6_ = switchEndian(this._rawData.readUnsignedInt());
                     _loc7_ = param1 ? premultiplyAlpha(_loc6_) : unmultiplyAlpha(_loc6_);
                     this._rawData.position = _loc5_;
                     this._rawData.writeUnsignedInt(switchEndian(_loc7_));
                     _loc5_ += this._vertexSize;
                     _loc8_++;
                  }
               }
               _loc3_++;
            }
         }
         this._premultipliedAlpha = param1;
      }
      
      public function updateTinted(param1:String = "color") : Boolean
      {
         var _loc2_:int = param1 == "color" ? this._colOffset : this.getAttribute(param1).offset;
         this._tinted = false;
         var _loc3_:int = 0;
         while(_loc3_ < this._numVertices)
         {
            this._rawData.position = _loc2_;
            if(this._rawData.readUnsignedInt() != 4294967295)
            {
               this._tinted = true;
               break;
            }
            _loc2_ += this._vertexSize;
            _loc3_++;
         }
         return this._tinted;
      }
      
      public function transformPoints(param1:String, param2:Matrix, param3:int = 0, param4:int = -1) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(param4 < 0 || param3 + param4 > this._numVertices)
         {
            param4 = this._numVertices - param3;
         }
         var _loc7_:int = param1 == "position" ? this._posOffset : this.getAttribute(param1).offset;
         var _loc8_:int;
         var _loc9_:int = (_loc8_ = param3 * this._vertexSize + _loc7_) + param4 * this._vertexSize;
         while(_loc8_ < _loc9_)
         {
            this._rawData.position = _loc8_;
            _loc5_ = this._rawData.readFloat();
            _loc6_ = this._rawData.readFloat();
            this._rawData.position = _loc8_;
            this._rawData.writeFloat(param2.a * _loc5_ + param2.c * _loc6_ + param2.tx);
            this._rawData.writeFloat(param2.d * _loc6_ + param2.b * _loc5_ + param2.ty);
            _loc8_ += this._vertexSize;
         }
      }
      
      public function translatePoints(param1:String, param2:Number, param3:Number, param4:int = 0, param5:int = -1) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(param5 < 0 || param4 + param5 > this._numVertices)
         {
            param5 = this._numVertices - param4;
         }
         var _loc8_:int = param1 == "position" ? this._posOffset : this.getAttribute(param1).offset;
         var _loc9_:int;
         var _loc10_:int = (_loc9_ = param4 * this._vertexSize + _loc8_) + param5 * this._vertexSize;
         while(_loc9_ < _loc10_)
         {
            this._rawData.position = _loc9_;
            _loc6_ = this._rawData.readFloat();
            _loc7_ = this._rawData.readFloat();
            this._rawData.position = _loc9_;
            this._rawData.writeFloat(_loc6_ + param2);
            this._rawData.writeFloat(_loc7_ + param3);
            _loc9_ += this._vertexSize;
         }
      }
      
      public function scaleAlphas(param1:String, param2:Number, param3:int = 0, param4:int = -1) : void
      {
         var _loc5_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:uint = 0;
         if(param2 == 1)
         {
            return;
         }
         if(param4 < 0 || param3 + param4 > this._numVertices)
         {
            param4 = this._numVertices - param3;
         }
         this._tinted = true;
         var _loc6_:int = param1 == "color" ? this._colOffset : this.getAttribute(param1).offset;
         var _loc7_:int = param3 * this._vertexSize + _loc6_;
         _loc5_ = 0;
         while(_loc5_ < param4)
         {
            _loc8_ = _loc7_ + 3;
            if((_loc9_ = this._rawData[_loc8_] / 255 * param2) > 1)
            {
               _loc9_ = 1;
            }
            else if(_loc9_ < 0)
            {
               _loc9_ = 0;
            }
            if(_loc9_ == 1 || !this._premultipliedAlpha)
            {
               this._rawData[_loc8_] = int(_loc9_ * 255);
            }
            else
            {
               this._rawData.position = _loc7_;
               _loc10_ = uint((_loc10_ = unmultiplyAlpha(switchEndian(this._rawData.readUnsignedInt()))) & 4294967040 | int(_loc9_ * 255) & 255);
               _loc10_ = premultiplyAlpha(_loc10_);
               this._rawData.position = _loc7_;
               this._rawData.writeUnsignedInt(switchEndian(_loc10_));
            }
            _loc7_ += this._vertexSize;
            _loc5_++;
         }
      }
      
      public function colorize(param1:String = "color", param2:uint = 16777215, param3:Number = 1, param4:int = 0, param5:int = -1) : void
      {
         if(param5 < 0 || param4 + param5 > this._numVertices)
         {
            param5 = this._numVertices - param4;
         }
         var _loc6_:int = param1 == "color" ? this._colOffset : this.getAttribute(param1).offset;
         var _loc7_:int;
         var _loc8_:int = (_loc7_ = param4 * this._vertexSize + _loc6_) + param5 * this._vertexSize;
         if(param3 > 1)
         {
            param3 = 1;
         }
         else if(param3 < 0)
         {
            param3 = 0;
         }
         var _loc9_:uint;
         if((_loc9_ = uint(param2 << 8 & 4294967040 | int(param3 * 255) & 255)) == 4294967295 && param5 == this._numVertices)
         {
            this._tinted = false;
         }
         else if(_loc9_ != 4294967295)
         {
            this._tinted = true;
         }
         if(this._premultipliedAlpha && param3 != 1)
         {
            _loc9_ = premultiplyAlpha(_loc9_);
         }
         this._rawData.position = param4 * this._vertexSize + _loc6_;
         this._rawData.writeUnsignedInt(switchEndian(_loc9_));
         while(_loc7_ < _loc8_)
         {
            this._rawData.position = _loc7_;
            this._rawData.writeUnsignedInt(switchEndian(_loc9_));
            _loc7_ += this._vertexSize;
         }
      }
      
      public function getFormat(param1:String) : String
      {
         return this.getAttribute(param1).format;
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
      
      public function hasAttribute(param1:String) : Boolean
      {
         return this.getAttribute(param1) != null;
      }
      
      public function createVertexBuffer(param1:Boolean = false, param2:String = "staticDraw") : VertexBuffer3D
      {
         var _loc3_:Context3D = Starling.context;
         if(_loc3_ == null)
         {
            throw new MissingContextError();
         }
         if(this._numVertices == 0)
         {
            return null;
         }
         var _loc4_:VertexBuffer3D = _loc3_.createVertexBuffer(this._numVertices,this._vertexSize / 4,param2);
         if(param1)
         {
            this.uploadToVertexBuffer(_loc4_);
         }
         return _loc4_;
      }
      
      public function uploadToVertexBuffer(param1:VertexBuffer3D, param2:int = 0, param3:int = -1) : void
      {
         if(param3 < 0 || param2 + param3 > this._numVertices)
         {
            param3 = this._numVertices - param2;
         }
         if(param3 > 0)
         {
            param1.uploadFromByteArray(this._rawData,0,param2,param3);
         }
      }
      
      final private function getAttribute(param1:String) : starling.rendering.VertexDataAttribute
      {
         var _loc2_:int = 0;
         var _loc3_:starling.rendering.VertexDataAttribute = null;
         _loc2_ = 0;
         while(_loc2_ < this._numAttributes)
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
      
      public function get numVertices() : int
      {
         return this._numVertices;
      }
      
      public function set numVertices(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:starling.rendering.VertexDataAttribute = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param1 > this._numVertices)
         {
            _loc2_ = this._numVertices * this.vertexSize;
            _loc3_ = param1 * this._vertexSize;
            if(this._rawData.length > _loc2_)
            {
               this._rawData.position = _loc2_;
               while(this._rawData.bytesAvailable)
               {
                  this._rawData.writeUnsignedInt(0);
               }
            }
            if(this._rawData.length < _loc3_)
            {
               this._rawData.length = _loc3_;
            }
            _loc4_ = 0;
            while(_loc4_ < this._numAttributes)
            {
               if((_loc5_ = this._attributes[_loc4_]).isColor)
               {
                  _loc6_ = this._numVertices * this._vertexSize + _loc5_.offset;
                  _loc7_ = this._numVertices;
                  while(_loc7_ < param1)
                  {
                     this._rawData.position = _loc6_;
                     this._rawData.writeUnsignedInt(4294967295);
                     _loc6_ += this._vertexSize;
                     _loc7_++;
                  }
               }
               _loc4_++;
            }
         }
         if(param1 == 0)
         {
            this._tinted = false;
         }
         this._numVertices = param1;
      }
      
      public function get rawData() : ByteArray
      {
         return this._rawData;
      }
      
      public function get format() : starling.rendering.VertexDataFormat
      {
         return this._format;
      }
      
      public function set format(param1:starling.rendering.VertexDataFormat) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:starling.rendering.VertexDataAttribute = null;
         var _loc9_:starling.rendering.VertexDataAttribute = null;
         if(this._format == param1)
         {
            return;
         }
         var _loc5_:int = this._format.vertexSize;
         var _loc6_:int = param1.vertexSize;
         var _loc7_:int = param1.numAttributes;
         sBytes.length = param1.vertexSize * this._numVertices;
         _loc2_ = 0;
         while(_loc2_ < _loc7_)
         {
            _loc8_ = param1.attributes[_loc2_];
            if(_loc9_ = this.getAttribute(_loc8_.name))
            {
               _loc4_ = _loc8_.offset;
               _loc3_ = 0;
               while(_loc3_ < this._numVertices)
               {
                  sBytes.position = _loc4_;
                  sBytes.writeBytes(this._rawData,_loc5_ * _loc3_ + _loc9_.offset,_loc9_.size);
                  _loc4_ += _loc6_;
                  _loc3_++;
               }
            }
            else if(_loc8_.isColor)
            {
               _loc4_ = _loc8_.offset;
               _loc3_ = 0;
               while(_loc3_ < this._numVertices)
               {
                  sBytes.position = _loc4_;
                  sBytes.writeUnsignedInt(4294967295);
                  _loc4_ += _loc6_;
                  _loc3_++;
               }
            }
            _loc2_++;
         }
         if(param1.vertexSize > this._format.vertexSize)
         {
            this._rawData.clear();
         }
         this._rawData.position = 0;
         this._rawData.length = sBytes.length;
         this._rawData.writeBytes(sBytes);
         sBytes.length = 0;
         this._format = param1;
         this._attributes = this._format.attributes;
         this._numAttributes = this._attributes.length;
         this._vertexSize = this._format.vertexSize;
         this._posOffset = this._format.hasAttribute("position") ? this._format.getOffset("position") : 0;
         this._colOffset = this._format.hasAttribute("color") ? this._format.getOffset("color") : 0;
      }
      
      public function get tinted() : Boolean
      {
         return this._tinted;
      }
      
      public function set tinted(param1:Boolean) : void
      {
         this._tinted = param1;
      }
      
      public function get formatString() : String
      {
         return this._format.formatString;
      }
      
      public function get vertexSize() : int
      {
         return this._vertexSize;
      }
      
      public function get vertexSizeIn32Bits() : int
      {
         return this._vertexSize / 4;
      }
      
      public function get size() : int
      {
         return this._numVertices * this._vertexSize;
      }
      
      public function get sizeIn32Bits() : int
      {
         return this._numVertices * this._vertexSize / 4;
      }
   }
}

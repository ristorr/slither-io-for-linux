package starling.display.graphics
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import starling.display.graphics.util.TriangleUtil;
   import starling.display.util.MatrixUtil;
   
   public class NGon extends starling.display.graphics.GraphicRenderer
   {
      
      private static var _uv:Point = new Point();
      
      private static var sa:Number;
      
      private static var ea:Number;
      
      private static var isEqual:Boolean;
      
      private static var sSign:int;
      
      private static var eSign:int;
      
      private static var r:Number;
      
      private static var g:Number;
      
      private static var b:Number;
      
      private static var len:int;
      
      private static var numVertices:int;
      
      private static var anglePerSide:Number;
      
      private static var cosA:Number;
      
      private static var sinB:Number;
      
      private static var s:Number;
      
      private static var c:Number;
      
      private static var i:int;
      
      private static var x:Number;
      
      private static var y:Number;
      
      private static var ns:Number;
      
      private static var nc:Number;
      
      private static var nv:int;
      
      private static var radiansPerDivision:Number;
      
      private static var startRadians:Number;
       
      
      private const DEGREES_TO_RADIANS:Number = 0.017453292519943295;
      
      private var _radius:Number;
      
      private var _innerRadius:Number;
      
      private var _startAngle:Number;
      
      private var _endAngle:Number;
      
      private var _numSides:int;
      
      private var _color:uint = 16777215;
      
      public function NGon(param1:Number = 100, param2:int = 10, param3:Number = 0, param4:Number = 0, param5:Number = 360)
      {
         super();
         this.radius = param1;
         this.numSides = param2;
         this.innerRadius = param3;
         this.startAngle = param4;
         this.endAngle = param5;
         minBounds.x = minBounds.y = -param1;
         maxBounds.x = maxBounds.y = param1;
      }
      
      private static function buildSimpleNGon(param1:Number, param2:int, param3:Vector.<Number>, param4:Vector.<uint>, param5:Matrix, param6:uint) : void
      {
         numVertices = 0;
         _uv.x = 0;
         _uv.y = 0;
         if(param5)
         {
            MatrixUtil.transformPoint(param5,_uv,_uv);
         }
         r = (param6 >> 16) / 255;
         g = ((param6 & 65280) >> 8) / 255;
         b = (param6 & 255) / 255;
         len = param3.length;
         param3[len] = 0;
         var _loc7_:*;
         param3[_loc7_ = ++len] = 0;
         var _loc8_:*;
         param3[_loc8_ = ++len] = 0;
         var _loc9_:*;
         param3[_loc9_ = ++len] = r;
         var _loc10_:*;
         param3[_loc10_ = ++len] = g;
         var _loc11_:*;
         param3[_loc11_ = ++len] = b;
         var _loc12_:*;
         param3[_loc12_ = ++len] = 1;
         var _loc13_:*;
         param3[_loc13_ = ++len] = _uv.x;
         var _loc14_:*;
         param3[_loc14_ = ++len] = _uv.y;
         ++numVertices;
         anglePerSide = Math.PI * 2 / param2;
         cosA = Math.cos(anglePerSide);
         sinB = Math.sin(anglePerSide);
         s = 0;
         c = 1;
         i = 0;
         while(i < param2)
         {
            x = s * param1;
            y = -c * param1;
            _uv.x = x;
            _uv.y = y;
            if(param5)
            {
               MatrixUtil.transformPoint(param5,_uv,_uv);
            }
            len = param3.length;
            param3[len] = x;
            var _loc15_:*;
            param3[_loc15_ = ++len] = y;
            var _loc16_:*;
            param3[_loc16_ = ++len] = 0;
            var _loc17_:*;
            param3[_loc17_ = ++len] = r;
            var _loc18_:*;
            param3[_loc18_ = ++len] = g;
            var _loc19_:*;
            param3[_loc19_ = ++len] = b;
            var _loc20_:*;
            param3[_loc20_ = ++len] = 1;
            var _loc21_:*;
            param3[_loc21_ = ++len] = _uv.x;
            var _loc22_:*;
            param3[_loc22_ = ++len] = _uv.y;
            ++numVertices;
            len = param4.length;
            param4[len] = 0;
            var _loc23_:*;
            param4[_loc23_ = ++len] = numVertices - 1;
            if(i == param2 - 1)
            {
               var _loc24_:*;
               param4[_loc24_ = ++len] = 1;
            }
            else
            {
               param4[_loc24_ = ++len] = numVertices;
            }
            ns = sinB * c + cosA * s;
            nc = cosA * c - sinB * s;
            c = nc;
            s = ns;
            ++i;
         }
      }
      
      private static function buildHoop(param1:Number, param2:Number, param3:int, param4:Vector.<Number>, param5:Vector.<uint>, param6:Matrix, param7:uint) : void
      {
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:Number = Math.PI * 2 / param3;
         var _loc10_:Number = Math.cos(_loc9_);
         var _loc11_:Number = Math.sin(_loc9_);
         var _loc12_:Number = 0;
         var _loc13_:Number = 1;
         var _loc14_:Number = (param7 >> 16) / 255;
         var _loc15_:Number = ((param7 & 65280) >> 8) / 255;
         var _loc16_:Number = (param7 & 255) / 255;
         var _loc17_:int = 0;
         while(_loc17_ < param3)
         {
            _loc18_ = _loc12_ * param2;
            _loc19_ = -_loc13_ * param2;
            _uv.x = _loc18_;
            _uv.y = _loc19_;
            if(param6)
            {
               MatrixUtil.transformPoint(param6,_uv,_uv);
            }
            param4.push(_loc18_,_loc19_,0,_loc14_,_loc15_,_loc16_,1,_uv.x,_uv.y);
            _loc8_++;
            _loc18_ = _loc12_ * param1;
            _loc19_ = -_loc13_ * param1;
            _uv.x = _loc18_;
            _uv.y = _loc19_;
            if(param6)
            {
               MatrixUtil.transformPoint(param6,_uv,_uv);
            }
            param4.push(_loc18_,_loc19_,0,_loc14_,_loc15_,_loc16_,1,_uv.x,_uv.y);
            _loc8_++;
            if(_loc17_ == param3 - 1)
            {
               param5.push(_loc8_ - 2,_loc8_ - 1,0,0,_loc8_ - 1,1);
            }
            else
            {
               param5.push(_loc8_ - 2,_loc8_,_loc8_ - 1,_loc8_,_loc8_ + 1,_loc8_ - 1);
            }
            _loc20_ = _loc11_ * _loc13_ + _loc10_ * _loc12_;
            _loc13_ = _loc21_ = _loc10_ * _loc13_ - _loc11_ * _loc12_;
            _loc12_ = _loc20_;
            _loc17_++;
         }
      }
      
      private static function buildFan(param1:Number, param2:Number, param3:Number, param4:int, param5:Vector.<Number>, param6:Vector.<uint>, param7:Matrix, param8:uint) : void
      {
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:Number = (param8 >> 16) / 255;
         var _loc11_:Number = ((param8 & 65280) >> 8) / 255;
         var _loc12_:Number = (param8 & 255) / 255;
         param5.push(0,0,0,_loc10_,_loc11_,_loc12_,1,0.5,0.5);
         _loc9_++;
         var _loc13_:Number = Math.PI * 2 / param4;
         var _loc14_:Number = (_loc14_ = (_loc14_ = param2 / _loc13_) < 0 ? -Math.ceil(-_loc14_) : int(_loc14_)) * _loc13_;
         var _loc15_:int = 0;
         while(_loc15_ <= param4 + 1)
         {
            if((_loc17_ = (_loc16_ = _loc14_ + _loc15_ * _loc13_) + _loc13_) >= param2)
            {
               _loc18_ = Math.sin(_loc16_) * param1;
               _loc19_ = -Math.cos(_loc16_) * param1;
               _loc20_ = _loc16_ - _loc13_;
               if(_loc16_ < param2 && _loc17_ > param2)
               {
                  _loc22_ = Math.sin(_loc17_) * param1;
                  _loc23_ = -Math.cos(_loc17_) * param1;
                  _loc21_ = (param2 - _loc16_) / _loc13_;
                  _loc18_ += _loc21_ * (_loc22_ - _loc18_);
                  _loc19_ += _loc21_ * (_loc23_ - _loc19_);
               }
               else if(_loc16_ > param3 && _loc20_ < param3)
               {
                  _loc24_ = Math.sin(_loc20_) * param1;
                  _loc25_ = -Math.cos(_loc20_) * param1;
                  _loc21_ = (param3 - _loc20_) / _loc13_;
                  _loc18_ = _loc24_ + _loc21_ * (_loc18_ - _loc24_);
                  _loc19_ = _loc25_ + _loc21_ * (_loc19_ - _loc25_);
               }
               _uv.x = _loc18_;
               _uv.y = _loc19_;
               if(param7)
               {
                  MatrixUtil.transformPoint(param7,_uv,_uv);
               }
               param5.push(_loc18_,_loc19_,0,_loc10_,_loc11_,_loc12_,1,_uv.x,_uv.y);
               _loc9_++;
               if(param5.length > 2 * 9)
               {
                  param6.push(0,_loc9_ - 2,_loc9_ - 1);
               }
               if(_loc16_ >= param3)
               {
                  break;
               }
            }
            _loc15_++;
         }
      }
      
      private static function buildArc(param1:Number, param2:Number, param3:Number, param4:Number, param5:int, param6:Vector.<Number>, param7:Vector.<uint>, param8:Matrix, param9:uint) : void
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         nv = 0;
         radiansPerDivision = Math.PI * 2 / param5;
         startRadians = param3 / radiansPerDivision;
         startRadians = startRadians < 0 ? -Math.ceil(-startRadians) : int(startRadians);
         startRadians *= radiansPerDivision;
         r = (param9 >> 16) / 255;
         g = ((param9 & 65280) >> 8) / 255;
         b = (param9 & 255) / 255;
         i = 0;
         while(i <= param5 + 1)
         {
            if((_loc11_ = (_loc10_ = startRadians + i * radiansPerDivision) + radiansPerDivision) >= param3)
            {
               _loc12_ = Math.sin(_loc10_);
               _loc13_ = Math.cos(_loc10_);
               _loc14_ = _loc12_ * param2;
               _loc15_ = -_loc13_ * param2;
               _loc16_ = _loc12_ * param1;
               _loc17_ = -_loc13_ * param1;
               _loc18_ = _loc10_ - radiansPerDivision;
               if(_loc10_ < param3 && _loc11_ > param3)
               {
                  _loc12_ = Math.sin(_loc11_);
                  _loc13_ = Math.cos(_loc11_);
                  _loc20_ = _loc12_ * param2;
                  _loc21_ = -_loc13_ * param2;
                  _loc22_ = _loc12_ * param1;
                  _loc23_ = -_loc13_ * param1;
                  _loc19_ = (param3 - _loc10_) / radiansPerDivision;
                  _loc14_ += _loc19_ * (_loc20_ - _loc14_);
                  _loc15_ += _loc19_ * (_loc21_ - _loc15_);
                  _loc16_ += _loc19_ * (_loc22_ - _loc16_);
                  _loc17_ += _loc19_ * (_loc23_ - _loc17_);
               }
               else if(_loc10_ > param4 && _loc18_ < param4)
               {
                  _loc12_ = Math.sin(_loc18_);
                  _loc13_ = Math.cos(_loc18_);
                  _loc24_ = _loc12_ * param2;
                  _loc25_ = -_loc13_ * param2;
                  _loc26_ = _loc12_ * param1;
                  _loc27_ = -_loc13_ * param1;
                  _loc19_ = (param4 - _loc18_) / radiansPerDivision;
                  _loc14_ = _loc24_ + _loc19_ * (_loc14_ - _loc24_);
                  _loc15_ = _loc25_ + _loc19_ * (_loc15_ - _loc25_);
                  _loc16_ = _loc26_ + _loc19_ * (_loc16_ - _loc26_);
                  _loc17_ = _loc27_ + _loc19_ * (_loc17_ - _loc27_);
               }
               _uv.x = _loc14_;
               _uv.y = _loc15_;
               if(param8)
               {
                  MatrixUtil.transformPoint(param8,_uv,_uv);
               }
               param6.push(_loc14_,_loc15_,0,r,g,b,1,_uv.x,_uv.y);
               ++nv;
               _uv.x = _loc16_;
               _uv.y = _loc17_;
               if(param8)
               {
                  MatrixUtil.transformPoint(param8,_uv,_uv);
               }
               param6.push(_loc16_,_loc17_,0,r,g,b,1,_uv.x,_uv.y);
               ++nv;
               if(param6.length > 3 * 9)
               {
                  param7.push(nv - 3,nv - 2,nv - 1,nv - 3,nv - 4,nv - 2);
               }
               if(_loc10_ >= param4)
               {
                  break;
               }
            }
            ++i;
         }
      }
      
      public function get endAngle() : Number
      {
         return this._endAngle;
      }
      
      public function set endAngle(param1:Number) : void
      {
         this._endAngle = param1;
         setGeometryInvalid();
      }
      
      public function get startAngle() : Number
      {
         return this._startAngle;
      }
      
      public function set startAngle(param1:Number) : void
      {
         this._startAngle = param1;
         setGeometryInvalid();
      }
      
      public function get radius() : Number
      {
         return this._radius;
      }
      
      public function set color(param1:uint) : void
      {
         this._color = param1;
         setGeometryInvalid();
      }
      
      public function set radius(param1:Number) : void
      {
         param1 = param1 < 0 ? 0 : param1;
         this._radius = param1;
         var _loc2_:Number = Math.max(this._radius,this._innerRadius);
         minBounds.x = minBounds.y = -_loc2_;
         maxBounds.x = maxBounds.y = _loc2_;
         setGeometryInvalid();
      }
      
      public function get innerRadius() : Number
      {
         return this._innerRadius;
      }
      
      public function set innerRadius(param1:Number) : void
      {
         param1 = param1 < 0 ? 0 : param1;
         this._innerRadius = param1;
         var _loc2_:Number = Math.max(this._radius,this._innerRadius);
         minBounds.x = minBounds.y = -_loc2_;
         maxBounds.x = maxBounds.y = _loc2_;
         setGeometryInvalid();
      }
      
      public function get numSides() : int
      {
         return this._numSides;
      }
      
      public function set numSides(param1:int) : void
      {
         param1 = param1 < 3 ? 3 : param1;
         this._numSides = param1;
         setGeometryInvalid();
      }
      
      override protected function buildGeometry() : void
      {
         vertices.length = 0;
         indices.length = 0;
         sa = this._startAngle;
         ea = this._endAngle;
         isEqual = sa == ea;
         sSign = sa < 0 ? -1 : 1;
         eSign = ea < 0 ? -1 : 1;
         sa *= sSign;
         ea *= eSign;
         ea %= 360;
         ea *= eSign;
         sa %= 360;
         if(ea < sa)
         {
            ea += 360;
         }
         sa *= sSign * this.DEGREES_TO_RADIANS;
         ea *= this.DEGREES_TO_RADIANS;
         if(ea - sa > Math.PI * 2)
         {
            ea -= Math.PI * 2;
         }
         var _loc1_:Number = this._innerRadius < this._radius ? this._innerRadius : this._radius;
         var _loc2_:Number = this._radius > this._innerRadius ? this._radius : this._innerRadius;
         var _loc3_:Boolean = sa != 0 || ea != 0;
         if(_loc3_ == false)
         {
            _loc3_ = isEqual;
         }
         if(_loc1_ == 0 && !_loc3_)
         {
            buildSimpleNGon(_loc2_,this._numSides,vertices,indices,_uvMatrix,this._color);
         }
         else if(_loc1_ != 0 && !_loc3_)
         {
            buildHoop(_loc1_,_loc2_,this._numSides,vertices,indices,_uvMatrix,this._color);
         }
         else if(_loc1_ == 0)
         {
            buildFan(_loc2_,sa,ea,this._numSides,vertices,indices,_uvMatrix,this._color);
         }
         else
         {
            buildArc(_loc1_,_loc2_,sa,ea,this._numSides,vertices,indices,_uvMatrix,this._color);
         }
      }
      
      override protected function shapeHitTestLocalInternal(param1:Number, param2:Number) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc3_:int = int(indices.length);
         if(_loc3_ < 2)
         {
            validateNow();
            _loc3_ = int(indices.length);
            if(_loc3_ < 2)
            {
               return false;
            }
         }
         if(this._innerRadius == 0 && this._radius > 0 && this._startAngle == 0 && this._endAngle == 360 && this._numSides > 20)
         {
            if(Math.sqrt(param1 * param1 + param2 * param2) < this._radius)
            {
               return true;
            }
            return false;
         }
         i = 2;
         while(i < _loc3_)
         {
            _loc4_ = int(indices[i - 2]);
            _loc5_ = int(indices[i - 1]);
            _loc6_ = int(indices[i - 0]);
            _loc7_ = vertices[VERTEX_STRIDE * _loc4_ + 0];
            _loc8_ = vertices[VERTEX_STRIDE * _loc4_ + 1];
            _loc9_ = vertices[VERTEX_STRIDE * _loc5_ + 0];
            _loc10_ = vertices[VERTEX_STRIDE * _loc5_ + 1];
            _loc11_ = vertices[VERTEX_STRIDE * _loc6_ + 0];
            _loc12_ = vertices[VERTEX_STRIDE * _loc6_ + 1];
            if(TriangleUtil.isPointInTriangle(_loc7_,_loc8_,_loc9_,_loc10_,_loc11_,_loc12_,param1,param2))
            {
               return true;
            }
            i += 3;
         }
         return false;
      }
   }
}

package starling.geom
{
   import flash.geom.Point;
   import flash.utils.getQualifiedClassName;
   import starling.rendering.IndexData;
   import starling.rendering.VertexData;
   import starling.utils.MathUtil;
   import starling.utils.Pool;
   
   public class Polygon
   {
      
      private static var sRestIndices:Vector.<uint> = new Vector.<uint>(0);
       
      
      private var _coords:Vector.<Number>;
      
      public function Polygon(param1:Array = null)
      {
         super();
         this._coords = new Vector.<Number>(0);
         this.addVertices.apply(this,param1);
      }
      
      public static function createEllipse(param1:Number, param2:Number, param3:Number, param4:Number, param5:int = -1) : starling.geom.Polygon
      {
         return new Ellipse(param1,param2,param3,param4,param5);
      }
      
      public static function createCircle(param1:Number, param2:Number, param3:Number, param4:int = -1) : starling.geom.Polygon
      {
         return new Ellipse(param1,param2,param3,param3,param4);
      }
      
      public static function createRectangle(param1:Number, param2:Number, param3:Number, param4:Number) : starling.geom.Polygon
      {
         return new Rectangle(param1,param2,param3,param4);
      }
      
      private static function isConvexTriangle(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : Boolean
      {
         return (param2 - param4) * (param5 - param3) + (param3 - param1) * (param6 - param4) >= 0;
      }
      
      private static function areVectorsIntersecting(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : Boolean
      {
         if(param1 == param3 && param2 == param4 || param5 == param7 && param6 == param8)
         {
            return false;
         }
         var _loc9_:Number = param3 - param1;
         var _loc10_:Number = param4 - param2;
         var _loc11_:Number = param7 - param5;
         var _loc13_:Number;
         var _loc12_:Number;
         if((_loc13_ = (_loc12_ = param8 - param6) * _loc9_ - _loc11_ * _loc10_) == 0)
         {
            return false;
         }
         var _loc14_:Number;
         if((_loc14_ = (_loc10_ * (param5 - param1) - _loc9_ * (param6 - param2)) / _loc13_) < 0 || _loc14_ > 1)
         {
            return false;
         }
         var _loc15_:Number;
         return (_loc15_ = !!_loc10_ ? (param6 - param2 + _loc14_ * _loc12_) / _loc10_ : (param5 - param1 + _loc14_ * _loc11_) / _loc9_) >= 0 && _loc15_ <= 1;
      }
      
      public function clone() : starling.geom.Polygon
      {
         var _loc1_:starling.geom.Polygon = new starling.geom.Polygon();
         var _loc2_:int = int(this._coords.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_._coords[_loc3_] = this._coords[_loc3_];
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function reverse() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:int = int(this._coords.length);
         var _loc2_:int = _loc1_ / 2;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_ = this._coords[_loc4_];
            this._coords[_loc4_] = this._coords[_loc1_ - _loc4_ - 2];
            this._coords[_loc1_ - _loc4_ - 2] = _loc3_;
            _loc3_ = this._coords[_loc4_ + 1];
            this._coords[_loc4_ + 1] = this._coords[_loc1_ - _loc4_ - 1];
            this._coords[_loc1_ - _loc4_ - 1] = _loc3_;
            _loc4_ += 2;
         }
      }
      
      public function addVertices(... rest) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(rest.length);
         var _loc4_:int = int(this._coords.length);
         if(_loc3_ > 0)
         {
            if(rest[0] is Point)
            {
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  this._coords[_loc4_ + _loc2_ * 2] = (rest[_loc2_] as Point).x;
                  this._coords[_loc4_ + _loc2_ * 2 + 1] = (rest[_loc2_] as Point).y;
                  _loc2_++;
               }
            }
            else
            {
               if(!(rest[0] is Number))
               {
                  throw new ArgumentError("Invalid type: " + getQualifiedClassName(rest[0]));
               }
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  this._coords[_loc4_ + _loc2_] = rest[_loc2_];
                  _loc2_++;
               }
            }
         }
      }
      
      public function setVertex(param1:int, param2:Number, param3:Number) : void
      {
         if(param1 >= 0 && param1 <= this.numVertices)
         {
            this._coords[param1 * 2] = param2;
            this._coords[param1 * 2 + 1] = param3;
            return;
         }
         throw new RangeError("Invalid index: " + param1);
      }
      
      public function getVertex(param1:int, param2:Point = null) : Point
      {
         if(param1 >= 0 && param1 < this.numVertices)
         {
            param2 ||= new Point();
            param2.setTo(this._coords[param1 * 2],this._coords[param1 * 2 + 1]);
            return param2;
         }
         throw new RangeError("Invalid index: " + param1);
      }
      
      public function contains(param1:Number, param2:Number) : Boolean
      {
         var _loc4_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc3_:int = this.numVertices;
         var _loc5_:int = _loc3_ - 1;
         var _loc6_:uint = 0;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc7_ = this._coords[_loc4_ * 2];
            _loc8_ = this._coords[_loc4_ * 2 + 1];
            _loc9_ = this._coords[_loc5_ * 2];
            _loc10_ = this._coords[_loc5_ * 2 + 1];
            if((_loc8_ < param2 && _loc10_ >= param2 || _loc10_ < param2 && _loc8_ >= param2) && (_loc7_ <= param1 || _loc9_ <= param1))
            {
               _loc6_ ^= uint(_loc7_ + (param2 - _loc8_) / (_loc10_ - _loc8_) * (_loc9_ - _loc7_) < param1);
            }
            _loc5_ = _loc4_;
            _loc4_++;
         }
         return _loc6_ != 0;
      }
      
      public function containsPoint(param1:Point) : Boolean
      {
         return this.contains(param1.x,param1.y);
      }
      
      public function triangulate(param1:IndexData = null, param2:int = 0) : IndexData
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc12_:uint = 0;
         var _loc13_:Boolean = false;
         var _loc14_:uint = 0;
         var _loc15_:uint = 0;
         var _loc16_:uint = 0;
         var _loc3_:int = this.numVertices;
         var _loc4_:int = this.numTriangles;
         if(param1 == null)
         {
            param1 = new IndexData(_loc4_ * 3);
         }
         if(_loc4_ == 0)
         {
            return param1;
         }
         sRestIndices.length = _loc3_;
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            sRestIndices[_loc5_] = _loc5_;
            _loc5_++;
         }
         _loc6_ = 0;
         _loc7_ = _loc3_;
         var _loc8_:Point = Pool.getPoint();
         var _loc9_:Point = Pool.getPoint();
         var _loc10_:Point = Pool.getPoint();
         var _loc11_:Point = Pool.getPoint();
         while(_loc7_ > 3)
         {
            _loc13_ = false;
            _loc14_ = sRestIndices[_loc6_ % _loc7_];
            _loc15_ = sRestIndices[(_loc6_ + 1) % _loc7_];
            _loc16_ = sRestIndices[(_loc6_ + 2) % _loc7_];
            _loc8_.setTo(this._coords[2 * _loc14_],this._coords[2 * _loc14_ + 1]);
            _loc9_.setTo(this._coords[2 * _loc15_],this._coords[2 * _loc15_ + 1]);
            _loc10_.setTo(this._coords[2 * _loc16_],this._coords[2 * _loc16_ + 1]);
            if(isConvexTriangle(_loc8_.x,_loc8_.y,_loc9_.x,_loc9_.y,_loc10_.x,_loc10_.y))
            {
               _loc13_ = true;
               _loc5_ = 3;
               while(_loc5_ < _loc7_)
               {
                  _loc12_ = sRestIndices[(_loc6_ + _loc5_) % _loc7_];
                  _loc11_.setTo(this._coords[2 * _loc12_],this._coords[2 * _loc12_ + 1]);
                  if(MathUtil.isPointInTriangle(_loc11_,_loc8_,_loc9_,_loc10_))
                  {
                     _loc13_ = false;
                     break;
                  }
                  _loc5_++;
               }
            }
            if(_loc13_)
            {
               param1.addTriangle(_loc14_ + param2,_loc15_ + param2,_loc16_ + param2);
               sRestIndices.removeAt((_loc6_ + 1) % _loc7_);
               _loc7_--;
               _loc6_ = 0;
            }
            else
            {
               _loc6_++;
               if(_loc6_ == _loc7_)
               {
                  break;
               }
            }
         }
         Pool.putPoint(_loc8_);
         Pool.putPoint(_loc9_);
         Pool.putPoint(_loc10_);
         Pool.putPoint(_loc11_);
         param1.addTriangle(sRestIndices[0] + param2,sRestIndices[1] + param2,sRestIndices[2] + param2);
         return param1;
      }
      
      public function copyToVertexData(param1:VertexData = null, param2:int = 0, param3:String = "position") : void
      {
         var _loc4_:int = this.numVertices;
         var _loc5_:int = param2 + _loc4_;
         if(param1.numVertices < _loc5_)
         {
            param1.numVertices = _loc5_;
         }
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_)
         {
            param1.setPoint(param2 + _loc6_,param3,this._coords[_loc6_ * 2],this._coords[_loc6_ * 2 + 1]);
            _loc6_++;
         }
      }
      
      public function toString() : String
      {
         var _loc1_:* = "[Polygon";
         var _loc2_:int = this.numVertices;
         if(_loc2_ > 0)
         {
            _loc1_ += "\n";
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ += "  [Vertex " + _loc3_ + ": " + "x=" + this._coords[_loc3_ * 2].toFixed(1) + ", " + "y=" + this._coords[_loc3_ * 2 + 1].toFixed(1) + "]" + (_loc3_ == _loc2_ - 1 ? "\n" : ",\n");
            _loc3_++;
         }
         return _loc1_ + "]";
      }
      
      public function get isSimple() : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc1_:int = int(this._coords.length);
         if(_loc1_ <= 6)
         {
            return true;
         }
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this._coords[_loc2_];
            _loc4_ = this._coords[_loc2_ + 1];
            _loc5_ = this._coords[(_loc2_ + 2) % _loc1_];
            _loc6_ = this._coords[(_loc2_ + 3) % _loc1_];
            _loc7_ = _loc2_ + _loc1_ - 2;
            _loc8_ = _loc2_ + 4;
            while(_loc8_ < _loc7_)
            {
               _loc9_ = this._coords[_loc8_ % _loc1_];
               _loc10_ = this._coords[(_loc8_ + 1) % _loc1_];
               _loc11_ = this._coords[(_loc8_ + 2) % _loc1_];
               _loc12_ = this._coords[(_loc8_ + 3) % _loc1_];
               if(areVectorsIntersecting(_loc3_,_loc4_,_loc5_,_loc6_,_loc9_,_loc10_,_loc11_,_loc12_))
               {
                  return false;
               }
               _loc8_ += 2;
            }
            _loc2_ += 2;
         }
         return true;
      }
      
      public function get isConvex() : Boolean
      {
         var _loc2_:int = 0;
         var _loc1_:int = int(this._coords.length);
         if(_loc1_ < 6)
         {
            return true;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(!isConvexTriangle(this._coords[_loc2_],this._coords[_loc2_ + 1],this._coords[(_loc2_ + 2) % _loc1_],this._coords[(_loc2_ + 3) % _loc1_],this._coords[(_loc2_ + 4) % _loc1_],this._coords[(_loc2_ + 5) % _loc1_]))
            {
               return false;
            }
            _loc2_ += 2;
         }
         return true;
      }
      
      public function get area() : Number
      {
         var _loc3_:int = 0;
         var _loc1_:Number = 0;
         var _loc2_:int = int(this._coords.length);
         if(_loc2_ >= 6)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc1_ += this._coords[_loc3_] * this._coords[(_loc3_ + 3) % _loc2_];
               _loc1_ -= this._coords[_loc3_ + 1] * this._coords[(_loc3_ + 2) % _loc2_];
               _loc3_ += 2;
            }
         }
         return _loc1_ / 2;
      }
      
      public function get numVertices() : int
      {
         return this._coords.length / 2;
      }
      
      public function set numVertices(param1:int) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = this.numVertices;
         this._coords.length = param1 * 2;
         if(_loc2_ < param1)
         {
            _loc3_ = _loc2_;
            while(_loc3_ < param1)
            {
               this._coords[_loc3_ * 2] = this._coords[_loc3_ * 2 + 1] = 0;
               _loc3_++;
            }
         }
      }
      
      public function get numTriangles() : int
      {
         var _loc1_:int = this.numVertices;
         return _loc1_ >= 3 ? _loc1_ - 2 : 0;
      }
   }
}

import flash.errors.IllegalOperationError;
import flash.utils.getQualifiedClassName;
import starling.geom.Polygon;

class ImmutablePolygon extends Polygon
{
    
   
   private var _frozen:Boolean;
   
   public function ImmutablePolygon(param1:Array)
   {
      super(param1);
      this._frozen = true;
   }
   
   override public function addVertices(... rest) : void
   {
      if(this._frozen)
      {
         throw this.getImmutableError();
      }
      super.addVertices.apply(this,rest);
   }
   
   override public function setVertex(param1:int, param2:Number, param3:Number) : void
   {
      if(this._frozen)
      {
         throw this.getImmutableError();
      }
      super.setVertex(param1,param2,param3);
   }
   
   override public function reverse() : void
   {
      if(this._frozen)
      {
         throw this.getImmutableError();
      }
      super.reverse();
   }
   
   override public function set numVertices(param1:int) : void
   {
      if(this._frozen)
      {
         throw this.getImmutableError();
      }
      super.reverse();
   }
   
   private function getImmutableError() : Error
   {
      var _loc1_:String = getQualifiedClassName(this).split("::").pop();
      var _loc2_:* = _loc1_ + " cannot be modified. Call \'clone\' to create a mutable copy.";
      return new IllegalOperationError(_loc2_);
   }
}

import starling.rendering.IndexData;

class Ellipse extends ImmutablePolygon
{
    
   
   private var _x:Number;
   
   private var _y:Number;
   
   private var _radiusX:Number;
   
   private var _radiusY:Number;
   
   public function Ellipse(param1:Number, param2:Number, param3:Number, param4:Number, param5:int = -1)
   {
      this._x = param1;
      this._y = param2;
      this._radiusX = param3;
      this._radiusY = param4;
      super(this.getVertices(param5));
   }
   
   private function getVertices(param1:int) : Array
   {
      if(param1 < 0)
      {
         param1 = Math.PI * (this._radiusX + this._radiusY) / 4;
      }
      if(param1 < 6)
      {
         param1 = 6;
      }
      var _loc2_:Array = [];
      var _loc3_:Number = 2 * Math.PI / param1;
      var _loc4_:Number = 0;
      var _loc5_:int = 0;
      while(_loc5_ < param1)
      {
         _loc2_[_loc5_ * 2] = Math.cos(_loc4_) * this._radiusX + this._x;
         _loc2_[_loc5_ * 2 + 1] = Math.sin(_loc4_) * this._radiusY + this._y;
         _loc4_ += _loc3_;
         _loc5_++;
      }
      return _loc2_;
   }
   
   override public function triangulate(param1:IndexData = null, param2:int = 0) : IndexData
   {
      if(param1 == null)
      {
         param1 = new IndexData((numVertices - 2) * 3);
      }
      var _loc3_:uint = 1;
      var _loc4_:uint = numVertices - 1;
      var _loc5_:int = int(_loc3_);
      while(_loc5_ < _loc4_)
      {
         param1.addTriangle(param2,param2 + _loc5_,param2 + _loc5_ + 1);
         _loc5_++;
      }
      return param1;
   }
   
   override public function contains(param1:Number, param2:Number) : Boolean
   {
      var _loc3_:Number = param1 - this._x;
      var _loc4_:Number = param2 - this._y;
      var _loc5_:Number = _loc3_ / this._radiusX;
      var _loc6_:Number = _loc4_ / this._radiusY;
      return _loc5_ * _loc5_ + _loc6_ * _loc6_ <= 1;
   }
   
   override public function get area() : Number
   {
      return Math.PI * this._radiusX * this._radiusY;
   }
   
   override public function get isSimple() : Boolean
   {
      return true;
   }
   
   override public function get isConvex() : Boolean
   {
      return true;
   }
}

import starling.rendering.IndexData;

class Rectangle extends ImmutablePolygon
{
    
   
   private var _x:Number;
   
   private var _y:Number;
   
   private var _width:Number;
   
   private var _height:Number;
   
   public function Rectangle(param1:Number, param2:Number, param3:Number, param4:Number)
   {
      this._x = param1;
      this._y = param2;
      this._width = param3;
      this._height = param4;
      super([param1,param2,param1 + param3,param2,param1 + param3,param2 + param4,param1,param2 + param4]);
   }
   
   override public function triangulate(param1:IndexData = null, param2:int = 0) : IndexData
   {
      if(param1 == null)
      {
         param1 = new IndexData(6);
      }
      param1.addTriangle(param2,param2 + 1,param2 + 3);
      param1.addTriangle(param2 + 1,param2 + 2,param2 + 3);
      return param1;
   }
   
   override public function contains(param1:Number, param2:Number) : Boolean
   {
      return param1 >= this._x && param1 <= this._x + this._width && param2 >= this._y && param2 <= this._y + this._height;
   }
   
   override public function get area() : Number
   {
      return this._width * this._height;
   }
   
   override public function get isSimple() : Boolean
   {
      return true;
   }
   
   override public function get isConvex() : Boolean
   {
      return true;
   }
}

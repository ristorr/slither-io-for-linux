package starling.utils
{
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import starling.errors.AbstractClassError;
   
   public class RectangleUtil
   {
      
      private static const sPoint:Point = new Point();
      
      private static const sPoint3D:Vector3D = new Vector3D();
      
      private static const sPositions:Vector.<Point> = new <Point>[new Point(),new Point(),new Point(),new Point()];
       
      
      public function RectangleUtil()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function intersect(param1:flash.geom.Rectangle, param2:flash.geom.Rectangle, param3:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         if(param3 == null)
         {
            param3 = new flash.geom.Rectangle();
         }
         var _loc4_:Number = param1.x > param2.x ? param1.x : param2.x;
         var _loc5_:Number = param1.right < param2.right ? param1.right : param2.right;
         var _loc6_:Number = param1.y > param2.y ? param1.y : param2.y;
         var _loc7_:Number = param1.bottom < param2.bottom ? param1.bottom : param2.bottom;
         if(_loc4_ > _loc5_ || _loc6_ > _loc7_)
         {
            param3.setEmpty();
         }
         else
         {
            param3.setTo(_loc4_,_loc6_,_loc5_ - _loc4_,_loc7_ - _loc6_);
         }
         return param3;
      }
      
      public static function fit(param1:flash.geom.Rectangle, param2:flash.geom.Rectangle, param3:String = "showAll", param4:Boolean = false, param5:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         if(!starling.utils.ScaleMode.isValid(param3))
         {
            throw new ArgumentError("Invalid scaleMode: " + param3);
         }
         if(param5 == null)
         {
            param5 = new flash.geom.Rectangle();
         }
         var _loc6_:Number = param1.width;
         var _loc7_:Number = param1.height;
         var _loc8_:Number = param2.width / _loc6_;
         var _loc9_:Number = param2.height / _loc7_;
         var _loc10_:Number = 1;
         if(param3 == starling.utils.ScaleMode.SHOW_ALL)
         {
            _loc10_ = _loc8_ < _loc9_ ? _loc8_ : _loc9_;
            if(param4)
            {
               _loc10_ = nextSuitableScaleFactor(_loc10_,false);
            }
         }
         else if(param3 == starling.utils.ScaleMode.NO_BORDER)
         {
            _loc10_ = _loc8_ > _loc9_ ? _loc8_ : _loc9_;
            if(param4)
            {
               _loc10_ = nextSuitableScaleFactor(_loc10_,true);
            }
         }
         _loc6_ *= _loc10_;
         _loc7_ *= _loc10_;
         param5.setTo(param2.x + (param2.width - _loc6_) / 2,param2.y + (param2.height - _loc7_) / 2,_loc6_,_loc7_);
         return param5;
      }
      
      private static function nextSuitableScaleFactor(param1:Number, param2:Boolean) : Number
      {
         var _loc3_:Number = 1;
         if(param2)
         {
            if(param1 >= 0.5)
            {
               return Math.ceil(param1);
            }
            while(1 / (_loc3_ + 1) > param1)
            {
               _loc3_++;
            }
         }
         else
         {
            if(param1 >= 1)
            {
               return Math.floor(param1);
            }
            while(1 / _loc3_ > param1)
            {
               _loc3_++;
            }
         }
         return 1 / _loc3_;
      }
      
      public static function normalize(param1:flash.geom.Rectangle) : void
      {
         if(param1.width < 0)
         {
            param1.width = -param1.width;
            param1.x -= param1.width;
         }
         if(param1.height < 0)
         {
            param1.height = -param1.height;
            param1.y -= param1.height;
         }
      }
      
      public static function extend(param1:flash.geom.Rectangle, param2:Number = 0, param3:Number = 0, param4:Number = 0, param5:Number = 0) : void
      {
         param1.x -= param2;
         param1.y -= param4;
         param1.width += param2 + param3;
         param1.height += param4 + param5;
      }
      
      public static function extendToWholePixels(param1:flash.geom.Rectangle, param2:Number = 1) : void
      {
         var _loc3_:Number = Math.floor(param1.x * param2) / param2;
         var _loc4_:Number = Math.floor(param1.y * param2) / param2;
         var _loc5_:Number = Math.ceil(param1.right * param2) / param2;
         var _loc6_:Number = Math.ceil(param1.bottom * param2) / param2;
         param1.setTo(_loc3_,_loc4_,_loc5_ - _loc3_,_loc6_ - _loc4_);
      }
      
      public static function getBounds(param1:flash.geom.Rectangle, param2:Matrix, param3:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         if(param3 == null)
         {
            param3 = new flash.geom.Rectangle();
         }
         var _loc4_:Number = Number.MAX_VALUE;
         var _loc5_:Number = -Number.MAX_VALUE;
         var _loc6_:Number = Number.MAX_VALUE;
         var _loc7_:Number = -Number.MAX_VALUE;
         var _loc8_:Vector.<Point> = getPositions(param1,sPositions);
         var _loc9_:int = 0;
         while(_loc9_ < 4)
         {
            starling.utils.MatrixUtil.transformCoords(param2,_loc8_[_loc9_].x,_loc8_[_loc9_].y,sPoint);
            if(_loc4_ > sPoint.x)
            {
               _loc4_ = sPoint.x;
            }
            if(_loc5_ < sPoint.x)
            {
               _loc5_ = sPoint.x;
            }
            if(_loc6_ > sPoint.y)
            {
               _loc6_ = sPoint.y;
            }
            if(_loc7_ < sPoint.y)
            {
               _loc7_ = sPoint.y;
            }
            _loc9_++;
         }
         param3.setTo(_loc4_,_loc6_,_loc5_ - _loc4_,_loc7_ - _loc6_);
         return param3;
      }
      
      public static function getBoundsProjected(param1:flash.geom.Rectangle, param2:Matrix3D, param3:Vector3D, param4:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         var _loc11_:Point = null;
         if(param4 == null)
         {
            param4 = new flash.geom.Rectangle();
         }
         if(param3 == null)
         {
            throw new ArgumentError("camPos must not be null");
         }
         var _loc5_:Number = Number.MAX_VALUE;
         var _loc6_:Number = -Number.MAX_VALUE;
         var _loc7_:Number = Number.MAX_VALUE;
         var _loc8_:Number = -Number.MAX_VALUE;
         var _loc9_:Vector.<Point> = getPositions(param1,sPositions);
         var _loc10_:int = 0;
         while(_loc10_ < 4)
         {
            _loc11_ = _loc9_[_loc10_];
            if(param2)
            {
               starling.utils.MatrixUtil.transformCoords3D(param2,_loc11_.x,_loc11_.y,0,sPoint3D);
            }
            else
            {
               sPoint3D.setTo(_loc11_.x,_loc11_.y,0);
            }
            starling.utils.MathUtil.intersectLineWithXYPlane(param3,sPoint3D,sPoint);
            if(_loc5_ > sPoint.x)
            {
               _loc5_ = sPoint.x;
            }
            if(_loc6_ < sPoint.x)
            {
               _loc6_ = sPoint.x;
            }
            if(_loc7_ > sPoint.y)
            {
               _loc7_ = sPoint.y;
            }
            if(_loc8_ < sPoint.y)
            {
               _loc8_ = sPoint.y;
            }
            _loc10_++;
         }
         param4.setTo(_loc5_,_loc7_,_loc6_ - _loc5_,_loc8_ - _loc7_);
         return param4;
      }
      
      public static function getPositions(param1:flash.geom.Rectangle, param2:Vector.<Point> = null) : Vector.<Point>
      {
         if(param2 == null)
         {
            param2 = new Vector.<Point>(4,true);
         }
         var _loc3_:int = 0;
         while(_loc3_ < 4)
         {
            if(param2[_loc3_] == null)
            {
               param2[_loc3_] = new Point();
            }
            _loc3_++;
         }
         param2[0].x = param1.left;
         param2[0].y = param1.top;
         param2[1].x = param1.right;
         param2[1].y = param1.top;
         param2[2].x = param1.left;
         param2[2].y = param1.bottom;
         param2[3].x = param1.right;
         param2[3].y = param1.bottom;
         return param2;
      }
      
      public static function compare(param1:flash.geom.Rectangle, param2:flash.geom.Rectangle, param3:Number = 0.0001) : Boolean
      {
         if(param1 == null)
         {
            return param2 == null;
         }
         if(param2 == null)
         {
            return false;
         }
         return param1.x > param2.x - param3 && param1.x < param2.x + param3 && param1.y > param2.y - param3 && param1.y < param2.y + param3 && param1.width > param2.width - param3 && param1.width < param2.width + param3 && param1.height > param2.height - param3 && param1.height < param2.height + param3;
      }
   }
}

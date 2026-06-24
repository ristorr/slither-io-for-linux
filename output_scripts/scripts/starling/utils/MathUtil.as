package starling.utils
{
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import starling.errors.AbstractClassError;
   
   public class MathUtil
   {
      
      private static const TWO_PI:Number = Math.PI * 2;
       
      
      public function MathUtil()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function intersectLineWithXYPlane(param1:Vector3D, param2:Vector3D, param3:Point = null) : Point
      {
         if(param3 == null)
         {
            param3 = new Point();
         }
         var _loc4_:Number = param2.x - param1.x;
         var _loc5_:Number = param2.y - param1.y;
         var _loc6_:Number = param2.z - param1.z;
         var _loc7_:Number = -param1.z / _loc6_;
         param3.x = param1.x + _loc7_ * _loc4_;
         param3.y = param1.y + _loc7_ * _loc5_;
         return param3;
      }
      
      public static function isPointInTriangle(param1:Point, param2:Point, param3:Point, param4:Point) : Boolean
      {
         var _loc5_:Number = param4.x - param2.x;
         var _loc6_:Number = param4.y - param2.y;
         var _loc7_:Number = param3.x - param2.x;
         var _loc8_:Number = param3.y - param2.y;
         var _loc9_:Number = param1.x - param2.x;
         var _loc10_:Number = param1.y - param2.y;
         var _loc11_:Number = _loc5_ * _loc5_ + _loc6_ * _loc6_;
         var _loc12_:Number = _loc5_ * _loc7_ + _loc6_ * _loc8_;
         var _loc13_:Number = _loc5_ * _loc9_ + _loc6_ * _loc10_;
         var _loc14_:Number = _loc7_ * _loc7_ + _loc8_ * _loc8_;
         var _loc15_:Number = _loc7_ * _loc9_ + _loc8_ * _loc10_;
         var _loc16_:Number = 1 / (_loc11_ * _loc14_ - _loc12_ * _loc12_);
         var _loc17_:Number = (_loc14_ * _loc13_ - _loc12_ * _loc15_) * _loc16_;
         var _loc18_:Number = (_loc11_ * _loc15_ - _loc12_ * _loc13_) * _loc16_;
         return _loc17_ >= 0 && _loc18_ >= 0 && _loc17_ + _loc18_ < 1;
      }
      
      public static function normalizeAngle(param1:Number) : Number
      {
         param1 %= TWO_PI;
         if(param1 < -Math.PI)
         {
            param1 += TWO_PI;
         }
         if(param1 > Math.PI)
         {
            param1 -= TWO_PI;
         }
         return param1;
      }
      
      public static function getNextPowerOfTwo(param1:Number) : int
      {
         var _loc2_:* = 0;
         if(param1 is int && param1 > 0 && (param1 & param1 - 1) == 0)
         {
            return param1;
         }
         _loc2_ = 1;
         param1 -= 1e-9;
         while(_loc2_ < param1)
         {
            _loc2_ <<= 1;
         }
         return _loc2_;
      }
      
      public static function isEquivalent(param1:Number, param2:Number, param3:Number = 0.0001) : Boolean
      {
         return param1 - param3 < param2 && param1 + param3 > param2;
      }
      
      public static function max(param1:Number, param2:Number) : Number
      {
         return param1 > param2 ? param1 : param2;
      }
      
      public static function min(param1:Number, param2:Number) : Number
      {
         return param1 < param2 ? param1 : param2;
      }
      
      public static function clamp(param1:Number, param2:Number, param3:Number) : Number
      {
         return param1 < param2 ? param2 : (param1 > param3 ? param3 : param1);
      }
   }
}

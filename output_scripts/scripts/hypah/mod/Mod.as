package hypah.mod
{
   public class Mod
   {
      
      public static var pi2:Number = 2 * Math.PI;
       
      
      public function Mod()
      {
         super();
      }
      
      public static function mod(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = NaN;
         if(param1 < 0)
         {
            _loc3_ = param2 - (param2 - param1) % param2;
            if(_loc3_ == param2)
            {
               return 0;
            }
            return _loc3_;
         }
         return param1 % param2;
      }
      
      public static function shortestArc(param1:Number, param2:Number, param3:Number) : Number
      {
         if(Math.abs(param2 - param1) < param3 / 2)
         {
            return param2 - param1;
         }
         if(param2 > param1)
         {
            return param2 - param1 - param3;
         }
         return param2 - param1 + param3;
      }
      
      public static function closestMod(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(param1 < 0)
         {
            if((_loc4_ = param3 - (param3 - param1) % param3) == param3)
            {
               _loc4_ = 0;
            }
         }
         else
         {
            _loc4_ = param1 % param3;
         }
         if(_loc4_ > param2)
         {
            _loc5_ = _loc4_ - param2;
         }
         else
         {
            _loc5_ = param2 - _loc4_;
         }
         if(_loc4_ - param3 > param2)
         {
            _loc6_ = _loc4_ - param3 - param2;
         }
         else
         {
            _loc6_ = param2 - (_loc4_ - param3);
         }
         if(_loc6_ < _loc5_)
         {
            _loc5_ = _loc6_;
            if(_loc4_ + param3 > param2)
            {
               _loc6_ = _loc4_ + param3 - param2;
            }
            else
            {
               _loc6_ = param2 - (_loc4_ + param3);
            }
            if(_loc6_ < _loc5_)
            {
               return _loc4_ + param3;
            }
            return _loc4_ - param3;
         }
         if(_loc4_ + param3 > param2)
         {
            _loc6_ = _loc4_ + param3 - param2;
         }
         else
         {
            _loc6_ = param2 - (_loc4_ + param3);
         }
         if(_loc6_ < _loc5_)
         {
            return _loc4_ + param3;
         }
         return _loc4_;
      }
      
      public static function closestRad(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(param1 < 0)
         {
            _loc3_ = pi2 - (pi2 - param1) % pi2;
            if(_loc3_ == pi2)
            {
               _loc3_ = 0;
            }
         }
         else
         {
            _loc3_ = param1 % pi2;
         }
         _loc4_ = Math.abs(_loc3_ - param2);
         if((_loc5_ = Math.abs(_loc3_ - pi2 - param2)) < _loc4_)
         {
            _loc4_ = _loc5_;
            if((_loc5_ = Math.abs(_loc3_ + pi2 - param2)) < _loc4_)
            {
               return _loc3_ + pi2;
            }
            return _loc3_ - pi2;
         }
         if((_loc5_ = Math.abs(_loc3_ + pi2 - param2)) < _loc4_)
         {
            return _loc3_ + pi2;
         }
         return _loc3_;
      }
      
      public static function closestAng(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(Math.abs(param1 - param2) > Math.abs(360 + param1 - param2))
         {
            _loc3_ = param2 + 360;
         }
         else if(Math.abs(param1 - param2) > Math.abs(-360 + param1 - param2))
         {
            _loc3_ = param2 - 360;
         }
         else
         {
            _loc3_ = param2;
         }
         return _loc3_;
      }
   }
}

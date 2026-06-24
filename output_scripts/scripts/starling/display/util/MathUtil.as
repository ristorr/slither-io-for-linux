package starling.display.util
{
   import flash.geom.Point;
   
   public class MathUtil
   {
      
      public static const RAD_TO_DEG:Number = 180 / Math.PI;
      
      public static const DEG_TO_RAD:Number = Math.PI / 180;
      
      public static const FULL_CIRCLE_ANGLE:Number = Math.PI * 2;
      
      public static const HALF_PI:Number = Math.PI / 2;
      
      public static const QUARTER_PI:Number = HALF_PI / 2;
      
      private static var denominator:Number;
      
      private static var a:Number;
      
      private static var b:Number;
      
      private static var numerator1:Number;
      
      private static var numerator2:Number;
       
      
      public function MathUtil()
      {
         super();
      }
      
      public static function calculateLineIntersectionPoint(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:Point) : Boolean
      {
         denominator = (param8 - param6) * (param3 - param1) - (param7 - param5) * (param4 - param2);
         if(denominator == 0)
         {
            return false;
         }
         a = param2 - param6;
         b = param1 - param5;
         numerator1 = (param7 - param5) * a - (param8 - param6) * b;
         numerator2 = (param3 - param1) * a - (param4 - param2) * b;
         a = numerator1 / denominator;
         b = numerator2 / denominator;
         param9.x = param1 + a * (param3 - param1);
         param9.y = param2 + a * (param4 - param2);
         return true;
      }
      
      public static function checkIfLineContainsPoint(param1:Point, param2:Point, param3:Point) : Boolean
      {
         return ((param2.y - param1.y) * (param3.x - param1.x)).toFixed(0) === ((param3.y - param1.y) * (param2.x - param1.x)).toFixed(0) && (param1.x > param3.x && param3.x > param2.x || param1.x < param3.x && param3.x < param2.x) && (param1.y >= param3.y && param3.y >= param2.y || param1.y <= param3.y && param3.y <= param2.y);
      }
      
      public static function calculateElipseY(param1:Number, param2:Number, param3:Number) : Number
      {
         return param2 / param1 * Math.sqrt(Math.pow(param1,2) - Math.pow(param3,2));
      }
      
      public static function calculateElipsePoint(param1:Number, param2:Number, param3:Number, param4:Point) : void
      {
         param4.x = Math.cos(param3) * param1;
         param4.y = MathUtil.calculateElipseY(param1,param2,param4.x);
      }
      
      public static function calculateAnglePoint(param1:Number, param2:Number, param3:Number, param4:Number, param5:Point) : void
      {
         param5.x = param1 + param3 * Math.cos(param4);
         param5.y = param2 + param3 * Math.sin(param4);
      }
   }
}

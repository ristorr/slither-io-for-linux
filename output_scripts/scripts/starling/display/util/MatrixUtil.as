package starling.display.util
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class MatrixUtil
   {
       
      
      public function MatrixUtil()
      {
         super();
      }
      
      public static function transformPoint(param1:Matrix, param2:Point, param3:Point) : void
      {
         param3.x = param1.a * param2.x + param1.c * param2.y + param1.tx;
         param3.y = param1.b * param2.x + param1.d * param2.y + param1.ty;
      }
   }
}

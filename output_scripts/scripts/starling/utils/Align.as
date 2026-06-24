package starling.utils
{
   import starling.errors.AbstractClassError;
   
   public final class Align
   {
      
      public static const LEFT:String = "left";
      
      public static const RIGHT:String = "right";
      
      public static const TOP:String = "top";
      
      public static const BOTTOM:String = "bottom";
      
      public static const CENTER:String = "center";
       
      
      public function Align()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function isValid(param1:String) : Boolean
      {
         return param1 == LEFT || param1 == RIGHT || param1 == CENTER || param1 == TOP || param1 == BOTTOM;
      }
      
      public static function isValidHorizontal(param1:String) : Boolean
      {
         return param1 == LEFT || param1 == CENTER || param1 == RIGHT;
      }
      
      public static function isValidVertical(param1:String) : Boolean
      {
         return param1 == TOP || param1 == CENTER || param1 == BOTTOM;
      }
   }
}

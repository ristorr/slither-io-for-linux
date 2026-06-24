package starling.display.util
{
   public class GPool
   {
      
      private static var _numberVectorPool:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
      
      private static var numberVector:Vector.<Number>;
       
      
      public function GPool()
      {
         super();
      }
      
      public static function getNumberVector() : Vector.<Number>
      {
         if(_numberVectorPool.length > 0)
         {
            return _numberVectorPool.pop();
         }
         return new Vector.<Number>();
      }
      
      public static function putNumberVector(param1:Vector.<Number>) : void
      {
         if(param1)
         {
            _numberVectorPool[_numberVectorPool.length] = param1;
         }
      }
   }
}

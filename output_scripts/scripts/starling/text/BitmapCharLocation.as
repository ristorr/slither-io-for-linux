package starling.text
{
   public class BitmapCharLocation
   {
      
      private static var sInstancePool:Vector.<starling.text.BitmapCharLocation> = new Vector.<starling.text.BitmapCharLocation>(0);
      
      private static var sVectorPool:Array = [];
      
      private static var sInstanceLoan:Vector.<starling.text.BitmapCharLocation> = new Vector.<starling.text.BitmapCharLocation>(0);
      
      private static var sVectorLoan:Array = [];
       
      
      public var char:starling.text.BitmapChar;
      
      public var scale:Number;
      
      public var x:Number;
      
      public var y:Number;
      
      public var index:int;
      
      public function BitmapCharLocation(param1:starling.text.BitmapChar)
      {
         super();
         this.init(param1);
      }
      
      public static function instanceFromPool(param1:starling.text.BitmapChar) : starling.text.BitmapCharLocation
      {
         var _loc2_:starling.text.BitmapCharLocation = sInstancePool.length > 0 ? sInstancePool.pop() : new starling.text.BitmapCharLocation(param1);
         _loc2_.init(param1);
         sInstanceLoan[sInstanceLoan.length] = _loc2_;
         return _loc2_;
      }
      
      public static function vectorFromPool() : Vector.<starling.text.BitmapCharLocation>
      {
         var _loc1_:Vector.<starling.text.BitmapCharLocation> = sVectorPool.length > 0 ? sVectorPool.pop() : new Vector.<starling.text.BitmapCharLocation>(0);
         _loc1_.length = 0;
         sVectorLoan[sVectorLoan.length] = _loc1_;
         return _loc1_;
      }
      
      public static function rechargePool() : void
      {
         var _loc1_:starling.text.BitmapCharLocation = null;
         var _loc2_:Vector.<starling.text.BitmapCharLocation> = null;
         while(sInstanceLoan.length > 0)
         {
            _loc1_ = sInstanceLoan.pop();
            _loc1_.char = null;
            sInstancePool[sInstancePool.length] = _loc1_;
         }
         while(sVectorLoan.length > 0)
         {
            _loc2_ = sVectorLoan.pop();
            _loc2_.length = 0;
            sVectorPool[sVectorPool.length] = _loc2_;
         }
      }
      
      private function init(param1:starling.text.BitmapChar) : starling.text.BitmapCharLocation
      {
         this.char = param1;
         return this;
      }
   }
}

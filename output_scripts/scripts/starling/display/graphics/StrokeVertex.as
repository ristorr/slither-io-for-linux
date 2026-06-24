package starling.display.graphics
{
   public class StrokeVertex
   {
      
      private static var pool:Vector.<starling.display.graphics.StrokeVertex> = new Vector.<starling.display.graphics.StrokeVertex>();
      
      private static var poolLength:int = 0;
      
      private static var i:int;
      
      private static var len:int;
       
      
      public var x:Number;
      
      public var y:Number;
      
      public var u:Number;
      
      public var v:Number;
      
      public var r1:Number;
      
      public var g1:Number;
      
      public var b1:Number;
      
      public var a1:Number;
      
      public var r2:Number;
      
      public var g2:Number;
      
      public var b2:Number;
      
      public var a2:Number;
      
      public var thickness:Number;
      
      public var degenerate:uint;
      
      public function StrokeVertex()
      {
         super();
      }
      
      public static function getInstance() : starling.display.graphics.StrokeVertex
      {
         if(poolLength == 0)
         {
            return new starling.display.graphics.StrokeVertex();
         }
         --poolLength;
         return pool.pop();
      }
      
      public static function putInstance(param1:starling.display.graphics.StrokeVertex) : void
      {
         var _loc2_:* = poolLength++;
         pool[_loc2_] = param1;
      }
      
      public static function putInstances(param1:Vector.<starling.display.graphics.StrokeVertex>) : void
      {
         i = 0;
         len = param1.length;
         while(i < len)
         {
            var _loc2_:* = poolLength++;
            pool[_loc2_] = param1[i];
            ++i;
         }
      }
      
      public function clone() : starling.display.graphics.StrokeVertex
      {
         var _loc1_:starling.display.graphics.StrokeVertex = getInstance();
         _loc1_.x = this.x;
         _loc1_.y = this.y;
         _loc1_.r1 = this.r1;
         _loc1_.g1 = this.g1;
         _loc1_.b1 = this.b1;
         _loc1_.a1 = this.a1;
         _loc1_.u = this.u;
         _loc1_.v = this.v;
         _loc1_.degenerate = this.degenerate;
         return _loc1_;
      }
   }
}

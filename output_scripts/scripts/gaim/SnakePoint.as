package gaim
{
   public class SnakePoint
   {
       
      
      public var xx:Number;
      
      public var yy:Number;
      
      public var fx:Number;
      
      public var fy:Number;
      
      public var fxs:Vector.<Number>;
      
      public var fys:Vector.<Number>;
      
      public var fltns:Vector.<Number>;
      
      public var fsmus:Vector.<Number>;
      
      public var fpos:int;
      
      public var da:Number;
      
      public var ftg:int;
      
      public var ebx:Number;
      
      public var eby:Number;
      
      public var ltn:Number;
      
      public var fltn:Number;
      
      public var smu:Number;
      
      public var fsmu:Number;
      
      public var pid:int;
      
      public var dying:Boolean;
      
      public var iang:int;
      
      public var taq:int;
      
      public function SnakePoint()
      {
         this.fxs = new Vector.<Number>();
         this.fys = new Vector.<Number>();
         this.fltns = new Vector.<Number>();
         this.fsmus = new Vector.<Number>();
         super();
      }
   }
}

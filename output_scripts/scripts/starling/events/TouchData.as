package starling.events
{
   public class TouchData
   {
      
      private static var sPool:Vector.<starling.events.TouchData> = new Vector.<starling.events.TouchData>(0);
       
      
      private var _id:int;
      
      private var _phase:String;
      
      private var _globalX:Number;
      
      private var _globalY:Number;
      
      private var _pressure:Number;
      
      private var _width:Number;
      
      private var _height:Number;
      
      public function TouchData()
      {
         super();
      }
      
      public static function fromPool(param1:int, param2:String, param3:Number, param4:Number, param5:Number = 1, param6:Number = 1, param7:Number = 1) : starling.events.TouchData
      {
         var _loc8_:starling.events.TouchData;
         (_loc8_ = sPool.length > 0 ? sPool.pop() : new starling.events.TouchData()).setTo(param1,param2,param3,param4,param5,param6,param7);
         return _loc8_;
      }
      
      public static function toPool(param1:starling.events.TouchData) : void
      {
         sPool[sPool.length] = param1;
      }
      
      private function setTo(param1:int, param2:String, param3:Number, param4:Number, param5:Number = 1, param6:Number = 1, param7:Number = 1) : void
      {
         this._id = param1;
         this._phase = param2;
         this._globalX = param3;
         this._globalY = param4;
         this._pressure = param5;
         this._width = param6;
         this._height = param7;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get phase() : String
      {
         return this._phase;
      }
      
      public function get globalX() : Number
      {
         return this._globalX;
      }
      
      public function get globalY() : Number
      {
         return this._globalY;
      }
      
      public function get pressure() : Number
      {
         return this._pressure;
      }
      
      public function get width() : Number
      {
         return this._width;
      }
      
      public function get height() : Number
      {
         return this._height;
      }
   }
}

package starling.utils
{
   import starling.events.Event;
   import starling.events.EventDispatcher;
   
   public class Padding extends EventDispatcher
   {
       
      
      private var _left:Number;
      
      private var _right:Number;
      
      private var _top:Number;
      
      private var _bottom:Number;
      
      public function Padding(param1:Number = 0, param2:Number = 0, param3:Number = 0, param4:Number = 0)
      {
         super();
         this.setTo(param1,param2,param3,param4);
      }
      
      public function setTo(param1:Number = 0, param2:Number = 0, param3:Number = 0, param4:Number = 0) : void
      {
         var _loc5_:Boolean = this._left != param1 || this._right != param2 || this._top != param3 || this._bottom != param4;
         this._left = param1;
         this._right = param2;
         this._top = param3;
         this._bottom = param4;
         if(_loc5_)
         {
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function setToUniform(param1:Number) : void
      {
         this.setTo(param1,param1,param1,param1);
      }
      
      public function setToSymmetric(param1:Number, param2:Number) : void
      {
         this.setTo(param1,param1,param2,param2);
      }
      
      public function copyFrom(param1:Padding) : void
      {
         if(param1 == null)
         {
            this.setTo(0,0,0,0);
         }
         else
         {
            this.setTo(param1._left,param1._right,param1._top,param1._bottom);
         }
      }
      
      public function clone() : Padding
      {
         return new Padding(this._left,this._right,this._top,this._bottom);
      }
      
      public function get left() : Number
      {
         return this._left;
      }
      
      public function set left(param1:Number) : void
      {
         if(this._left != param1)
         {
            this._left = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get right() : Number
      {
         return this._right;
      }
      
      public function set right(param1:Number) : void
      {
         if(this._right != param1)
         {
            this._right = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get top() : Number
      {
         return this._top;
      }
      
      public function set top(param1:Number) : void
      {
         if(this._top != param1)
         {
            this._top = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get bottom() : Number
      {
         return this._bottom;
      }
      
      public function set bottom(param1:Number) : void
      {
         if(this._bottom != param1)
         {
            this._bottom = param1;
            dispatchEventWith(Event.CHANGE);
         }
      }
      
      public function get horizontal() : Number
      {
         return this._left + this._right;
      }
      
      public function get vertical() : Number
      {
         return this._top + this._bottom;
      }
   }
}

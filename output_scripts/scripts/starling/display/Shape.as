package starling.display
{
   public class Shape extends DisplayObjectContainer
   {
       
      
      private var _graphics:Graphics;
      
      public function Shape()
      {
         super();
         this._graphics = new Graphics();
         this._graphics.container = this;
      }
      
      public function get graphics() : Graphics
      {
         return this._graphics;
      }
      
      override public function dispose() : void
      {
         this._graphics.clear();
         this._graphics.container = null;
         this._graphics = null;
         super.dispose();
      }
   }
}

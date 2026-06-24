package gaim
{
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import starling.textures.Texture;
   
   public class GameTextureContainer
   {
       
      
      public var bm:BitmapData = null;
      
      public var sheet:int;
      
      public var sheet_bm:BitmapData;
      
      public var x:int;
      
      public var y:int;
      
      public var width:int;
      
      public var height:int;
      
      public var inset:int = -1;
      
      public var inset_x:int = -1;
      
      public var inset_y:int = -1;
      
      public var r:Rectangle;
      
      public var texture:Texture;
      
      public function GameTextureContainer()
      {
         super();
      }
      
      public function repaint() : *
      {
         var _loc1_:Matrix = new Matrix();
         _loc1_.translate(this.x,this.y);
         this.sheet_bm.fillRect(this.r,0);
         this.sheet_bm.draw(this.bm,_loc1_);
      }
   }
}

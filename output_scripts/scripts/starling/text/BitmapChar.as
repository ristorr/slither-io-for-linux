package starling.text
{
   import flash.utils.Dictionary;
   import starling.display.Image;
   import starling.textures.Texture;
   
   public class BitmapChar
   {
       
      
      private var _texture:Texture;
      
      private var _charID:int;
      
      private var _xOffset:Number;
      
      private var _yOffset:Number;
      
      private var _xAdvance:Number;
      
      private var _kernings:Dictionary;
      
      public function BitmapChar(param1:int, param2:Texture, param3:Number, param4:Number, param5:Number)
      {
         super();
         this._charID = param1;
         this._texture = param2;
         this._xOffset = param3;
         this._yOffset = param4;
         this._xAdvance = param5;
         this._kernings = null;
      }
      
      public function addKerning(param1:int, param2:Number) : void
      {
         if(this._kernings == null)
         {
            this._kernings = new Dictionary();
         }
         this._kernings[param1] = param2;
      }
      
      public function getKerning(param1:int) : Number
      {
         if(this._kernings == null || this._kernings[param1] == undefined)
         {
            return 0;
         }
         return this._kernings[param1];
      }
      
      public function createImage() : Image
      {
         return new Image(this._texture);
      }
      
      public function get charID() : int
      {
         return this._charID;
      }
      
      public function get xOffset() : Number
      {
         return this._xOffset;
      }
      
      public function get yOffset() : Number
      {
         return this._yOffset;
      }
      
      public function get xAdvance() : Number
      {
         return this._xAdvance;
      }
      
      public function get texture() : Texture
      {
         return this._texture;
      }
      
      public function get width() : Number
      {
         return !!this._texture ? this._texture.width : 0;
      }
      
      public function get height() : Number
      {
         return !!this._texture ? this._texture.height : 0;
      }
   }
}

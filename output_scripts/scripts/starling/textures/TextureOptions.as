package starling.textures
{
   import starling.core.Starling;
   
   public class TextureOptions
   {
       
      
      private var _scale:Number;
      
      private var _format:String;
      
      private var _mipMapping:Boolean;
      
      private var _optimizeForRenderToTexture:Boolean = false;
      
      private var _premultipliedAlpha:Boolean;
      
      private var _forcePotTexture:Boolean;
      
      private var _onReady:Function = null;
      
      public function TextureOptions(param1:Number = 1, param2:Boolean = false, param3:String = "bgra", param4:Boolean = true, param5:Boolean = false)
      {
         super();
         this._scale = param1;
         this._format = param3;
         this._mipMapping = param2;
         this._forcePotTexture = param5;
         this._premultipliedAlpha = param4;
      }
      
      public function clone() : TextureOptions
      {
         var _loc1_:TextureOptions = new TextureOptions();
         _loc1_.copyFrom(this);
         return _loc1_;
      }
      
      public function copyFrom(param1:TextureOptions) : void
      {
         this._scale = param1._scale;
         this._mipMapping = param1._mipMapping;
         this._format = param1._format;
         this._optimizeForRenderToTexture = param1._optimizeForRenderToTexture;
         this._premultipliedAlpha = param1._premultipliedAlpha;
         this._forcePotTexture = param1._forcePotTexture;
         this._onReady = param1._onReady;
      }
      
      public function get scale() : Number
      {
         return this._scale;
      }
      
      public function set scale(param1:Number) : void
      {
         this._scale = param1 > 0 ? param1 : Starling.contentScaleFactor;
      }
      
      public function get format() : String
      {
         return this._format;
      }
      
      public function set format(param1:String) : void
      {
         this._format = param1;
      }
      
      public function get mipMapping() : Boolean
      {
         return this._mipMapping;
      }
      
      public function set mipMapping(param1:Boolean) : void
      {
         this._mipMapping = param1;
      }
      
      public function get optimizeForRenderToTexture() : Boolean
      {
         return this._optimizeForRenderToTexture;
      }
      
      public function set optimizeForRenderToTexture(param1:Boolean) : void
      {
         this._optimizeForRenderToTexture = param1;
      }
      
      public function get forcePotTexture() : Boolean
      {
         return this._forcePotTexture;
      }
      
      public function set forcePotTexture(param1:Boolean) : void
      {
         this._forcePotTexture = param1;
      }
      
      public function get onReady() : Function
      {
         return this._onReady;
      }
      
      public function set onReady(param1:Function) : void
      {
         this._onReady = param1;
      }
      
      public function get premultipliedAlpha() : Boolean
      {
         return this._premultipliedAlpha;
      }
      
      public function set premultipliedAlpha(param1:Boolean) : void
      {
         this._premultipliedAlpha = param1;
      }
   }
}

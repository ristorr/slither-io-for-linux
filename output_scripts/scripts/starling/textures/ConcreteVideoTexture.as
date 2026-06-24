package starling.textures
{
   import flash.display3D.Context3DTextureFormat;
   import flash.display3D.textures.TextureBase;
   import flash.display3D.textures.VideoTexture;
   import flash.events.Event;
   import starling.core.Starling;
   import starling.utils.execute;
   
   internal class ConcreteVideoTexture extends starling.textures.ConcreteTexture
   {
       
      
      private var _textureReadyCallback:Function;
      
      private var _disposed:Boolean;
      
      public function ConcreteVideoTexture(param1:VideoTexture, param2:Number = 1)
      {
         super(param1,Context3DTextureFormat.BGRA,param1.videoWidth,param1.videoHeight,false,false,false,param2);
      }
      
      override public function dispose() : void
      {
         base.removeEventListener(Event.TEXTURE_READY,this.onTextureReady);
         if(!this._disposed)
         {
            this.videoBase.attachCamera(null);
            this.videoBase.attachNetStream(null);
            this._disposed = true;
         }
         super.dispose();
      }
      
      override protected function createBase() : TextureBase
      {
         return Starling.context.createVideoTexture();
      }
      
      override internal function attachVideo(param1:String, param2:Object, param3:Function = null) : void
      {
         this._textureReadyCallback = param3;
         base["attach" + param1](param2);
         base.addEventListener(Event.TEXTURE_READY,this.onTextureReady);
         setDataUploaded();
      }
      
      private function onTextureReady(param1:Event) : void
      {
         base.removeEventListener(Event.TEXTURE_READY,this.onTextureReady);
         execute(this._textureReadyCallback,this);
         this._textureReadyCallback = null;
      }
      
      override public function get nativeWidth() : Number
      {
         return this.videoBase.videoWidth;
      }
      
      override public function get nativeHeight() : Number
      {
         return this.videoBase.videoHeight;
      }
      
      override public function get width() : Number
      {
         return this.nativeWidth / scale;
      }
      
      override public function get height() : Number
      {
         return this.nativeHeight / scale;
      }
      
      private function get videoBase() : VideoTexture
      {
         return base as VideoTexture;
      }
   }
}

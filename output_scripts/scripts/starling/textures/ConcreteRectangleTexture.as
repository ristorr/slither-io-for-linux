package starling.textures
{
   import flash.display.BitmapData;
   import flash.display3D.textures.RectangleTexture;
   import flash.display3D.textures.TextureBase;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.utils.setTimeout;
   import starling.core.Starling;
   import starling.utils.execute;
   
   internal class ConcreteRectangleTexture extends starling.textures.ConcreteTexture
   {
      
      private static var sAsyncUploadEnabled:Boolean = false;
       
      
      private var _textureReadyCallback:Function;
      
      public function ConcreteRectangleTexture(param1:RectangleTexture, param2:String, param3:int, param4:int, param5:Boolean, param6:Boolean = false, param7:Number = 1)
      {
         super(param1,param2,param3,param4,false,param5,param6,param7);
      }
      
      internal static function get asyncUploadEnabled() : Boolean
      {
         return sAsyncUploadEnabled;
      }
      
      internal static function set asyncUploadEnabled(param1:Boolean) : void
      {
         sAsyncUploadEnabled = param1;
      }
      
      override public function uploadBitmapData(param1:*, param2:* = null) : void
      {
         if(param2 is Function)
         {
            this._textureReadyCallback = param2 as Function;
         }
         this.upload(param1,param2 != null);
         setDataUploaded();
      }
      
      override protected function createBase() : TextureBase
      {
         return Starling.context.createRectangleTexture(nativeWidth,nativeHeight,format,optimizedForRenderTexture);
      }
      
      private function get rectBase() : RectangleTexture
      {
         return base as RectangleTexture;
      }
      
      private function upload(param1:BitmapData, param2:Boolean) : void
      {
         if(param2)
         {
            this.uploadAsync(param1);
            base.addEventListener(Event.TEXTURE_READY,this.onTextureReady);
            base.addEventListener(ErrorEvent.ERROR,this.onTextureReady);
         }
         else
         {
            this.rectBase.uploadFromBitmapData(param1);
         }
      }
      
      private function uploadAsync(param1:BitmapData) : void
      {
         var source:BitmapData = param1;
         if(sAsyncUploadEnabled)
         {
            try
            {
               base["uploadFromBitmapDataAsync"](source);
            }
            catch(error:Error)
            {
               if(!(error.errorID == 3708 || error.errorID == 1069))
               {
                  throw error;
               }
               sAsyncUploadEnabled = false;
            }
         }
         if(!sAsyncUploadEnabled)
         {
            setTimeout(base.dispatchEvent,1,new Event(Event.TEXTURE_READY));
            this.rectBase.uploadFromBitmapData(source);
         }
      }
      
      private function onTextureReady(param1:Event) : void
      {
         base.removeEventListener(Event.TEXTURE_READY,this.onTextureReady);
         base.removeEventListener(ErrorEvent.ERROR,this.onTextureReady);
         execute(this._textureReadyCallback,this,param1 as ErrorEvent);
         this._textureReadyCallback = null;
      }
   }
}

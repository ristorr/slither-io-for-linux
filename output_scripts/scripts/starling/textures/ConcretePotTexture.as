package starling.textures
{
   import flash.display.BitmapData;
   import flash.display3D.textures.Texture;
   import flash.display3D.textures.TextureBase;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import starling.core.Starling;
   import starling.utils.MathUtil;
   import starling.utils.execute;
   
   internal class ConcretePotTexture extends starling.textures.ConcreteTexture
   {
      
      private static var sMatrix:Matrix = new Matrix();
      
      private static var sRectangle:flash.geom.Rectangle = new flash.geom.Rectangle();
      
      private static var sOrigin:Point = new Point();
      
      private static var sAsyncUploadEnabled:Boolean = false;
       
      
      private var _textureReadyCallback:Function;
      
      public function ConcretePotTexture(param1:flash.display3D.textures.Texture, param2:String, param3:int, param4:int, param5:Boolean, param6:Boolean, param7:Boolean = false, param8:Number = 1)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8);
         if(param3 != MathUtil.getNextPowerOfTwo(param3))
         {
            throw new ArgumentError("width must be a power of two");
         }
         if(param4 != MathUtil.getNextPowerOfTwo(param4))
         {
            throw new ArgumentError("height must be a power of two");
         }
      }
      
      internal static function get asyncUploadEnabled() : Boolean
      {
         return sAsyncUploadEnabled;
      }
      
      internal static function set asyncUploadEnabled(param1:Boolean) : void
      {
         sAsyncUploadEnabled = param1;
      }
      
      override public function dispose() : void
      {
         base.removeEventListener(Event.TEXTURE_READY,this.onTextureReady);
         super.dispose();
      }
      
      override protected function createBase() : TextureBase
      {
         return Starling.context.createTexture(nativeWidth,nativeHeight,format,optimizedForRenderTexture);
      }
      
      override public function uploadBitmapData(param1:*, param2:* = null) : void
      {
         var _loc6_:BitmapData = null;
         var _loc7_:* = 0;
         var _loc8_:* = 0;
         var _loc9_:BitmapData = null;
         var _loc10_:Boolean = false;
         var _loc11_:int = 0;
         var _loc12_:Matrix = null;
         var _loc13_:BitmapData = null;
         var _loc3_:BitmapData = null;
         var _loc4_:Boolean = param2 is Function || param2 === true;
         if(param2 is Function)
         {
            this._textureReadyCallback = param2 as Function;
         }
         var _loc5_:Boolean = false;
         if(param1 is BitmapData)
         {
            _loc6_ = param1;
         }
         else
         {
            _loc6_ = param1[0];
            _loc5_ = true;
         }
         if(_loc6_.width != nativeWidth || _loc6_.height != nativeHeight)
         {
            _loc3_ = new BitmapData(nativeWidth,nativeHeight,true,0);
            _loc3_.copyPixels(_loc6_,_loc6_.rect,sOrigin);
            _loc6_ = _loc3_;
         }
         trace("  starting upload level 0: " + getTimer());
         this.upload(_loc6_,0,_loc4_);
         trace("  done at " + getTimer());
         if(mipMapping && _loc6_.width > 1 && _loc6_.height > 1)
         {
            _loc7_ = _loc6_.width >> 1;
            _loc8_ = _loc6_.height >> 1;
            _loc9_ = null;
            _loc10_ = false;
            _loc11_ = 1;
            (_loc12_ = sMatrix).setTo(0.5,0,0,0.5,0,0);
            while(_loc7_ >= 1 || _loc8_ >= 1)
            {
               _loc13_ = null;
               if(_loc5_)
               {
                  if(_loc11_ < param1.length)
                  {
                     if(param1[_loc11_].width == _loc7_ && param1[_loc11_].height == _loc8_)
                     {
                        _loc13_ = param1[_loc11_];
                     }
                     else
                     {
                        trace("ConcretePotTexture error " + param1[_loc11_].width + " " + param1[_loc11_].height + "    " + _loc7_ + " " + _loc8_);
                     }
                  }
               }
               if(_loc13_ == null)
               {
                  _loc13_ = new BitmapData(Math.max(1,_loc7_),Math.max(1,_loc8_),true,0);
                  _loc10_ = true;
                  if(_loc11_ == 1)
                  {
                     _loc13_.draw(_loc6_,_loc12_,null,null,null,true);
                  }
                  else
                  {
                     _loc13_.draw(_loc9_,_loc12_,null,null,null,true);
                  }
               }
               if(_loc9_ != null)
               {
                  if(_loc9_ != _loc6_)
                  {
                     if(_loc10_)
                     {
                        _loc9_.dispose();
                     }
                  }
               }
               _loc9_ = _loc13_;
               this.upload(_loc13_,_loc11_++,false);
               _loc7_ >>= 1;
               _loc8_ >>= 1;
            }
            if(_loc9_ != null)
            {
               if(_loc10_)
               {
                  _loc9_.dispose();
               }
            }
         }
         if(_loc3_)
         {
            _loc3_.dispose();
         }
         setDataUploaded();
      }
      
      override public function get isPotTexture() : Boolean
      {
         return true;
      }
      
      override public function uploadAtfData(param1:ByteArray, param2:int = 0, param3:* = null) : void
      {
         var _loc4_:Boolean = param3 is Function || param3 === true;
         if(param3 is Function)
         {
            this._textureReadyCallback = param3 as Function;
            base.addEventListener(Event.TEXTURE_READY,this.onTextureReady);
         }
         this.potBase.uploadCompressedTextureFromByteArray(param1,param2,_loc4_);
         setDataUploaded();
      }
      
      private function upload(param1:BitmapData, param2:uint, param3:Boolean) : void
      {
         if(param3)
         {
            trace("  uploading mipmap " + param1.width + "x" + param1.height + " at " + getTimer());
            this.uploadAsync(param1,param2);
            base.addEventListener(Event.TEXTURE_READY,this.onTextureReady);
            base.addEventListener(ErrorEvent.ERROR,this.onTextureReady);
         }
         else
         {
            trace("  uploading non-async mipmap " + param1.width + "x" + param1.height + " at " + getTimer());
            this.potBase.uploadFromBitmapData(param1,param2);
         }
      }
      
      private function uploadAsync(param1:BitmapData, param2:uint) : void
      {
         var source:BitmapData = param1;
         var mipLevel:uint = param2;
         if(sAsyncUploadEnabled)
         {
            try
            {
               base["uploadFromBitmapDataAsync"](source,mipLevel);
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
            this.potBase.uploadFromBitmapData(source);
         }
      }
      
      private function onTextureReady(param1:Event) : void
      {
         base.removeEventListener(Event.TEXTURE_READY,this.onTextureReady);
         base.removeEventListener(ErrorEvent.ERROR,this.onTextureReady);
         execute(this._textureReadyCallback,this,param1 as ErrorEvent);
         this._textureReadyCallback = null;
      }
      
      private function get potBase() : flash.display3D.textures.Texture
      {
         return base as flash.display3D.textures.Texture;
      }
   }
}

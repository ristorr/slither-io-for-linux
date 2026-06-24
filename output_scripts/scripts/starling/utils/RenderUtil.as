package starling.utils
{
   import flash.display.Stage3D;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DMipFilter;
   import flash.display3D.Context3DRenderMode;
   import flash.display3D.Context3DTextureFilter;
   import flash.display3D.Context3DTextureFormat;
   import flash.display3D.Context3DWrapMode;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.utils.setTimeout;
   import starling.core.Starling;
   import starling.errors.AbstractClassError;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   
   public class RenderUtil
   {
       
      
      public function RenderUtil()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function clear(param1:uint = 0, param2:Number = 0, param3:Number = 1, param4:uint = 0) : void
      {
         Starling.context.clear(Color.getRed(param1) / 255,Color.getGreen(param1) / 255,Color.getBlue(param1) / 255,param2,param3,param4);
      }
      
      public static function getTextureLookupFlags(param1:String, param2:Boolean, param3:Boolean = false, param4:String = "bilinear") : String
      {
         var _loc5_:Array = ["2d",param3 ? "repeat" : "clamp"];
         if(param1 == Context3DTextureFormat.COMPRESSED)
         {
            _loc5_.push("dxt1");
         }
         else if(param1 == "compressedAlpha")
         {
            _loc5_.push("dxt5");
         }
         if(param4 == TextureSmoothing.NONE)
         {
            _loc5_.push("nearest",param2 ? "mipnearest" : "mipnone");
         }
         else if(param4 == TextureSmoothing.BILINEAR)
         {
            _loc5_.push("linear",param2 ? "mipnearest" : "mipnone");
         }
         else
         {
            _loc5_.push("linear",param2 ? "miplinear" : "mipnone");
         }
         return "<" + _loc5_.join() + ">";
      }
      
      public static function getTextureVariantBits(param1:Texture) : uint
      {
         if(param1 == null)
         {
            return 0;
         }
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         switch(param1.format)
         {
            case Context3DTextureFormat.COMPRESSED_ALPHA:
               _loc3_ = 3;
               break;
            case Context3DTextureFormat.COMPRESSED:
               _loc3_ = 2;
               break;
            default:
               _loc3_ = 1;
         }
         _loc2_ |= _loc3_;
         if(!param1.premultipliedAlpha)
         {
            _loc2_ |= 1 << 2;
         }
         return _loc2_;
      }
      
      public static function setSamplerStateAt(param1:int, param2:Boolean, param3:String = "bilinear", param4:Boolean = false) : void
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc5_:String = param4 ? Context3DWrapMode.REPEAT : Context3DWrapMode.CLAMP;
         if(param3 == TextureSmoothing.NONE)
         {
            _loc6_ = Context3DTextureFilter.NEAREST;
            _loc7_ = param2 ? Context3DMipFilter.MIPNEAREST : Context3DMipFilter.MIPNONE;
         }
         else if(param3 == TextureSmoothing.BILINEAR)
         {
            _loc6_ = Context3DTextureFilter.LINEAR;
            _loc7_ = param2 ? Context3DMipFilter.MIPNEAREST : Context3DMipFilter.MIPNONE;
         }
         else
         {
            _loc6_ = Context3DTextureFilter.LINEAR;
            _loc7_ = param2 ? Context3DMipFilter.MIPLINEAR : Context3DMipFilter.MIPNONE;
         }
         Starling.context.setSamplerStateAt(param1,_loc5_,_loc6_,_loc7_);
      }
      
      public static function createAGALTexOperation(param1:String, param2:String, param3:int, param4:Texture, param5:Boolean = true, param6:String = "ft0") : String
      {
         var _loc8_:String = null;
         var _loc7_:String = param4.format;
         switch(_loc7_)
         {
            case Context3DTextureFormat.COMPRESSED:
               _loc8_ = "dxt1";
               break;
            case Context3DTextureFormat.COMPRESSED_ALPHA:
               _loc8_ = "dxt5";
               break;
            default:
               _loc8_ = "rgba";
         }
         var _loc9_:Boolean;
         var _loc10_:String = (_loc9_ = param5 && !param4.premultipliedAlpha) && param1 == "oc" ? param6 : param1;
         var _loc11_:* = "tex " + _loc10_ + ", " + param2 + ", fs" + param3 + " <2d, " + _loc8_ + ">\n";
         if(_loc9_)
         {
            if(param1 == "oc")
            {
               _loc11_ = (_loc11_ += "mul " + _loc10_ + ".xyz, " + _loc10_ + ".xyz, " + _loc10_ + ".www\n") + ("mov " + param1 + ", " + _loc10_);
            }
            else
            {
               _loc11_ += "mul " + param1 + ".xyz, " + _loc10_ + ".xyz, " + _loc10_ + ".www\n";
            }
         }
         return _loc11_;
      }
      
      public static function requestContext3D(param1:Stage3D, param2:String, param3:*) : void
      {
         var profiles:Array = null;
         var currentProfile:String = null;
         var requestNextProfile:Function = null;
         var onCreated:Function = null;
         var onError:Function = null;
         var stage3D:Stage3D = param1;
         var renderMode:String = param2;
         var profile:* = param3;
         requestNextProfile = function():void
         {
            currentProfile = profiles.shift();
            try
            {
               executeFunc(stage3D.requestContext3D,renderMode,currentProfile);
            }
            catch(error:Error)
            {
               if(profiles.length == 0)
               {
                  throw error;
               }
               setTimeout(requestNextProfile,1);
            }
         };
         onCreated = function(param1:Event):void
         {
            var _loc2_:Context3D = stage3D.context3D;
            if(renderMode == Context3DRenderMode.AUTO && profiles.length != 0 && _loc2_.driverInfo.indexOf("Software") != -1)
            {
               onError(param1);
            }
            else
            {
               onFinished();
            }
         };
         onError = function(param1:Event):void
         {
            if(profiles.length != 0)
            {
               param1.stopImmediatePropagation();
               setTimeout(requestNextProfile,1);
            }
            else
            {
               onFinished();
            }
         };
         var onFinished:Function = function():void
         {
            stage3D.removeEventListener(Event.CONTEXT3D_CREATE,onCreated);
            stage3D.removeEventListener(ErrorEvent.ERROR,onError);
         };
         var executeFunc:Function = SystemUtil.isDesktop ? execute : SystemUtil.executeWhenApplicationIsActive;
         if(profile == "auto")
         {
            profiles = ["enhanced","standardExtended","standard","standardConstrained","baselineExtended","baseline","baselineConstrained"];
         }
         else if(profile is String)
         {
            profiles = [profile as String];
         }
         else
         {
            if(!(profile is Array))
            {
               throw new ArgumentError("Profile must be of type \'String\' or \'Array\'");
            }
            profiles = profile as Array;
         }
         stage3D.addEventListener(Event.CONTEXT3D_CREATE,onCreated,false,100);
         stage3D.addEventListener(ErrorEvent.ERROR,onError,false,100);
         requestNextProfile();
      }
   }
}

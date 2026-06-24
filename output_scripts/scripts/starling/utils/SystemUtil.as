package starling.utils
{
   import flash.display3D.Context3D;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.system.Capabilities;
   import flash.text.Font;
   import flash.text.FontStyle;
   import flash.utils.getDefinitionByName;
   import starling.errors.AbstractClassError;
   
   public class SystemUtil
   {
      
      private static var sInitialized:Boolean = false;
      
      private static var sApplicationActive:Boolean = true;
      
      private static var sWaitingCalls:Array = [];
      
      private static var sPlatform:String;
      
      private static var sVersion:String;
      
      private static var sAIR:Boolean;
      
      private static var sEmbeddedFonts:Array = null;
      
      private static var sSupportsDepthAndStencil:Boolean = true;
       
      
      public function SystemUtil()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function initialize() : void
      {
         var nativeAppClass:Object = null;
         var nativeApp:EventDispatcher = null;
         var appDescriptor:XML = null;
         var ns:Namespace = null;
         var ds:String = null;
         if(sInitialized)
         {
            return;
         }
         sInitialized = true;
         sPlatform = Capabilities.version.substr(0,3);
         sVersion = Capabilities.version.substr(4);
         try
         {
            nativeAppClass = getDefinitionByName("flash.desktop::NativeApplication");
            nativeApp = nativeAppClass["nativeApplication"] as EventDispatcher;
            nativeApp.addEventListener(Event.ACTIVATE,onActivate,false,0,true);
            nativeApp.addEventListener(Event.DEACTIVATE,onDeactivate,false,0,true);
            appDescriptor = nativeApp["applicationDescriptor"];
            ns = appDescriptor.namespace();
            ds = String(appDescriptor.ns::initialWindow.ns::depthAndStencil.toString().toLowerCase());
            sSupportsDepthAndStencil = ds == "true";
            sAIR = true;
         }
         catch(e:Error)
         {
            sAIR = false;
         }
      }
      
      private static function onActivate(param1:Object) : void
      {
         var call:Array = null;
         var event:Object = param1;
         sApplicationActive = true;
         for each(call in sWaitingCalls)
         {
            try
            {
               call[0].apply(null,call[1]);
            }
            catch(e:Error)
            {
               trace("[Starling] Error in \'executeWhenApplicationIsActive\' call:",e.message);
            }
         }
         sWaitingCalls = [];
      }
      
      private static function onDeactivate(param1:Object) : void
      {
         sApplicationActive = false;
      }
      
      public static function executeWhenApplicationIsActive(param1:Function, ... rest) : void
      {
         initialize();
         if(sApplicationActive)
         {
            param1.apply(null,rest);
         }
         else
         {
            sWaitingCalls.push([param1,rest]);
         }
      }
      
      public static function get isApplicationActive() : Boolean
      {
         initialize();
         return sApplicationActive;
      }
      
      public static function get isAIR() : Boolean
      {
         initialize();
         return sAIR;
      }
      
      public static function get version() : String
      {
         initialize();
         return sVersion;
      }
      
      public static function get platform() : String
      {
         initialize();
         return sPlatform;
      }
      
      public static function set platform(param1:String) : void
      {
         initialize();
         sPlatform = param1;
      }
      
      public static function get supportsDepthAndStencil() : Boolean
      {
         return sSupportsDepthAndStencil;
      }
      
      public static function get supportsVideoTexture() : Boolean
      {
         return Context3D["supportsVideoTexture"];
      }
      
      public static function updateEmbeddedFonts() : void
      {
         sEmbeddedFonts = null;
      }
      
      public static function isEmbeddedFont(param1:String, param2:Boolean = false, param3:Boolean = false, param4:String = "embedded") : Boolean
      {
         var _loc5_:Font = null;
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         if(sEmbeddedFonts == null)
         {
            sEmbeddedFonts = Font.enumerateFonts(false);
         }
         for each(_loc5_ in sEmbeddedFonts)
         {
            _loc7_ = (_loc6_ = String(_loc5_.fontStyle)) == FontStyle.BOLD || _loc6_ == FontStyle.BOLD_ITALIC;
            _loc8_ = _loc6_ == FontStyle.ITALIC || _loc6_ == FontStyle.BOLD_ITALIC;
            if(param1 == _loc5_.fontName && param2 == _loc7_ && param3 == _loc8_ && param4 == _loc5_.fontType)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function get isIOS() : Boolean
      {
         return platform == "IOS";
      }
      
      public static function get isAndroid() : Boolean
      {
         return platform == "AND";
      }
      
      public static function get isMac() : Boolean
      {
         return platform == "MAC";
      }
      
      public static function get isWindows() : Boolean
      {
         return platform == "WIN";
      }
      
      public static function get isDesktop() : Boolean
      {
         return platform == "WIN" || platform == "MAC" || platform == "LNX";
      }
   }
}
